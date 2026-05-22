test_that("compute_pi works for a fully correct patient", {
  data <- tibble::tibble(
    patient_id = rep(1, 4),
    tooth = rep("11", 4),
    tooth_side = c("M", "D", "B", "L"),
    plaque = c(0, 1, 2, 3) # Scores 0-3
  )

  result <- compute_pi(data)

  expect_equal(nrow(result), 1)
  expect_equal(result$total_sites, 4)
  expect_equal(result$total_score, 6)   # 0 + 1 + 2 + 3
  expect_equal(result$pi_index, 1.5)    # 6 / 4
})

test_that("patients with invalid PI values (e.g. 4) are handled by validation", {
  data <- tibble::tibble(
    patient_id = rep(1, 4),
    tooth = rep("11", 4),
    tooth_side = c("M", "D", "B", "L"),
    plaque = c(0, 1, 2, 4) # 4 is invalid for PI
  )

  # validate_index_input will stop() if it finds a 4 for PI
  expect_error(compute_pi(data))
})

test_that("patients with incorrect number of sites are omitted", {
  data <- tibble::tibble(
    patient_id = c(rep(1, 4), rep(2, 2)),
    tooth = c(rep("11", 4), rep("12", 2)),
    tooth_side = c("M","D","B","L", "M","D"),
    plaque = 1
  )

  expect_warning(result <- compute_pi(data), "must be 4")
  expect_equal(nrow(result), 1)
  expect_equal(result$patient_id, 1)
  expect_equal(result$total_sites, 4)
})

test_that("mixed dataset: PI correctly calculates means and handles columns", {
  data <- tibble::tibble(
    patient_id = c(rep(1, 4), rep(2, 4)),
    tooth = c(rep("11", 4), rep("21", 4)),
    tooth_side = rep(c("M", "D", "B", "L"), 2),
    plaque = c(0,0,0,0, 3,3,3,3)
  )

  result <- compute_pi(data)

  expect_equal(result$pi_index[result$patient_id == 1], 0)
  expect_equal(result$total_score[result$patient_id == 1], 0)

  expect_equal(result$pi_index[result$patient_id == 2], 3)
  expect_equal(result$total_score[result$patient_id == 2], 12)
})

test_that("returns an empty tibble with correct structure when all patients are omitted", {
  # Dataset where the only patient has an incorrect site count
  data <- tibble::tibble(
    patient_id = rep(1, 2),
    tooth = rep("11", 2),
    tooth_side = c("M", "D"),
    plaque = c(1, 2)
  )

  expect_warning(result <- compute_pi(data), "must be 4")

  expect_equal(nrow(result), 0)
  expect_named(result, c("patient_id", "total_sites", "total_score", "pi_index"))
  expect_type(result$total_sites, "integer")
  expect_type(result$total_score, "double") # Verifies numeric type preservation
})
