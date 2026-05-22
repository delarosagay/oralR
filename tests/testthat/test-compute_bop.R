test_that("compute_bop works for a fully correct patient", {
  data <- tibble::tibble(
    patient_id = rep(1, 6),
    tooth = rep("11", 6),
    tooth_side = c("MB", "B", "DB", "ML", "L", "DL"),
    bop = c(1, 0, 1, 0, 0, 1)
  )

  result <- compute_bop(data)

  expect_equal(nrow(result), 1)
  expect_equal(result$patient_id, 1)
  expect_equal(result$total_points, 6)
  expect_equal(result$bleeding_points, 3)
  expect_equal(result$bop_percent, 50)
})

test_that("patients with invalid tooth notation or non-permanent teeth are omitted", {
  data <- tibble::tibble(
    patient_id = c(rep(1, 6), rep(2, 6)),
    tooth = c(rep("11", 6), rep("99", 6)), # 99 is invalid FDI
    tooth_side = rep(c("MB", "B", "DB", "ML", "L", "DL"), 2),
    bop = c(rep(1, 6), rep(0, 6))
  )

  # Match the new English warning message
  expect_warning(
    result <- compute_bop(data),
    "Invalid or non-permanent FDI teeth"
  )

  expect_equal(nrow(result), 1)
  expect_equal(result$patient_id, 1)
})

test_that("patients with incorrect number of sites are omitted", {
  data <- tibble::tibble(
    patient_id = c(rep(1, 6), rep(2, 5)),
    tooth = c(rep("11", 6), rep("36", 5)),
    tooth_side = c(
      c("MB", "B", "DB", "ML", "L", "DL"),
      c("MB", "B", "DB", "ML", "L") # missing DL
    ),
    bop = rep(0, 11)
  )

  expect_warning(
    result <- compute_bop(data),
    "must be 6"
  )

  expect_equal(nrow(result), 1)
  expect_equal(result$patient_id, 1)
})

test_that("patients with primary teeth are omitted", {
  data <- tibble::tibble(
    patient_id = rep(10, 6),
    tooth = rep("55", 6), # primary tooth
    tooth_side = c("MB", "B", "DB", "ML", "L", "DL"),
    bop = c(1, 0, 1, 0, 0, 1)
  )

  # Now this returns an empty tibble instead of stopping
  expect_warning(
    result <- compute_bop(data),
    "non-permanent FDI teeth"
  )

  expect_equal(nrow(result), 0)
})

test_that("mixed dataset: only correct patients are computed", {
  data <- tibble::tibble(
    patient_id = c(
      rep(1, 6), # correct
      rep(2, 6), # invalid notation
      rep(3, 5)  # wrong sites
    ),
    tooth = c(
      rep("11", 6),
      rep("UR1", 6),
      rep("36", 5)
    ),
    tooth_side = c(
      c("MB", "B", "DB", "ML", "L", "DL"),
      rep(c("MB", "B", "DB", "ML", "L", "DL"), 1),
      c("MB", "B", "DB", "ML", "L")
    ),
    bop = rep(0, 17)
  )

  expect_warning(
    result <- compute_bop(data),
    "Some patients were omitted"
  )

  expect_equal(nrow(result), 1)
  expect_equal(result$patient_id, 1)
})
