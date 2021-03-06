% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/marine_area_overlay.R
\name{marine_area_overlay}
\alias{marine_area_overlay}
\title{Consistent spatial marine area overlay (related to fao area)}
\usage{
marine_area_overlay(
  data,
  overlay_level = "major",
  longitude_name,
  latitude_name,
  tolerance = 0
)
}
\arguments{
\item{data}{{\link[base]{data.frame}} expected. R dataframe, with at least two columns with longitude and latitude values. Be careful! Your longitude and latitude data have to be in the WGS84 projection and coordinates in decimal degrees.}

\item{overlay_level}{{\link[base]{character}} expected. Level of accuarcy that you want for classified your data. By default, major fao fishing area are selected. Check the section details below.}

\item{longitude_name}{{\link[base]{character}} expected. Longitude column name in your data.}

\item{latitude_name}{{\link[base]{character}} expected. Latitude column name in your data.}

\item{tolerance}{{\link[base]{numeric}} expected. Tolerance of maximum distance between coordinates and area selected (in km). By default no tolerance (0 km).}
}
\value{
The function return your input data frame with one or several columns (regarding specification in the argument "overlay_level") which contains area classification. For avoid conflicts, new colums ended by _MAO (for marine area overlay).
}
\description{
Consistent spatial marine area overlay (related to fao area) for points, grids and polygons.
}
\details{
For the argument "overlay_level", you can choose between 5 modalities (descending size classification):
\itemize{
 \item{ocean: }{ocean area}
 \item{major: }{major fao fishing area}
 \item{subarea: }{sub fao fishing area}
 \item{division: }{division fao fishing area}
 \item{subdivision: }{sub-division fao fishing area}
 \item{subunit: }{sub-unit fao fishing area}
}
Specificity for fao fishing area parameters: all the items above your specification (thus contain it at higher levels) will be added in the output. For example, if you select "subarea", you will also have the information about the major area concerning.
If you want more information visit http://www.fao.org/fishery/area/search/en
}
\examples{
# Example for classification until division fao fishing area, with a tolerance of 10 km
\dontrun{
#' tmp <- fao_area_overlay(data = data,
                        overlay_level = "division",
                        longitude_name = "longitude",
                        latitude_name = "latitude",
                        tolerance = 10)}
}
