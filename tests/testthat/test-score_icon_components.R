test_that("score_icon_components calculates correct scores for a perfect case", {
  data <- tibble::tibble(
    patient_id = 1,
    time = "pre",
    aesthetic_component = 5,
    upper_crowding_mm = 10,       # Score 3 (range 9-13)
    upper_spacing_mm = 0,
    crossbite = FALSE,            # Score 0
    incisor_openbite_mm = 3,      # Score 3 (range 2-4)
    incisor_overbite_category = 1,# Score 1 -> Vertical = max(3,1) = 3
    buccal_ap_left = 1,
    buccal_ap_right = 1,          # Buccal AP = 1+1 = 2
    impacted_teeth = FALSE
  )

  result <- score_icon_components(data, .on_error = "stop")

  expect_equal(nrow(result), 1)
  expect_equal(result$upper_arch_crowding_score, 3)
  expect_equal(result$crossbite_score, 0)
  expect_equal(result$vertical_score, 3)
  expect_equal(result$buccal_ap_score, 2)
})

test_that("impacted_teeth forces crowding score to 5 regardless of mm", {
  data <- tibble::tibble(
    patient_id = 1,
    time = "pre",
    aesthetic_component = 5,
    upper_crowding_mm = 1,        # Normal score would be 0
    upper_spacing_mm = 0,
    crossbite = FALSE,
    incisor_openbite_mm = 0,
    incisor_overbite_category = 0,
    buccal_ap_left = 0,
    buccal_ap_right = 0,
    impacted_teeth = TRUE         # Should force 5
  )

  result <- score_icon_components(data, .on_error = "stop")
  expect_equal(result$upper_arch_crowding_score, 5)
})

test_that("validation stops on invalid aesthetic component range", {
  data <- tibble::tibble(
    patient_id = 1,
    time = "pre",
    aesthetic_component = 11,     # Invalid: max is 10
    upper_crowding_mm = 0,
    upper_spacing_mm = 0,
    crossbite = FALSE,
    incisor_openbite_mm = 0,
    incisor_overbite_category = 0,
    buccal_ap_left = 0,
    buccal_ap_right = 0
  )

  expect_error(score_icon_components(data, .on_error = "stop"))
})

test_that(".on_error = 'collect' returns scores and errors tibbles", {
  data <- tibble::tibble(
    patient_id = c(1, 2),
    time = c("pre", "pre"),
    aesthetic_component = c(5, 50), # 50 is invalid
    upper_crowding_mm = c(0, 0),
    upper_spacing_mm = c(0, 0),
    crossbite = c(FALSE, FALSE),
    incisor_openbite_mm = c(0, 0),
    incisor_overbite_category = c(0, 0),
    buccal_ap_left = c(0, 0),
    buccal_ap_right = c(0, 0)
  )

  result_list <- score_icon_components(data, .on_error = "collect")

  expect_equal(nrow(result_list$scores), 1)
  expect_equal(nrow(result_list$errors), 1)
  expect_equal(result_list$errors$patient_id, 2)
  expect_match(result_list$errors$error, "aesthetic_component")
})

test_that("coercion of character logicals works with .warn = TRUE", {
  data <- tibble::tibble(
    patient_id = 1,
    time = "pre",
    aesthetic_component = 5,
    upper_crowding_mm = 0,
    upper_spacing_mm = 0,
    crossbite = "yes",            # Should be coerced to TRUE
    incisor_openbite_mm = 0,
    incisor_overbite_category = 0,
    buccal_ap_left = 0,
    buccal_ap_right = 0
  )

  expect_warning(
    result <- score_icon_components(data, .on_error = "stop", .warn = TRUE),
    "coerced to logical"
  )
  expect_equal(result$crossbite_score, 1)
})
