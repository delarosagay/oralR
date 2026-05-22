test_that("tidy_dental() basic normalization and validation", {
  # Error on missing patient column
  df_err <- data.frame(id = 1:3)
  expect_error(tidy_dental(df_err, patient_col = "patient_id"))

  # Dot and hyphen normalization
  df_norm <- tibble::tibble(`patient-id` = 1, tooth = "11", tooth_side = "B")
  out <- tidy_dental(df_norm, patient_col = "patient-id")
  expect_true("patient_id" %in% names(out))

  # Check for invalid dental codes
  df_invalid <- tibble::tibble(patient_id = 1, tooth = "XY3", value = 1)
  expect_error(tidy_dental(df_invalid), "Invalid dental codes detected")
})

test_that("tidy_dental() handles wide underscore (Mixed systems)", {
  df_wide <- tibble::tibble(
    patient_id = 1,
    `16_MB` = 1, # FDI (Valid)
    `1_B` = 0,   # Universal (Valid)
    `UR6_V` = 1  # Alphanumeric (Valid)
  )
  out <- tidy_dental(df_wide)
  expect_setequal(out$tooth_side, c("MB", "B"))
  # UR6 becomes 16, 16 remains 16, 1 remains 1
  expect_setequal(as.character(out$tooth), c("16", "1"))
  expect_equal(nrow(out), 3)

  # Mixed valid and invalid columns
  df_bad_wide <- tibble::tibble(patient_id = 1, `11_B` = 1, `67_V` = 0)
  expect_error(tidy_dental(df_bad_wide), "Invalid dental codes detected")
})

test_that("tidy_dental() handles periodontal wide (No underscores)", {
  df_surf <- tibble::tibble(
    patient_id = 1,
    tooth = "UR6",
    MB = 1,
    v  = 0
  )
  out <- tidy_dental(df_surf)
  expect_setequal(out$tooth_side, c("MB", "B"))
  expect_equal(as.character(unique(out$tooth)), "16")
  expect_equal(nrow(out), 2)

  # Check invalid tooth in periodontal wide
  df_bad_surf <- tibble::tibble(patient_id = 1, tooth = "99", MB = 1)
  expect_error(tidy_dental(df_bad_surf), "Invalid dental codes detected")
})

test_that("tidy_dental() handles long and tooth-level formats", {
  # Long
  df_long <- tibble::tibble(patient_id = 1, tooth = "UR1", tooth_side = "B")
  expect_equal(as.character(tidy_dental(df_long)$tooth), "11")

  # Tooth-level
  df_tl <- tibble::tibble(patient_id = 1, tooth = "LL1", value = 1)
  expect_equal(as.character(tidy_dental(df_tl)$tooth), "31")
})

test_that("tidy_dental() preserves ambiguous numeric codes", {
  # 11 and 32 are valid in FDI or Universal, so detect_notation allows them
  df_num <- tibble::tibble(patient_id = 1, tooth = c("11", "32"))
  out <- tidy_dental(df_num)
  expect_equal(as.character(out$tooth), c("11", "32"))

  # 49 is not valid in any system
  df_num_err <- tibble::tibble(patient_id = 1, tooth = "49")
  expect_error(tidy_dental(df_num_err), "Invalid dental codes detected")
})

test_that("tidy_dental() returns summary data and sextants unchanged", {
  # Summary (No dental structure detected, should return original)
  df_sum <- tibble::tibble(patient_id = 1, dmft = 5)
  expect_equal(dplyr::distinct(df_sum), tidy_dental(df_sum))

  # Sextant (Valid format)
  df_sex <- tibble::tibble(patient_id = 1, sextant = 1, code = 3)
  out_sex <- tidy_dental(df_sex)
  expect_true("sextant" %in% names(out_sex))
})
