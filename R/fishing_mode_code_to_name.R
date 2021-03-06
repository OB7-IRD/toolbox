#' @name fishing_mode_code_to_name
#' @title Fishing mode(s) name(s) creation
#' @description Fishing mode(s) name(s) creation in relation with fishing mode referential of the IRD Ob7 (Observatory of Exploited Tropical Pelagic Ecosystems).
#' @param fishing_mode_code {\link[base]{numeric}} expected. Fishing mode code(s).
#' @return A character vector in relation with the fishing mode(s) code(s) provided.
#' @examples
#' fishing_mode_code_to_name(fishing_mode_code = c(1, 2, 3))
#' @export
#' @importFrom dplyr last
#' @importFrom stringr str_split
fishing_mode_code_to_name <- function (fishing_mode_code) {
  # Arguments verification ----
  if (missing(fishing_mode_code) || ! is.numeric(fishing_mode_code)) {
    stop("invalid \"fishing_mode_code\" argument")
  }
  # Function ----
  if (length(fishing_mode_code) == 1) {
    if (fishing_mode_code == 1) {
      fishing_mode_name <- "floating object"
      fishing_mode_code_chr <- "FOB"
    } else {
      if (fishing_mode_code == 2) {
        fishing_mode_name <- "free school"
        fishing_mode_code_chr <- "FSC"
      } else {
        if (fishing_mode_code == 3) {
          fishing_mode_name <- "undetermined school"
          fishing_mode_code_chr <- "UND"
        }
      }
    }
  } else {
    fishing_mode_name <- NULL
    fishing_mode_code_chr <- NULL
    for (i in fishing_mode_code) {
      if (i == 1) {
        fishing_mode_name <- ifelse(is.null(fishing_mode_name),
                                    "floating object, ",
                                    paste0(fishing_mode_name, "floating object, "))
        fishing_mode_code_chr <- ifelse(is.null(fishing_mode_code_chr),
                                        "FOB, ",
                                        paste0(fishing_mode_code_chr, "FOB, "))
      } else {
        if (i == 2) {
          fishing_mode_name <- ifelse(is.null(fishing_mode_name),
                                      "free school, ",
                                      paste0(fishing_mode_name, "free school, "))
          fishing_mode_code_chr <- ifelse(is.null(fishing_mode_code_chr),
                                          "FSC, ",
                                          paste0(fishing_mode_code_chr, "FSC, "))
        } else {
          if (i == 3) {
            fishing_mode_name <- ifelse(is.null(fishing_mode_name),
                                        "undetermined school, ",
                                        paste0(fishing_mode_name, "undetermined school, "))
            fishing_mode_code_chr <- ifelse(is.null(fishing_mode_code_chr),
                                            "UND, ",
                                            paste0(fishing_mode_code_chr, "UND, "))
          }
        }
      }
    }
    if (i == dplyr::last(fishing_mode_code)) {
      tmp <- stringr::str_split(string = fishing_mode_name, pattern = ", ", simplify = TRUE)
      tmp <- tmp[tmp != ""]
      fishing_mode_name <- paste0(paste(tmp[tmp != dplyr::last(tmp)],
                                        collapse = ", "),
                                  " and ",
                                  dplyr::last(tmp))
      tmp <- stringr::str_split(string = fishing_mode_code_chr, pattern = ", ", simplify = TRUE)
      tmp <- tmp[tmp != ""]
      fishing_mode_code_chr <- paste0(paste(tmp[tmp != dplyr::last(tmp)],
                                            collapse = ", "),
                                      " and ",
                                      dplyr::last(tmp))
    }
  }
  fishing_mode <- c("fishing_mode_name" = fishing_mode_name,
                    "fishing_mode_code_chr" = fishing_mode_code_chr)
  return(fishing_mode)
}
