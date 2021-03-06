#' @name marine_area_overlay
#' @title Consistent spatial marine area overlay (related to fao area)
#' @description Consistent spatial marine area overlay (related to fao area) for points, grids and polygons.
#' @param data {\link[base]{data.frame}} expected. R dataframe, with at least two columns with longitude and latitude values. Be careful! Your longitude and latitude data have to be in the WGS84 projection and coordinates in decimal degrees.
#' @param overlay_level {\link[base]{character}} expected. Level of accuarcy that you want for classified your data. By default, major fao fishing area are selected. Check the section details below.
#' @param longitude_name {\link[base]{character}} expected. Longitude column name in your data.
#' @param latitude_name {\link[base]{character}} expected. Latitude column name in your data.
#' @param tolerance {\link[base]{numeric}} expected. Tolerance of maximum distance between coordinates and area selected (in km). By default no tolerance (0 km).
#' @return The function return your input data frame with one or several columns (regarding specification in the argument "overlay_level") which contains area classification. For avoid conflicts, new colums ended by _MAO (for marine area overlay).
#' @details
#' For the argument "overlay_level", you can choose between 5 modalities (descending size classification):
#' \itemize{
#'  \item{ocean: }{ocean area}
#'  \item{major: }{major fao fishing area}
#'  \item{subarea: }{sub fao fishing area}
#'  \item{division: }{division fao fishing area}
#'  \item{subdivision: }{sub-division fao fishing area}
#'  \item{subunit: }{sub-unit fao fishing area}
#' }
#' Specificity for fao fishing area parameters: all the items above your specification (thus contain it at higher levels) will be added in the output. For example, if you select "subarea", you will also have the information about the major area concerning.
#' If you want more information visit http://www.fao.org/fishery/area/search/en
#' @examples
#' # Example for classification until division fao fishing area, with a tolerance of 10 km
#' \dontrun{
#' #' tmp <- fao_area_overlay(data = data,
#'                         overlay_level = "division",
#'                         longitude_name = "longitude",
#'                         latitude_name = "latitude",
#'                         tolerance = 10)}
#' @export
#' @importFrom rgdal readOGR
#' @importFrom sp coordinates proj4string spTransform
#' @importFrom rgeos gDistance
#' @importFrom dplyr inner_join select
marine_area_overlay <- function(data,
                                overlay_level = "major",
                                longitude_name,
                                latitude_name,
                                tolerance = 0) {
  if (missing(data) || ! is.data.frame(data)) {
    stop("invalid \"data\" argument")
  }
  overlay_level <- match.arg(arg = overlay_level,
                             choices = c("ocean", "major", "subarea", "division", "subdivision", "subunit"))
  if (missing(longitude_name) || ! is.character(longitude_name)) {
    stop("invalid \"longitude_name\" argument")
  }
  if (missing(latitude_name) || ! is.character(latitude_name)) {
    stop("invalid \"latitude_name\" argument")
  }
  if (! is.numeric(tolerance)) {
    stop("Missing \"tolerance\" argument")
  }
  cat("Be careful!",
      "\n",
      "You're spatial coordinates have to be in WGS84 projection",
      "\n",
      "Be patient! The function could be long\n")
  # Fao area shapefile importation ----
  tmp <- rgdal::readOGR(dsn = system.file("fao_area",
                                          "FAO_AREAS.shp",
                                          package = "furdeb"),
                        verbose = FALSE)
  # Data design ----
  tmp1 <- unique(data[, c(longitude_name, latitude_name)])
  sp::coordinates(tmp1) <- c(longitude_name,
                             latitude_name)
  sp::proj4string(tmp1) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
  tmp2 <- as.data.frame(tmp1)
  tmp1 <- sp::spTransform(tmp1,
                          "+proj=merc +lon_0=0 +k=1 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
  tmp <- sp::spTransform(tmp,
                         sp::proj4string(tmp1))
  # Data spatial overlay ----
  if (overlay_level == "ocean") {
    accuracy <- "OCEAN"
    names(accuracy) <- "MAJOR"
  } else {
    if (overlay_level == "major") {
      accuracy <- "F_AREA"
      names(accuracy) <- "MAJOR"
    } else {
      if (overlay_level == "subarea") {
        accuracy <- c("F_AREA", "F_SUBAREA")
        names(accuracy) <- c("MAJOR", "SUBAREA")
      } else {
        if (overlay_level == "division") {
          accuracy <- c("F_AREA", "F_SUBAREA", "F_DIVISION")
          names(accuracy) <- c("MAJOR", "SUBAREA", "DIVISION")
        } else {
          if (overlay_level == "subdivision") {
            accuracy <- c("F_AREA", "F_SUBAREA", "F_DIVISION", "F_SUBDIVIS")
            names(accuracy) <- c("MAJOR", "SUBAREA", "DIVISION", "SUBDIVISION")
          } else {
            if (overlay_level == "subunit") {
              accuracy <- c("F_AREA", "F_SUBAREA", "F_DIVISION", "F_SUBDIVIS", "F_SUBUNIT")
              names(accuracy) <- c("MAJOR", "SUBAREA", "DIVISION", "SUBDIVISION", "SUBUNIT")
            }
          }
        }
      }
    }
  }
  tmp2 <- cbind(tmp2, as.data.frame(tmp1))
  names(tmp2)[3:4] <- c("longitude_bis", "latitude_bis")
  for (step1 in names(accuracy)) {
    tmp_sub <- tmp[tmp$F_LEVEL == step1, ]
    name_cols <- as.character(t(tmp_sub@data[as.character(accuracy[step1])]))
    tmp3 <- as.data.frame(rgeos::gDistance(tmp_sub[, as.character(accuracy[step1])],
                                           tmp1,
                                           byid = TRUE))
    names(name_cols) <- colnames(tmp3)
    #colnames(tmp3) <- as.character(t(tmp_sub@data[as.character(accuracy[step1])]))
    nb_col_tmp3 <- dim(tmp3)[2]
    for (i in 1:dim(tmp3)[1]) {
      tmp3[i, "min_dist"] <- ifelse(min(tmp3[i, 1:nb_col_tmp3]) <= (tolerance * 1000),
                                    name_cols[names(which.min(tmp3[i, ]))],
                                    "far_away")
    }
    tmp4 <- select(.data = tmp3, min_dist)
    names(tmp4) <- paste0(as.character(accuracy[step1]),
                          "_MAO")
    tmp2 <- cbind(tmp2,
                  tmp4)
    if (step1 == names(accuracy)[length(accuracy)]) {
      names(tmp2)[5:ncol(tmp2)] <- tolower(names(tmp2)[5:ncol(tmp2)])
      data <- dplyr::inner_join(data,
                                tmp2,
                                by = c(latitude_name, longitude_name)) %>%
        dplyr::select(-longitude_bis, -latitude_bis)
    }
  }
  return(data)
}
