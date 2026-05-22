test_that("normalize_dmft_format converts status format correctly (case-insensitive)", {

  df <- tibble::tibble(
    patient_id = 1,
    tooth = c("11", "12", "13", "14"),
    status = c("d", "M", "f", "s")   # mix of lowercase and uppercase
  )

  out <- normalize_dmft_format(df)

  expect_equal(out$D, c(1, 0, 0, 0))
  expect_equal(out$M, c(0, 1, 0, 0))
  expect_equal(out$F, c(0, 0, 1, 0))
})



test_that("normalize_dmft_format keeps binary format unchanged", {

  df <- tibble::tibble(
    patient_id = 1,
    tooth = c("11", "12", "13"),
    D = c(1, 0, 0),
    M = c(0, 1, 0),
    F = c(0, 0, 1)
  )

  out <- normalize_dmft_format(df)

  expect_equal(out$D, df$D)
  expect_equal(out$M, df$M)
  expect_equal(out$F, df$F)
})


test_that("normalize_dmft_format errors when both systems are present", {

  df <- tibble::tibble(
    patient_id = 1,
    tooth = "11",
    status = "D",
    D = 1, M = 0, F = 0
  )

  expect_error(
    normalize_dmft_format(df),
    "cannot contain both"
  )
})


test_that("normalize_dmft_format errors when no valid system is present", {

  df <- tibble::tibble(
    patient_id = 1,
    tooth = "11"
  )

  expect_error(
    normalize_dmft_format(df),
    "must contain either"
  )
})


test_that("normalize_dmft_format rejects invalid status codes", {

  df <- tibble::tibble(
    patient_id = 1,
    tooth = "11",
    status = "X"
  )

  expect_error(
    normalize_dmft_format(df),
    "Invalid status codes"
  )
})


test_that("normalize_dmft_format enforces exclusivity in binary format", {

  df <- tibble::tibble(
    patient_id = 1,
    tooth = "11",
    D = 1, M = 1, F = 0
  )

  expect_error(
    normalize_dmft_format(df),
    "mutually exclusive"
  )
})


test_that("normalize_dmft_format rejects non-binary values in D/M/F", {

  df <- tibble::tibble(
    patient_id = 1,
    tooth = "11",
    D = 2, M = 0, F = 0
  )

  expect_error(
    normalize_dmft_format(df),
    "must contain only 0, 1, or NA"
  )
})
