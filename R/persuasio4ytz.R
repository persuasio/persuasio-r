#' @title Causal Inference on the Average Persuasion Rate
#'
#' @description Estimates the Average Persuasion Rate (APR) and constructs
#'   confidence intervals for binary outcome \code{y}, binary treatment
#'   \code{t}, and binary instrument \code{z}. Combines lower and upper bound
#'   estimation via \code{\link{aprlb}} and \code{\link{aprub}} with inference
#'   using either a Stoye (2009)-style asymptotic normal approximation or
#'   bootstrap resampling.
#'
#'   When covariates are absent, both inference methods are available. When
#'   covariates are present, \code{method = "bootstrap"} is recommended as
#'   standard errors are not available analytically.
#'
#' This function combines:
#' \itemize{
#'   \item lower bound estimation via \code{aprlb()}
#'   \item upper bound estimation via \code{aprub()}
#'   \item inference using either Stoye-style normal approximation or bootstrap
#' }
#'
#' @param y character, outcome variable name (binary 0/1)
#' @param t character, treatment variable name (binary 0/1)
#' @param z character, instrument variable name (binary 0/1)
#' @param x optional character, vector of covariates. Defaults to \code{NULL}.
#' @param level confidence level (default 0.95)
#' @param model model specification: \code{"no_interaction"} or
#'   \code{"interaction"}
#' @param method inference method: \code{"normal"} or \code{"bootstrap"}
#' @param nboot number of bootstrap replications (default 50)
#' @param data data.frame containing variables
#'
#' @return An object of class \code{persuasio4ytz} containing:
#' \describe{
#'   \item{lb_coef}{lower bound estimate}
#'   \item{ub_coef}{upper bound estimate}
#'   \item{ci_lb}{lower confidence bound}
#'   \item{ci_ub}{upper confidence bound}
#'   \item{level}{confidence level}
#'   \item{method}{inference method used}
#'   \item{n}{sample size}
#'   \item{outcome}{Y variable name}
#'   \item{treatment}{T variable name}
#'   \item{instrument}{Z variable name}
#'   \item{covariates}{covariates used}
#'   \item{model}{model specification}
#'   \item{nboot}{number of bootstrap draws (if applicable)}
#' }
#'
#' @details When \code{method = "normal"}, the function uses a Stoye
#' (2009)-style correction for partially identified parameters. Standard errors
#' from both \code{\link{aprlb}} and \code{\link{aprub}} are available only when
#' there are no covariates.
#'
#' When \code{method = "bootstrap"}, the function constructs confidence
#' intervals from empirical quantiles of bootstrap replicates of the bound
#' estimates. This is the recommended approach when covariates are present or
#' when the sample size is small.
#'
#' @references Sung Jae Jun and Sokbae Lee (2023). Identifying the Effect of
#'   Persuasion. _Journal of Political Economy_, 131(8).
#'   <doi:10.1086/724114>
#'
#' @seealso \code{\link{aprlb}}, \code{\link{aprub}}, \code{\link{lpr4ytz}},
#'   \code{\link{persuasio}}
#'
#' @examples
#' # Example 1: No covariates, normal inference
#' persuasio4ytz(
#'   y      = "voteddem_all",
#'   t      = "readsome",
#'   z      = "post",
#'   method = "normal",
#'   level  = 0.80,
#'   data   = GKB
#' )
#'
#' # Example 2: No covariates, bootstrap inference
#' persuasio4ytz(
#'   y      = "voteddem_all",
#'   t      = "readsome",
#'   z      = "post",
#'   method = "bootstrap",
#'   level  = 0.80,
#'   nboot  = 100,
#'   data   = GKB
#' )
#'
#' # Example 3: With covariate, interaction model, bootstrap inference
#' persuasio4ytz(
#'   y      = "voteddem_all",
#'   t      = "readsome",
#'   z      = "post",
#'   x      = "MZwave2",
#'   model  = "interaction",
#'   method = "bootstrap",
#'   level  = 0.80,
#'   nboot  = 100,
#'   data   = GKB
#' )
#'
#' @export
persuasio4ytz <- function(y, t, z, x = NULL,
                          model = "no_interaction",
                          method = "normal",
                          level = 0.95,
                          nboot = 50,
                          data) {

  method <- match.arg(method, c("normal", "bootstrap"))

  # core estimation
  lb <- aprlb(y = y, z = z, x = x, model = model, data = data)
  ub <- aprub(y = y, t = t, z = z, x = x, model = model, data = data)

  lb_coef <- lb$lb_coef
  ub_coef <- ub$ub_coef

  lb_se <- lb$lb_se
  ub_se <- ub$ub_se

  n <- nrow(data)

  alpha <- 1 - level

  # Case 1: Normal approximation (Stoye-style CI)
  if (method == "normal") {

    if (is.na(lb_se) || is.na(ub_se)) {
      stop("Normal approximation not available: lower-bound SE is NA (likely due to covariates). Use method='bootstrap'.")
    }

    cv1 <- qnorm(1 - alpha)
    cv2 <- qnorm(1 - alpha / 2)

    correction <- (ub_coef - lb_coef) / max(lb_se, ub_se)

    objective <- function(c) {
      abs(pnorm(c + correction) - pnorm(-c) - (1 - alpha))
    }

    cv_star <- optimize(objective, interval = c(cv1, cv2))$minimum

    ci_lb <- lb_coef - cv_star * lb_se
    ci_ub <- ub_coef + cv_star * ub_se

    res <- list(
      lb_coef = as.numeric(lb_coef),
      ub_coef = as.numeric(ub_coef),
      ci_lb = as.numeric(ci_lb),
      ci_ub = as.numeric(ci_ub),
      level = level,
      method = "normal",
      n = n,
      outcome = y,
      treatment = t,
      instrument = z,
      covariates = x,
      model = model
    )

    class(res) <- "persuasio4ytz"
    return(res)
  }

  # Case 2: Bootstrap — separate independent loops for lb and ub,
  # matching the Stata implementation which runs two independent
  # bootstrap calls (one for aprlb, one for aprub).
  if (method == "bootstrap") {

    lb_boot <- numeric(nboot)

    for (b in seq_len(nboot)) {
      idx <- sample(seq_len(n), size = n, replace = TRUE)
      d_b <- data[idx, , drop = FALSE]

      lb_b <- suppressWarnings(try(
        aprlb(y = y, z = z, x = x, model = model, data = d_b), silent = TRUE
      ))
      lb_boot[b] <- if (inherits(lb_b, "try-error")) NA else lb_b$lb_coef
    }

    ub_boot <- numeric(nboot)
    for (b in seq_len(nboot)) {
      idx <- sample(seq_len(n), size = n, replace = TRUE)
      d_b <- data[idx, , drop = FALSE]

      ub_b <- suppressWarnings(try(
        aprub(y = y, t = t, z = z, x = x, model = model, data = d_b), silent = TRUE
      ))
      ub_boot[b] <- if (inherits(ub_b, "try-error")) NA else ub_b$ub_coef
    }

    lb_boot <- lb_boot[!is.na(lb_boot)]
    ub_boot <- ub_boot[!is.na(ub_boot)]
    ci_lb <- quantile(lb_boot, probs = alpha)
    ci_ub <- quantile(ub_boot, probs = 1 - alpha)

    res <- list(
      lb_coef = lb_coef,
      ub_coef = ub_coef,
      ci_lb = ci_lb,
      ci_ub = ci_ub,
      level = level,
      method = "bootstrap",
      n = n,
      outcome = y,
      treatment = t,
      instrument = z,
      covariates = x,
      model = model,
      nboot = nboot
    )
  }

  class(res) <- "persuasio4ytz"
  return(res)
}
