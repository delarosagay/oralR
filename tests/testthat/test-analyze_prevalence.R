test_that("analyze_prevalence works with simple TRUE/FALSE input", {
  x <- c(TRUE, TRUE, FALSE, TRUE, FALSE, TRUE)
  res <- analyze_prevalence(x)

  expect_s3_class(res, "tbl_df")
  expect_equal(res$n, 6)
  expect_equal(res$n_positive, 4)
  expect_equal(res$prevalence, 4/6)
  expect_true(res$ci_low < res$prevalence)
  expect_true(res$ci_high > res$prevalence)
})

test_that("analyze_prevalence handles NA values correctly", {
  x <- c(TRUE, FALSE, TRUE, NA, TRUE)
  res <- analyze_prevalence(x)

  expect_equal(res$n, 4)
  expect_equal(res$n_positive, 3)
  expect_equal(res$prevalence, 3/4)
})

test_that("analyze_prevalence works with numeric 0/1 input", {
  x <- c(1, 0, 1, 1, 0)
  res <- analyze_prevalence(x)

  expect_equal(res$n, 5)
  expect_equal(res$n_positive, 3)
  expect_equal(res$prevalence, 3/5)
})

test_that("analyze_prevalence treats any non-zero numeric as TRUE", {
  # Note: as.logical() in R converts any non-zero number to TRUE
  x <- c(2, 5, 0, -3, 0)
  res <- analyze_prevalence(x)

  expect_equal(res$n_positive, 3)
  expect_equal(res$prevalence, 3/5)
})

test_that("analyze_prevalence returns NA summary when all values are NA", {
  x <- c(NA, NA, NA)
  res <- analyze_prevalence(x)

  expect_equal(res$n, 0)
  expect_true(is.na(res$n_positive))
  expect_true(is.na(res$prevalence))
})

test_that("analyze_prevalence handles non-logical/non-numeric input safely", {
  # We use as.logical(), which converts any strings other than "T/F/TRUE/FALSE" to NA
  x <- c("a", "b", "c")
  res <- analyze_prevalence(x)

  expect_equal(res$n, 0)
  expect_true(is.na(res$prevalence))
})

test_that("confidence interval is within valid bounds and precise", {
  # Bound checking for 100% prevalence case
  x <- c(rep(TRUE, 10), rep(FALSE, 0))
  res <- analyze_prevalence(x)

  expect_lte(res$ci_high, 1)
  expect_gte(res$ci_low, 0)

  # Check conf_level argument consistency
  res_99 <- analyze_prevalence(c(TRUE, FALSE), conf_level = 0.99)
  res_95 <- analyze_prevalence(c(TRUE, FALSE), conf_level = 0.95)

  # A 99% CI must be wider than a 95% CI
  expect_true((res_99$ci_high - res_99$ci_low) > (res_95$ci_high - res_95$ci_low))
})
