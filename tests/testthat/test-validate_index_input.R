test_that("validate_index_input checks required columns", {
  data <- tibble::tibble(
    patient_id = 1,
    tooth = "11",
    tooth_side = "M",
    bop = 1
  )

  # Missing value column for PCR (it expects 'plaque' or 'value')
  expect_error(
    validate_index_input(data, "PCR"),
    "Missing required columns"
  )
})

test_that("validate_index_input validates tooth_side for each index", {
  data_bop <- tibble::tibble(
    patient_id = 1,
    tooth = "11",
    tooth_side = "X", # Invalid side
    bop = 1
  )

  expect_error(
    validate_index_input(data_bop, "BOP"),
    "Invalid tooth_side"
  )

  data_pcr_invalid <- tibble::tibble(
    patient_id = 1,
    tooth = "11",
    tooth_side = "ZZZ", # Invalid side
    plaque = 1
  )

  expect_error(
    validate_index_input(data_pcr_invalid, "PCR"),
    "Invalid tooth_side"
  )
})

test_that("validate_index_input accepts synonyms and case-insensitive sides", {
  data_synonyms <- tibble::tibble(
    patient_id = c(1, 1, 1),
    tooth = c("11", "12", "13"), # Different teeth to avoid duplicates
    tooth_side = c("v", "p", "mb"),
    bop = c(1, 0, 1)
  )

  expect_silent(validate_index_input(data_synonyms, "BOP"))
})

test_that("validate_index_input detects duplicate tooth surfaces (including synonyms)", {
  # Case 1: Pure duplication of the same side
  data_dup_pure <- tibble::tibble(
    patient_id = c(1, 1),
    tooth = c("11", "11"),
    tooth_side = c("M", "M"),
    bop = c(1, 0)
  )

  expect_error(
    validate_index_input(data_dup_pure, "BOP"),
    "Duplicate tooth surfaces detected"
  )

  # Case 2: Duplication hidden behind synonyms (V and B normalize to the same side)
  data_dup_synonym <- tibble::tibble(
    patient_id = c(1, 1),
    tooth = c("11", "11"),
    tooth_side = c("V", "B"), # Both will become 'B'
    bop = c(1, 1)
  )

  expect_error(
    validate_index_input(data_dup_synonym, "BOP"),
    "Duplicate tooth surfaces detected"
  )
})

test_that("validate_index_input validates BOP values globally", {
  data <- tibble::tibble(
    patient_id = 1,
    tooth = "11",
    tooth_side = "MB",
    bop = 2 # Invalid binary
  )

  expect_error(
    validate_index_input(data, "BOP"),
    "BOP values must be binary"
  )
})

test_that("validate_index_input validates PCR values globally", {
  data <- tibble::tibble(
    patient_id = 1,
    tooth = "11",
    tooth_side = "M",
    plaque = 5 # Invalid binary
  )

  expect_error(
    validate_index_input(data, "PCR"),
    "PCR values must be binary"
  )
})

test_that("validate_index_input validates PI values globally", {
  data_invalid <- tibble::tibble(
    patient_id = 1,
    tooth = "11",
    tooth_side = "M",
    plaque = 99 # Invalid range
  )

  expect_error(
    validate_index_input(data_invalid, "PI"),
    "PI values must be integers between 0 and 3"
  )

  data_valid <- tibble::tibble(
    patient_id = 1,
    tooth = "11",
    tooth_side = "M",
    plaque = 3
  )
  expect_silent(validate_index_input(data_valid, "PI"))
})

test_that("validate_index_input accepts 'value' column from tidy_dental", {
  data_tidy <- tibble::tibble(
    patient_id = 1,
    tooth = "11",
    tooth_side = "M",
    value = 1 # value: generic name from tidy_dental
  )
  expect_silent(validate_index_input(data_tidy, "BOP"))
})

test_that("validate_index_input accepts correct inputs silently", {
  # BOP correct
  data_bop <- tibble::tibble(
    patient_id = 1,
    tooth = "16",
    tooth_side = "MB",
    bop = 1
  )
  expect_silent(validate_index_input(data_bop, "BOP"))

  # PCR correct
  data_pcr <- tibble::tibble(
    patient_id = 1,
    tooth = "11",
    tooth_side = "M",
    plaque = 0
  )
  expect_silent(validate_index_input(data_pcr, "PCR"))

  # PI correct
  data_pi <- tibble::tibble(
    patient_id = 1,
    tooth = "46",
    tooth_side = "D",
    plaque = 2
  )
  expect_silent(validate_index_input(data_pi, "PI"))
})
