#' @name mclapply_socket
#' @title Define a sockets version of mclapply
#' @description An implementation of mclapply function (package parallel) using parLapply function (package parallel).
#' Windows does not support forking. This makes it impossible to use mclapply on Windows to farm out work to additional cores.
#' This function was developped througth framework of work done by Nathan VanHoudnos. Source: https://github.com/nathanvan/parallelsugar.git
#' @import parallel
#' @export
mclapply_socket <- function(X,
                            FUN,
                            ...,
                            mc.preschedule = TRUE,
                            mc.set.seed = TRUE,
                            mc.silent = FALSE,
                            mc.cores = NULL,
                            mc.cleanup = TRUE,
                            mc.allow.recursive = TRUE) {
  # Create a cluster
  if (is.null(mc.cores)) {
    mc.cores <- min(length(X), parallel::detectCores())
  }
  cl <- parallel::makeCluster(mc.cores)

  tryCatch({
    # Find out the names of the loaded packages
    loaded.package.names <- c(
      # Base packages
      sessionInfo()$basePkgs,
      # Additional packages
      names(sessionInfo()$otherPkgs ))

    # Ship it to the clusters
    parallel::clusterExport(cl,
                            'loaded.package.names',
                            envir = environment())

    # Load the libraries on all the clusters
    # N.B. length(cl) returns the number of clusters
    parallel::parLapply(cl,
                        1:length(cl),
                        function(xx) {
                          lapply(loaded.package.names,
                                 function(yy) {
                                   require(yy,
                                           character.only = TRUE)})
                        })

    clusterExport_function(cl, FUN)

    ## Run the lapply in parallel, with a special case for the ... arguments
    if( length(list(...)) == 0) {
      return(parallel::parLapply(cl = cl,
                                 X = X,
                                 fun = FUN))
    } else {
      return(parallel::parLapply(cl = cl,
                                 X = X,
                                 fun = FUN,
                                 ...))
    }
  },
  finally = {
    # Stop the cluster
    parallel::stopCluster(cl)
  })
}

#' @name mclapply
#' @title mclapply for Windows
#' @description Overwrite the serial version of mclapply on Windows only
#' @export
mclapply <- switch( Sys.info()[['sysname']],
                    Windows = {mclapply_socket},
                    Linux   = {parallel::mclapply},
                    Darwin  = {parallel::mclapply})

clusterExport_function <- function(cl, FUN ) {
  # We want the enclosing environment, not the calling environment
  # (I had tried parent.frame, which was not what we needed)
  # Written by Hadley Wickham, off the top of his head, when I asked him for help at one of his Advanced R workshops.
  env <- environment(FUN)
  while(!identical(env, globalenv())) {
    env <- parent.env(env)
    parallel::clusterExport(cl,
                            ls(all.names=TRUE,
                               envir = env),
                            envir = env)
  }
  parallel::clusterExport(cl,
                          ls(all.names=TRUE,
                             envir = env),
                          envir = env)
}
