#' Descriptive statistics for clinical indices
#'
#' Computes standard descriptive statistics for any numeric clinical index
#' (e.g., BOP, PI, PCR, DMFT, DEF, ICON). Returns mean, median, SD, range,
#' percentiles, normality test, and outlier detection.
#'
#' @details
#' The function provides a summary of continuous or discrete
#' numeric variables. It includes a Shapiro-Wilk test for normality (performed
#' only when 3 <= n <= 5000 and variance > 0) and identifies outliers using
#' the Tukey's Interquartile Range (IQR) rule (1.5 * IQR).
#'
#' @param x A numeric or coercible to numeric vector (may contain NA).
#' @param na.rm Logical; whether to remove NA values before analysis
#'   (default = TRUE).
#'
#' @return A tibble with the following columns:
#' \itemize{
#'   \item \code{n} — total number of non-missing observations
#'   \item \code{mean} — arithmetic mean
#'   \item \code{median} — median value
#'   \item \code{sd} — standard deviation
#'   \item \code{min} — minimum value
#'   \item \code{max} — maximum value
#'   \item \code{p25} — 25th percentile (1st quartile)
#'   \item \code{p75} — 75th percentile (3rd quartile)
#'   \item \code{normality_p} — p-value from Shapiro-Wilk normality test
#'   \item \code{outliers} — unique outlier values as a comma-separated string
#' }
#'
#' @examples
#' analyze_descriptives(c(0, 2, 5, 1, 0, 4, 7, 0, 12, NA))
#' analyze_descriptives(c("10", "20", "30", "13", "21", "5"))
#'
#' @export
analyze_descriptives <- function(x, na.rm = TRUE) {

  # 1. Coerce input to numeric type safely
  x <- suppressWarnings(as.numeric(x))

  # 2. Handle missing values based on user preference
  if (na.rm) {
    x_clean <- x[!is.na(x)]
  } else {
    x_clean <- x
  }

  # 3. Defensive check for empty or completely missing inputs
  if (length(x_clean) == 0 || all(is.na(x_clean))) {
    return(tibble::tibble(
      n = 0,
      mean = NA_real_,
      median = NA_real_,
      sd = NA_real_,
      min = NA_real_,
      max = NA_real_,
      p25 = NA_real_,
      p75 = NA_real_,
      normality_p = NA_real_,
      outliers = NA_character_
    ))
  }

  # Count only valid, non-missing observations for the final summary
  n_clean <- sum(!is.na(x_clean))

  # 4. Normality testing via Shapiro-Wilk algorithm
  normality_p <- NA_real_

  # Run test only under valid conditions:
  # - Sample size (n) must be between 3 and 5000
  # - No internal missing values can be present if na.rm = FALSE
  if (n_clean >= 3 && n_clean <= 5000 && !any(is.na(x_clean))) {
    sd_val <- stats::sd(x_clean, na.rm = TRUE)
    # Ensure variance is not zero
    if (!is.na(sd_val) && sd_val > 0) {
      normality_p <- stats::shapiro.test(x_clean)$p.value
    }
  }


  # 5. Quantile estimation and outlier detection (Tukey's IQR rule)
  # If na.rm = FALSE and there are NAs, stats::quantile throws an error.
  # We protect against this by setting quantiles to NA manually in that case.
  if (!na.rm && any(is.na(x_clean))) {
    q1 <- NA_real_
    q3 <- NA_real_
    outliers_str <- NA_character_
  } else {
    q_stats <- stats::quantile(x_clean, probs = c(0.25, 0.75), na.rm = na.rm)
    q1 <- as.numeric(q_stats[1])
    q3 <- as.numeric(q_stats[2])

    # Compute standard fencing thresholds
    iqr <- q3 - q1
    lower_bound <- q1 - 1.5 * iqr
    upper_bound <- q3 + 1.5 * iqr

    # Filter outliers excluding any potential NA values
    outliers_vec <- x_clean[!is.na(x_clean) & (x_clean < lower_bound | x_clean > upper_bound)]

    if (length(outliers_vec) == 0) {
      outliers_str <- NA_character_
    } else {
      # Sort and remove duplicates for a clean, readable string output
      outliers_str <- paste(sort(unique(outliers_vec)), collapse = ", ")
    }
  }


  # 6. Construct and return the final summary tibble
  tibble::tibble(
    n           = n_clean,
    mean        = mean(x_clean, na.rm = na.rm),
    median      = stats::median(x_clean, na.rm = na.rm),
    sd          = stats::sd(x_clean, na.rm = na.rm),
    min         = min(x_clean, na.rm = na.rm),
    max         = max(x_clean, na.rm = na.rm),
    p25         = q1,
    p75         = q3,
    normality_p = normality_p,
    outliers    = outliers_str
  )
}
