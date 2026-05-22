test_that("convert_alphanumeric_to_universal works for permanent, primary, vectors and invalid inputs", {

  # Permanent teeth (UR/UL/LL/LR + 1–8)

  # UR (1–8): inverse of Universal 1–8
  expect_equal(convert_alphanumeric_to_universal("UR1"), "8",  ignore_attr = TRUE)
  expect_equal(convert_alphanumeric_to_universal("UR2"), "7",  ignore_attr = TRUE)
  expect_equal(convert_alphanumeric_to_universal("UR3"), "6",  ignore_attr = TRUE)
  expect_equal(convert_alphanumeric_to_universal("UR4"), "5",  ignore_attr = TRUE)
  expect_equal(convert_alphanumeric_to_universal("UR5"), "4",  ignore_attr = TRUE)
  expect_equal(convert_alphanumeric_to_universal("UR6"), "3",  ignore_attr = TRUE)
  expect_equal(convert_alphanumeric_to_universal("UR7"), "2",  ignore_attr = TRUE)
  expect_equal(convert_alphanumeric_to_universal("UR8"), "1",  ignore_attr = TRUE)

  # UL (9–16)
  expect_equal(convert_alphanumeric_to_universal("UL1"), "9",   ignore_attr = TRUE)
  expect_equal(convert_alphanumeric_to_universal("UL8"), "16",  ignore_attr = TRUE)

  # LL (17–24): reversed
  expect_equal(convert_alphanumeric_to_universal("LL1"), "24",  ignore_attr = TRUE)
  expect_equal(convert_alphanumeric_to_universal("LL8"), "17",  ignore_attr = TRUE)

  # LR (25–32)
  expect_equal(convert_alphanumeric_to_universal("LR1"), "25",  ignore_attr = TRUE)
  expect_equal(convert_alphanumeric_to_universal("LR8"), "32",  ignore_attr = TRUE)


  # Primary teeth (UR/UL/LL/LR + A–E)

  # UR (A–E)
  expect_equal(convert_alphanumeric_to_universal("URA"), "E",  ignore_attr = TRUE)
  expect_equal(convert_alphanumeric_to_universal("URB"), "D",  ignore_attr = TRUE)
  expect_equal(convert_alphanumeric_to_universal("URC"), "C",  ignore_attr = TRUE)
  expect_equal(convert_alphanumeric_to_universal("URD"), "B",  ignore_attr = TRUE)
  expect_equal(convert_alphanumeric_to_universal("URE"), "A",  ignore_attr = TRUE)

  # UL (F–J)
  expect_equal(convert_alphanumeric_to_universal("ULA"), "F",  ignore_attr = TRUE)
  expect_equal(convert_alphanumeric_to_universal("ULE"), "J",  ignore_attr = TRUE)

  # LL (K–O)
  expect_equal(convert_alphanumeric_to_universal("LLA"), "O",  ignore_attr = TRUE)
  expect_equal(convert_alphanumeric_to_universal("LLE"), "K",  ignore_attr = TRUE)

  # LR (P–T)
  expect_equal(convert_alphanumeric_to_universal("LRA"), "P",  ignore_attr = TRUE)
  expect_equal(convert_alphanumeric_to_universal("LRE"), "T",  ignore_attr = TRUE)


  # Vector input
  input_vec    <- c("UR1", "URA", "UL8", "LRE")
  expected_vec <- c("8",   "E",   "16",  "T")
  expect_equal(convert_alphanumeric_to_universal(input_vec),
               expected_vec,
               ignore_attr = TRUE)


  # Invalid inputs
  expect_true(is.na(convert_alphanumeric_to_universal("XYZ")))
  expect_true(is.na(convert_alphanumeric_to_universal("UR9")))
  expect_true(is.na(convert_alphanumeric_to_universal("ULZ")))
  expect_true(is.na(convert_alphanumeric_to_universal("LL0")))
  expect_true(is.na(convert_alphanumeric_to_universal("LRF")))
  expect_true(is.na(convert_alphanumeric_to_universal("URA1")))
})


test_that("convert_alphanumeric_to_universal handles edge cases for R objects", {

  expect_equal(convert_alphanumeric_to_universal(NULL), character(0), ignore_attr = TRUE)
  expect_equal(convert_alphanumeric_to_universal(character(0)), character(0), ignore_attr = TRUE)

  expect_true(is.na(convert_alphanumeric_to_universal(NA)))

  # Case-insensitivity
  expect_equal(convert_alphanumeric_to_universal("ur1"), "8", ignore_attr = TRUE)
})

test_that("convert_alphanumeric_to_universal sets the ambiguous_as attribute correctly", {
  out <- convert_alphanumeric_to_universal(c("UR1", "UL1"))

  # Check that the attribute exists and is exactly "Universal"
  expect_equal(attr(out, "ambiguous_as"), "Universal")

  # Ensure vector names were stripped correctly to avoid interfering with the attribute
  expect_null(names(out))
})
