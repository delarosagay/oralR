test_that("normalize_def_format converts status format correctly (case-insensitive)", {

  df <- tibble::tibble(
    patient_id = 1,
    tooth = c("51", "52", "53", "54"),
    status = c("d", "E", "f", "s")   # mix of lowercase and uppercase
  )

  out <- normalize_def_format(df)

  expect_equal(out$D, c(1, 0, 0, 0))
  expect_equal(out$E, c(0, 1, 0, 0))
  expect_equal(out$F, c(0, 0, 1, 0))
})



test_that("normalize_def_format keeps binary format unchanged", {

  df <- tibble::tibble(
    patient_id = 1,
    tooth = c("51", "52", "53"),
    D = c(1, 0, 0),
    E = c(0, 1, 0),
    F = c(0, 0, 1)
  )

  out <- normalize_def_format(df)

  expect_equal(out$D, df$D)
  expect_equal(out$E, df$E)
  expect_equal(out$F, df$F)
})


test_that("normalize_def_format errors when both systems are present", {

  df <- tibble::tibble(
    patient_id = 1,
    tooth = "51",
    status = "D",
    D = 1, E = 0, F = 0
  )

  expect_error(
    normalize_def_format(df),
    "cannot contain both"
  )
})


test_that("normalize_def_format errors when no valid system is present", {

  df <- tibble::tibble(
    patient_id = 1,
    tooth = "51"
  )

  expect_error(
    normalize_def_format(df),
    "either D/E/F columns or a 'status' column"
  )
})


test_that("normalize_def_format rejects invalid status codes", {

  df <- tibble::tibble(
    patient_id = 1,
    tooth = "51",
    status = "X"
  )

  expect_error(
    normalize_def_format(df),
    "Invalid status codes"
  )
})


test_that("normalize_def_format enforces exclusivity in binary format", {

  df <- tibble::tibble(
    patient_id = 1,
    tooth = "51",
    D = 1, E = 1, F = 0
  )

  expect_error(
    normalize_def_format(df),
    "mutually exclusive"
  )
})


test_that("normalize_def_format rejects non-binary values in D/E/F", {

  df <- tibble::tibble(
    patient_id = 1,
    tooth = "51",
    D = 2, E = 0, F = 0
  )

  expect_error(
    normalize_def_format(df),
    "must contain only 0, 1, or NA"
  )
})


test_that("normalize_def_format returns correct columns", {

  df <- tibble::tibble(
    patient_id = 1,
    tooth = "51",
    status = "D"
  )

  out <- normalize_def_format(df)

  expect_named(out, c("patient_id", "tooth", "D", "E", "F"))
})
