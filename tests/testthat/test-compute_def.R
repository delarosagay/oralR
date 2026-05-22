test_that("compute_def computes correct def values for valid primary dentition", {

  df <- tibble::tibble(
    patient_id = 1,
    tooth = as.character(c(51:55, 61:65, 71:75, 81:85)),
    D = c(rep(1, 5), rep(0, 15)),
    E = 0,
    F = 0
  )

  out <- compute_def(df)

  expect_equal(nrow(out), 1)
  expect_equal(out$def, 5)
})


test_that("compute_def omits patients with permanent teeth", {

  df <- tibble::tibble(
    patient_id = 1,
    tooth = c("51", "52", "11"),  # 11 is permanent
    D = 1, E = 0, F = 0
  )

  expect_warning(
    out <- compute_def(df),
    "Permanent teeth detected"
  )

  expect_equal(nrow(out), 0)
})


test_that("compute_def omits patients with non-FDI primary notation", {

  df <- tibble::tibble(
    patient_id = 1,
    tooth = c("A", "B", "C"),  # Universal primary
    D = 1, E = 0, F = 0
  )

  expect_warning(
    out <- compute_def(df),
    "Non-FDI primary notation detected"
  )

  expect_equal(nrow(out), 0)
})


test_that("compute_def omits patients with invalid FDI primary teeth", {

  df <- tibble::tibble(
    patient_id = 1,
    tooth = c("51", "52", "99"),  # 99 invalid
    D = 1, E = 0, F = 0
  )

  expect_warning(
    out <- compute_def(df),
    "Invalid FDI primary teeth"
  )

  expect_equal(nrow(out), 0)
})


test_that("compute_def enforces complete primary dentition", {

  df <- tibble::tibble(
    patient_id = 1,
    tooth = as.character(c(51:55, 61:65, 71:75)),  # missing 81–85
    D = 0, E = 0, F = 0
  )

  expect_warning(
    out <- compute_def(df),
    "Incomplete primary dentition"
  )

  expect_equal(nrow(out), 0)
})


test_that("compute_def enforces binary and exclusive D/E/F", {

  # Full primary dentition
  teeth <- as.character(c(51:55, 61:65, 71:75, 81:85))

  # Case 1: mutually exclusive violation
  df_conflict <- tibble::tibble(
    patient_id = 1,
    tooth = teeth,
    D = 0, E = 0, F = 0
  )

  # Introduce conflict in one tooth
  df_conflict$D[df_conflict$tooth == "51"] <- 1
  df_conflict$E[df_conflict$tooth == "51"] <- 1

  expect_warning(
    out <- compute_def(df_conflict),
    "mutually exclusive"
  )
  expect_equal(nrow(out), 0)


  # Case 2: non-binary values
  df_nonbinary <- tibble::tibble(
    patient_id = 1,
    tooth = teeth,
    D = 0, E = 0, F = 0
  )

  df_nonbinary$D[df_nonbinary$tooth == "51"] <- 2

  expect_warning(
    out <- compute_def(df_nonbinary),
    "must be 0 or 1"
  )
  expect_equal(nrow(out), 0)
})


test_that("compute_def returns empty tibble when all patients invalid", {

  df <- tibble::tibble(
    patient_id = 1,
    tooth = "11",  # permanent
    D = 1, E = 0, F = 0
  )

  expect_warning(
    out <- compute_def(df),
    "Permanent teeth detected"
  )

  expect_equal(nrow(out), 0)
  expect_named(out, c("patient_id", "def"))
})
