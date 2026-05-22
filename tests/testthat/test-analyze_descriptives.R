test_that("analyze_descriptives returns correct basic statistics", {
  x <- c(10, 20, 30, 40, 50)
  res <- analyze_descriptives(x)

  expect_s3_class(res, "tbl_df")
  expect_equal(res$n, 5)
  expect_equal(res$mean, mean(x))
  expect_equal(res$median, median(x))
  expect_equal(res$sd, sd(x))
  expect_equal(res$min, min(x))
  expect_equal(res$max, max(x))
  # Use as.numeric to avoid conflicts with quantile names
  expect_equal(res$p25, as.numeric(quantile(x, 0.25)))
  expect_equal(res$p75, as.numeric(quantile(x, 0.75)))
})

test_that("analyze_descriptives handles NA values correctly", {
  x <- c(10, 20, NA, 40)
  res <- analyze_descriptives(x)

  expect_equal(res$n, 3)
  expect_equal(res$mean, mean(c(10, 20, 40)))
  expect_equal(res$median, median(c(10, 20, 40)))
})

test_that("analyze_descriptives returns NA summary when all values are NA", {
  x <- c(NA, NA, NA)
  res <- analyze_descriptives(x)

  expect_equal(res$n, 0)
  expect_true(all(is.na(res[, -1]))) # Check that all columns except 'n' are NA
})

test_that("analyze_descriptives coerces non-numeric input to numeric", {
  x <- c("10", "20", "30")
  res <- analyze_descriptives(x)

  expect_equal(res$n, 3)
  expect_equal(res$mean, 20)
})

test_that("normality test is computed only when valid (n >= 3 and variance > 0)", {
  # Case n < 3
  res_small <- analyze_descriptives(c(10, 20))
  expect_true(is.na(res_small$normality_p))

  # Case zero variance (all values identical)
  res_zero_var <- analyze_descriptives(c(10, 10, 10, 10))
  expect_true(is.na(res_zero_var$normality_p))

  # Valid case
  res_valid <- analyze_descriptives(c(10, 20, 32, 45, 12))
  expect_false(is.na(res_valid$normality_p))
})

test_that("outlier detection works and uses unique values", {
  # Use a sufficient sample size to ensure 500 is detected as an outlier
  x <- c(10, 11, 12, 10, 11, 12, 10, 11, 12, 500, 500)
  res <- analyze_descriptives(x)

  expect_true(grepl("500", res$outliers))
  # Result should be "500" (not repeated due to unique())
  expect_equal(res$outliers, "500")
})

test_that("outliers is NA when no outliers exist", {
  x <- c(10, 11, 10, 11, 10, 11)
  res <- analyze_descriptives(x)

  expect_true(is.na(res$outliers))
})

test_that("output is always a single-row tibble", {
  x <- c(1, 2, 3, 4)
  res <- analyze_descriptives(x)

  expect_equal(nrow(res), 1)
  expect_s3_class(res, "tbl_df")
})

test_that("analyze_descriptives handles na.rm = FALSE correctly", {
  # When na.rm = FALSE and there are NAs, most stats should be NA,
  # but n should still count the valid ones, and the function shouldn't crash.
  x <- c(10, 20, NA, 40)
  res <- analyze_descriptives(x, na.rm = FALSE)

  expect_equal(res$n, 3)
  expect_true(is.na(res$mean))
  expect_true(is.na(res$median))
  expect_true(is.na(res$sd))
  expect_true(is.na(res$normality_p))
})

test_that("normality test is skipped and returns NA if n > 5000", {
  # Test the upper bound constraint for Shapiro-Wilk (n <= 5000)
  # Generating 5001 random normal values
  x_huge <- rnorm(5001)
  res_huge <- analyze_descriptives(x_huge)

  expect_equal(res_huge$n, 5001)
  expect_true(is.na(res_huge$normality_p))
})
