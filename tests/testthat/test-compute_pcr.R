test_that("compute_pcr works for a correct patient", {
  data <- tibble::tibble(
    patient_id = rep(1, 4),
    tooth = rep("11", 4),
    tooth_side = c("M", "D", "B", "L"),
    plaque = c(1, 0, 1, 0)
  )

  result <- compute_pcr(data)

  expect_equal(nrow(result), 1)
  expect_equal(result$patient_id, 1)
  expect_equal(result$total_points, 4)
  expect_equal(result$plaque_points, 2)
  expect_equal(result$pcr_percent, 50)
})

test_that("patients with alphanumeric notation are omitted", {
  data <- tibble::tibble(
    patient_id = c(rep(1, 4), rep(2, 4)),
    tooth = c(rep("11", 4), rep("UR1", 4)),
    tooth_side = rep(c("M", "D", "B", "L"), 2),
    plaque = rep(0, 8)
  )

  # warning
  expect_warning(
    result <- compute_pcr(data),
    "Invalid FDI tooth numbers"
  )

  expect_equal(nrow(result), 1)
  expect_equal(result$patient_id, 1)
})

test_that("patients with universal notation are omitted", {
  data <- tibble::tibble(
    patient_id = c(rep(1, 4), rep(2, 4)),
    tooth = c(rep("11", 4), rep("9", 4)),  # 9 is universal
    tooth_side = rep(c("M", "D", "B", "L"), 2),
    plaque = rep(0, 8)
  )

  expect_warning(
    result <- compute_pcr(data),
    "Invalid FDI tooth numbers"
  )

  expect_equal(nrow(result), 1)
  expect_equal(result$patient_id, 1)
})

test_that("patients with incorrect number of sites are omitted", {
  data <- tibble::tibble(
    patient_id = c(rep(1, 4), rep(2, 3)),
    tooth = c(rep("11", 4), rep("36", 3)),
    tooth_side = c(
      c("M", "D", "B", "L"),
      c("M", "D", "B")  # missing L
    ),
    plaque = rep(0, 7)
  )

  # warning: "must be 4"
  expect_warning(
    result <- compute_pcr(data),
    "must be 4"
  )

  expect_equal(nrow(result), 1)
  expect_equal(result$patient_id, 1)
})

test_that("mixed dataset: only correct patients are computed", {
  data <- tibble::tibble(
    patient_id = c(
      rep(1, 4),
      rep(2, 4),
      rep(3, 4),
      rep(4, 3)
    ),
    tooth = c(
      rep("11", 4),   # correct
      rep("UR1", 4),  # alphanumeric
      rep("9", 4),    # universal
      rep("36", 3)    # wrong sites, must be 4
    ),
    tooth_side = c(
      c("M", "D", "B", "L"),
      rep(c("M", "D", "B", "L"), 2),
      c("M", "D", "B")
    ),
    plaque = rep(0, 15)
  )

  expect_warning(
    result <- compute_pcr(data),
    "Some patients were omitted"
  )

  expect_equal(nrow(result), 1)
  expect_equal(result$patient_id, 1)
})

test_that("compute_pcr accepts primary teeth", {
  # Important test as PCR allows primary teeth (51-85)
  data <- tibble::tibble(
    patient_id = rep(10, 4),
    tooth = rep("55", 4), # FDI, primary upper right second molar
    tooth_side = c("M", "D", "B", "L"),
    plaque = c(1, 1, 0, 0)
  )

  expect_silent(result <- compute_pcr(data))
  expect_equal(nrow(result), 1)
  expect_equal(result$pcr_percent, 50)
})
