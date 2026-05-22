test_that("compute_icon calculates correctly for pre and post timepoints", {
  data <- tibble::tibble(
    patient_id = "P1",
    time = c("pre", "post"),
    aesthetic_component = c(8, 2),
    upper_crowding_mm = c(10, 0),
    upper_spacing_mm = c(0, 0),
    crossbite = c(FALSE, FALSE),
    incisor_openbite_mm = c(0, 0),
    incisor_overbite_category = c(2, 0),
    buccal_ap_left = c(1, 0),
    buccal_ap_right = c(1, 0)
  )

  result <- compute_icon(data, .on_error = "stop")

  # Pre: (7*8) + (5*0) + (5*3) + (4*2) + (3*2) = 56 + 0 + 15 + 8 + 6 = 85
  # Post: (7*2) + (5*0) + (5*0) + (4*0) + (3*0) = 14
  # Improvement: 85 - (4 * 14) = 85 - 56 = 29
  expect_equal(result$icon_pre, 85)
  expect_equal(result$icon_post, 14)
  expect_equal(result$icon_improvement, 29)

  # Check categorical factors match Daniels & Richmond classifications
  expect_equal(as.character(result$complexity_grade), "Very difficult")
  expect_equal(as.character(result$improvement_grade), "Greatly improved")
})


test_that("compute_icon handles missing timepoints safely", {
  data <- tibble::tibble(
    patient_id = "P2",
    time = "pre",
    aesthetic_component = 5,
    upper_crowding_mm = 0, upper_spacing_mm = 0,
    crossbite = FALSE, incisor_openbite_mm = 0,
    incisor_overbite_category = 0, buccal_ap_left = 0,
    buccal_ap_right = 0
  )

  result <- compute_icon(data, .on_error = "stop")

  expect_true(is.na(result$icon_post))
  expect_true(is.na(result$icon_improvement))
  expect_s3_class(result$complexity_grade, "factor")
})

test_that("compute_icon catches longitudinal duplicates based on .on_error policy", {
  # Patient 'D1' has two 'pre' entries, which is a structural database error
  bad_data <- tibble::tibble(
    patient_id = c("D1", "D1"),
    time = c("pre", "pre"),
    aesthetic_component = c(5, 6),
    upper_crowding_mm = c(3, 3),
    upper_spacing_mm = c(0, 0),
    crossbite = c(FALSE, FALSE),
    incisor_openbite_mm = c(0, 0),
    incisor_overbite_category = c(1, 1),
    buccal_ap_left = c(0, 0),
    buccal_ap_right = c(0, 0)
  )

  # Scenario A: .on_error = "stop" should halt execution with a specific message
  expect_error(
    compute_icon(bad_data, .on_error = "stop"),
    "Duplicate entries found"
  )

  # Scenario B: .on_error = "collect" should log the problem in the errors data frame
  result_collected <- compute_icon(bad_data, .on_error = "collect")

  expect_type(result_collected, "list")
  expect_true("errors" %in% names(result_collected))
  expect_equal(nrow(result_collected$errors), 1)
  expect_equal(result_collected$errors$patient_id, "D1")
})
