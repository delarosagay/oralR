test_that("compute_dmft returns correct DMFT for a valid complete dentition", {

  df <- tibble::tribble(
    ~patient_id, ~tooth, ~D, ~M, ~F,

    # Upper right (11–17)
    1, "11", 1, 0, 0,
    1, "12", 0, 0, 0,
    1, "13", 0, 0, 0,
    1, "14", 0, 0, 0,
    1, "15", 0, 0, 0,
    1, "16", 0, 0, 1,
    1, "17", 0, 0, 0,

    # Upper left (21–27)
    1, "21", 0, 0, 0,
    1, "22", 0, 0, 0,
    1, "23", 0, 0, 0,
    1, "24", 0, 0, 0,
    1, "25", 0, 0, 0,
    1, "26", 0, 1, 0,
    1, "27", 0, 0, 0,

    # Lower left (31–37)
    1, "31", 0, 0, 0,
    1, "32", 0, 0, 0,
    1, "33", 0, 0, 0,
    1, "34", 0, 0, 0,
    1, "35", 0, 0, 0,
    1, "36", 0, 0, 0,
    1, "37", 0, 0, 0,

    # Lower right (41–47)
    1, "41", 0, 0, 0,
    1, "42", 0, 0, 0,
    1, "43", 0, 0, 0,
    1, "44", 0, 0, 0,
    1, "45", 0, 0, 0,
    1, "46", 0, 0, 0,
    1, "47", 0, 0, 0
  )

  result <- compute_dmft(df)
  expect_equal(nrow(result), 1)
  expect_equal(result$dmft, 3)
})


test_that("compute_dmft omits patients with primary teeth", {

  df <- tibble::tibble(
    patient_id = 1,
    tooth = "51",  # primary tooth
    D = 1, M = 0, F = 0
  )

  expect_warning(result <- compute_dmft(df), "Primary teeth detected")
  expect_equal(nrow(result), 0)
})


test_that("compute_dmft omits patients with invalid FDI codes", {

  df <- tibble::tibble(
    patient_id = 1,
    tooth = "99",  # invalid
    D = 0, M = 0, F = 1
  )

  expect_warning(result <- compute_dmft(df), "Invalid permanent FDI")
  expect_equal(nrow(result), 0)
})


test_that("compute_dmft omits patients with incomplete dentition", {

  df <- tibble::tibble(
    patient_id = 1,
    tooth = c("11", "12", "13"),  # missing many required teeth
    D = 0, M = 0, F = 0
  )

  expect_warning(result <- compute_dmft(df), "Incomplete permanent dentition")
  expect_equal(nrow(result), 0)
})


test_that("compute_dmft enforces exclusivity of D/M/F", {

  # Build a complete dentition for patient 1
  teeth <- c(as.character(11:17), as.character(21:27),
             as.character(31:37), as.character(41:47))

  df <- tibble::tibble(
    patient_id = 1,
    tooth = teeth,
    D = 0,
    M = 0,
    F = 0
  )

  # Introduce an exclusivity violation in one tooth
  df$D[df$tooth == "11"] <- 1
  df$M[df$tooth == "11"] <- 1   # invalid: D and M simultaneously

  expect_warning(result <- compute_dmft(df), "mutually exclusive")
  expect_equal(nrow(result), 0)
})


test_that("compute_dmft omits patients with duplicate teeth", {

  # Build a complete dentition but append a duplicate "11" at the end
  teeth_with_duplicate <- c(
    as.character(11:17), as.character(21:27),
    as.character(31:37), as.character(41:47),
    "11" # Duplicate record
  )

  df <- tibble::tibble(
    patient_id = 1,
    tooth = teeth_with_duplicate,
    D = 0, M = 0, F = 0
  )

  expect_warning(result <- compute_dmft(df), "Duplicate teeth detected")
  expect_equal(nrow(result), 0)
})


test_that("compute_dmft handles mixed patient quality correctly", {

  df <- tibble::tribble(
    # Patient 1: incomplete dentition → invalid
    ~patient_id, ~tooth, ~D, ~M, ~F,
    1, "11", 0, 0, 0,
    1, "12", 0, 0, 0,

    # Patient 2: complete dentition → valid
    2, "11", 1, 0, 0,
    2, "12", 0, 0, 0,
    2, "13", 0, 0, 0,
    2, "14", 0, 0, 0,
    2, "15", 0, 0, 0,
    2, "16", 0, 0, 1,
    2, "17", 0, 0, 0,

    2, "21", 0, 0, 0,
    2, "22", 0, 0, 0,
    2, "23", 0, 0, 0,
    2, "24", 0, 0, 0,
    2, "25", 0, 0, 0,
    2, "26", 0, 1, 0,
    2, "27", 0, 0, 0,

    2, "31", 0, 0, 0,
    2, "32", 0, 0, 0,
    2, "33", 0, 0, 0,
    2, "34", 0, 0, 0,
    2, "35", 0, 0, 0,
    2, "36", 0, 0, 0,
    2, "37", 0, 0, 0,

    2, "41", 0, 0, 0,
    2, "42", 0, 0, 0,
    2, "43", 0, 0, 0,
    2, "44", 0, 0, 0,
    2, "45", 0, 0, 0,
    2, "46", 0, 0, 0,
    2, "47", 0, 0, 0
  )

  expect_warning(result <- compute_dmft(df), "Some patients were omitted")
  expect_equal(nrow(result), 1)
  expect_equal(result$patient_id, 2)
  expect_equal(result$dmft, 3)
})

