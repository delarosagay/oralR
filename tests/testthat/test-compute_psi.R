test_that("compute_psi works for correct tooth-level input", {
  data <- tibble::tibble(
    patient_id = rep(1, 6),
    tooth      = c("16","15","14","24","25","26"),
    psi_code   = c(2,0,1,3,1,0)
  )

  result <- compute_psi(data)

  expect_equal(nrow(result), 1)
  expect_equal(result$patient_id, 1)
  expect_equal(result$psi, 3) # Should extract the maximum score
})

test_that("compute_psi works for correct sextant-level input", {
  data <- tibble::tibble(
    patient_id = rep(2, 6),
    sextant    = 1:6,
    psi_code   = c(2,1,0,3,2,0)
  )

  result <- compute_psi(data)

  expect_equal(nrow(result), 1)
  expect_equal(result$patient_id, 2)
  expect_equal(result$psi, 3) # Should extract the maximum score
})

test_that("compute_psi omits patients with duplicate teeth in tooth-level mode", {
  # Patient 10 has the tooth "16" duplicated
  data_dup_tooth <- tibble::tibble(
    patient_id = c(10, 10, 10),
    tooth      = c("16", "15", "16"), # Duplicate 16
    psi_code   = c(2, 1, 3)
  )

  expect_warning(
    result <- compute_psi(data_dup_tooth),
    "Duplicate teeth detected: 16"
  )
  expect_equal(nrow(result), 0)
})

test_that("compute_psi omits patients with duplicate sextants in sextant-level mode", {
  # Patient 11 has the sextant 3 duplicated
  data_dup_sextant <- tibble::tibble(
    patient_id = c(11, 11, 11),
    sextant    = c(1, 3, 3), # Duplicate 3
    psi_code   = c(2, 4, 1)
  )

  expect_warning(
    result <- compute_psi(data_dup_sextant),
    "Duplicate sextants detected: 3"
  )
  expect_equal(nrow(result), 0)
})

test_that("compute_psi omits patients with invalid tooth formats (no longer filters silently)", {
  data <- tibble::tibble(
    patient_id = c(3, 3),
    tooth      = c("UR1", "16"),
    psi_code   = c(2, 1)
  )

  expect_warning(
    result <- compute_psi(data),
    "Invalid FDI tooth numbers: UR1"
  )

  expect_equal(nrow(result), 0)
})

test_that("compute_psi omits patients with invalid psi_code values", {
  data <- tibble::tibble(
    patient_id = c(4, 4),
    tooth      = c("16", "15"),
    psi_code   = c(2.5, 7)
  )

  expect_warning(
    result <- compute_psi(data),
    "PSI values must be between 0 and 4"
  )

  expect_equal(nrow(result), 0)
})

test_that("compute_psi omits patients with out-of-range FDI numbers (e.g., temporary teeth or typos)", {
  data <- tibble::tibble(
    patient_id = c(5, 5),
    tooth      = c("9", "10"),
    psi_code   = c(1, 2)
  )

  expect_warning(
    result <- compute_psi(data),
    "Invalid FDI tooth numbers: 9, 10"
  )

  expect_equal(nrow(result), 0)
})

test_that("compute_psi handles mixed dataset correctly according to strict criteria", {
  # In a multi-patient dataset, only completely valid patients (1 and 2) should be processed
  data <- tibble::tibble(
    patient_id = c(
      rep(1, 6),   # Valid teeth input
      rep(2, 6),   # Valid sextants input
      rep(3, 2),   # Contains "UR1": Omission for Patient 3
      rep(4, 2),   # Out-of-bounds psi_code: Omission for Patient 4
      rep(5, 2),   # Non-permanent FDI digits: Omission for Patient 5
      rep(6, 3),   # Duplicate teeth: Omission for Patient 6
      rep(7, 3)    # Duplicate sextants: Omission for Patient 7
    ),

    tooth = c(
      "16","15","14","24","25","26",
      rep(NA, 6),
      "UR1","16",
      "16","15",
      "9","10",
      "11","12","11", # Duplicate 11
      rep(NA, 3)
    ),

    sextant = c(
      rep(NA, 6),
      1:6,
      NA, NA,
      NA, NA,
      NA, NA,
      rep(NA, 3),
      1, 2, 1 # Duplicate 1
    ),

    psi_code = c(
      2,0,1,3,1,0,
      2,1,0,3,2,0,
      2,1,
      2.5,7,
      1,2,
      1,2,3,
      0,4,2
    )
  )

  expect_warning(
    result <- compute_psi(data),
    "Some patients were omitted"
  )

  # Only patients 1 and 2 are free of data entries anomalies
  expect_equal(nrow(result), 2)
  expect_setequal(result$patient_id, c(1, 2))

  expect_equal(result$psi[result$patient_id == 1], 3)
  expect_equal(result$psi[result$patient_id == 2], 3)
})
