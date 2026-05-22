#' Prevalence Analysis for Binary Clinical Indicators
#'
#' Computes prevalence and confidence intervals for any binary clinical
#' indicator. The function is general-purpose and can be applied to any
#' logical or 0/1-coded numeric vector.
#'
#' @param x A logical or numeric vector representing presence/absence.
#' @param na.rm Logical; whether to remove NA values before analysis
#'   (default = TRUE).
#' @param conf_level Numeric; the confidence level for the interval
#'   (default = 0.95).
#'
#' @return A tibble with n, n_positive, prevalence, ci_low, and ci_high.
#' @export
analyze_prevalence <- function(x, na.rm = TRUE, conf_level = 0.95) {

  # 1. First, convert to logical to handle characters/factors consistently
  # Any non-logical/non-numeric string will become NA here
  x_bool <- as.logical(x)

  # 2. Handle missing values from the resulting logical vector
  if (na.rm) {
    x_bool <- x_bool[!is.na(x_bool)]
  }

  n <- length(x_bool)

  # 3. Return empty structure if no valid data remains
  if (n == 0) {
    return(tibble::tibble(
      n = 0,
      n_positive = NA_integer_,
      prevalence = NA_real_,
      ci_low = NA_real_,
      ci_high = NA_real_
    ))
  }

  # 4. Basic counts
  n_pos <- sum(x_bool) # No na.rm needed here: cleaned above
  p <- n_pos / n

  # 5. Wilson Score Interval calculation
  alpha <- 1 - conf_level
  z <- stats::qnorm(1 - alpha / 2)

  denom <- 1 + (z^2 / n)
  centre <- p + (z^2 / (2 * n))
  adj <- z * sqrt((p * (1 - p) + z^2 / (4 * n)) / n)

  ci_low <- max(0, (centre - adj) / denom)
  ci_high <- min(1, (centre + adj) / denom)

  tibble::tibble(
    n = n,
    n_positive = n_pos,
    prevalence = p,
    ci_low = ci_low,
    ci_high = ci_high
  )
}
