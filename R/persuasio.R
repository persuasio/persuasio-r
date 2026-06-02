#' @title Unified Interface for Causal Inference on Persuasion Effects
#'
#' @description Main wrapper for the \pkg{persuasio} package. Provides a unified
#'   entry point to all persuasion effect estimators. The function parses inputs
#'   and dispatches to the appropriate estimator based on \code{est}. The
#'   variables \code{y}, \code{t}, \code{z}, and \code{x} can be supplied in any
#'   order as explicitly named arguments. For \code{est = "apr"}, \code{"lpr"},
#'   and \code{"calc"}, supplying \code{y} (outcome), \code{t} (treatment), and
#'   \code{z} (instrument) is mandatory. For \code{est = "yz"}, where the
#'   treatment is unobserved, only \code{y} and \code{z} are required, while the
#'   treatment argument \code{t} is ignored. Optional covariates can be supplied
#'   to \code{x} for any estimator mode.
#'
#' @param est character. Estimator type:
#' \itemize{
#'   \item \code{"apr"}: Average persuasion rate bounds for binary outcome, treatment and instrument
#'   \item \code{"lpr"}: Local persuasion rate bounds for binary outcome, treatment and instrument
#'   \item \code{"yz"}: Average and local persuasion rate bounds using binary outcome and instrument only
#'   \item \code{"calc"}: Average and local persuasion rate calculation from summary statistics
#' }
#'
#' @param y character, outcome variable name (binary 0/1)
#' @param z character, instrument variable name (binary 0/1)
#' @param t character, treatment variable name (binary 0/1). Required for
#'   \code{est = "apr"}, \code{"lpr"}, and \code{"calc"}. Defaults to
#'   \code{NULL}.
#' @param x optional character, vector of covariates Defaults to \code{NULL}.
#'
#' @param data data.frame containing variables
#' @param ... additional arguments passed to downstream estimators
#'
#' @return An object of class depending on \code{est}:
#' \itemize{
#'   \item \code{"apr"}: APR estimation object
#'   \item \code{"lpr"}: LPR estimation object
#'   \item \code{"yz"}: reduced-form bound object
#'   \item \code{"calc"}: summary-statistics-based object
#' }
#'
#' @details
#' This function only performs:
#' \enumerate{
#'   \item input parsing
#'   \item method dispatch
#' }
#'
#'
#' @references Sung Jae Jun and Sokbae Lee (2023). Identifying the Effect of
#'   Persuasion. _Journal of Political Economy_, 131(8).
#'   <doi:10.1086/724114>
#'
#' @seealso \code{\link{aprlb}}, \code{\link{aprub}}, \code{\link{lpr4ytz}},
#'   \code{\link{calc4persuasio}}
#'
#' @examples
#' # Example 1: Average persuasion rate (APR) with normal inference
#' persuasio(
#'   est = "apr",
#'   y = "voteddem_all",
#'   t = "readsome",
#'   z = "post",
#'   level = 0.80,
#'   method = "normal",
#'   data = GKB
#' )
#'
#' # Example 2: Local persuasion rate (LPR) with normal inference
#' persuasio(
#'   est = "lpr",
#'   y = "voteddem_all",
#'   t = "readsome",
#'   z = "post",
#'   level = 0.80,
#'   method = "normal",
#'   data = GKB
#' )
#'
#' # Example 3: Outcome-instrument bounds with covariate and bootstrap inference
#' persuasio(
#'   est = "yz",
#'   y = "voteddem_all",
#'   z = "post",
#'   x = "MZwave2",
#'   level = 0.80,
#'   model = "interaction",
#'   method = "bootstrap",
#'   nboot = 1000,
#'   data = GKB
#' )
#'
#'
#' @export
persuasio <- function(est = c("apr", "lpr", "yz", "calc"),
                      y, z, t = NULL, x = NULL,
                      data,
                      ...) {

  est <- match.arg(est)

  # Enforce strict checks for missing mandatory arguments
  if (missing(y) || is.null(y)) {
    stop("Argument 'y' is required for all estimators.")
  }
  if (missing(z) || is.null(z)) {
    stop("Argument 'z' is required for all estimators.")
  }

  # Method-specific argument validation
  if (est %in% c("apr", "lpr", "calc") && is.null(t)) {
    stop("Argument 't' must be supplied for est = '", est, "'")
  }

  # Route to underlying functions
  switch(est,

    apr = {
      return(persuasio4ytz(
        data = data, y = y, t = t, z = z, x = x, ...
      ))
    },

    lpr = {
      return(persuasio4ytz2lpr(
        data = data, y = y, t = t, z = z, x = x, ...
      ))
    },

    yz = {
      return(persuasio4yz(
        data = data, y = y, z = z, x = x, ...
      ))
    },

    calc = {
      y1 <- mean(data[[y]][data[[z]] == 1], na.rm = TRUE)
      y0 <- mean(data[[y]][data[[z]] == 0], na.rm = TRUE)
      e1 <- mean(data[[t]][data[[z]] == 1], na.rm = TRUE)
      e0 <- mean(data[[t]][data[[z]] == 0], na.rm = TRUE)

      return(calc4persuasio(
        y1 = y1, y0 = y0, e1 = e1, e0 = e0
      ))
    }
  )

  stop("Invalid estimator type")
}
