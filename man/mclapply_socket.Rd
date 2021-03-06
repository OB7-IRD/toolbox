% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mclapply_socket.R
\name{mclapply_socket}
\alias{mclapply_socket}
\title{Define a sockets version of mclapply}
\usage{
mclapply_socket(
  X,
  FUN,
  ...,
  mc.preschedule = TRUE,
  mc.set.seed = TRUE,
  mc.silent = FALSE,
  mc.cores = NULL,
  mc.cleanup = TRUE,
  mc.allow.recursive = TRUE
)
}
\description{
An implementation of mclapply function (package parallel) using parLapply function (package parallel).
Windows does not support forking. This makes it impossible to use mclapply on Windows to farm out work to additional cores.
This function was developped througth framework of work done by Nathan VanHoudnos. Source: https://github.com/nathanvan/parallelsugar.git
}
