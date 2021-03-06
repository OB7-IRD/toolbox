% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/add_vertices.R
\name{add_vertices}
\alias{add_vertices}
\title{Densify a spatial polygon by adding vertices}
\usage{
add_vertices(sp, each = as.numeric(0.1), parallel = FALSE, ...)
}
\arguments{
\item{sp}{SpatialPolygonsDataFrame expected. An object of class "SpatialPolygonsDataFrame".}

\item{each}{{\link[base]{numeric}} or {\link[base]{integer}} expected. The step value to use to create vertices. By default 0.1.}

\item{parallel}{{\link[base]{logical}} expected. Run in parallel (if you have at least two processor cores). By default FALSE.}

\item{...}{Others parallel options}
}
\value{
An object of class "SpatialPolygonsDataFrame".
}
\description{
Densify a spatial polygon by adding vertices.
}
\references{
From a function developed by Emmanuel Blondel \email{emmanuel.blondel1@gmail.com}.
}
