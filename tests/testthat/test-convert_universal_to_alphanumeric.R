test_that("convert_universal_to_alphanumeric works for permanent teeth", {
  # Single permanent teeth (Clockwise mapping)
  expect_equal(convert_universal_to_alphanumeric("1"), "UR8")
  expect_equal(convert_universal_to_alphanumeric("8"), "UR1")
  expect_equal(convert_universal_to_alphanumeric("9"), "UL1")
  expect_equal(convert_universal_to_alphanumeric("16"), "UL8")
  expect_equal(convert_universal_to_alphanumeric("17"), "LL8")
  expect_equal(convert_universal_to_alphanumeric("24"), "LL1")
  expect_equal(convert_universal_to_alphanumeric("25"), "LR1")
  expect_equal(convert_universal_to_alphanumeric("32"), "LR8")
})


test_that("convert_universal_to_alphanumeric works for primary teeth", {
  # Primary teeth (A–T mapping)
  expect_equal(convert_universal_to_alphanumeric("A"), "URE")
  expect_equal(convert_universal_to_alphanumeric("E"), "URA")
  expect_equal(convert_universal_to_alphanumeric("F"), "ULA")
  expect_equal(convert_universal_to_alphanumeric("J"), "ULE")
  expect_equal(convert_universal_to_alphanumeric("K"), "LLE")
  expect_equal(convert_universal_to_alphanumeric("O"), "LLA")
  expect_equal(convert_universal_to_alphanumeric("P"), "LRA")
  expect_equal(convert_universal_to_alphanumeric("T"), "LRE")
})


test_that("convert_universal_to_alphanumeric handles mixed vectors", {
  input_vec    <- c("1", "E", "16", "T")
  expected_vec <- c("UR8", "URA", "UL8", "LRE")
  expect_equal(convert_universal_to_alphanumeric(input_vec), expected_vec)
})


test_that("convert_universal_to_alphanumeric handles invalid and edge cases", {
  # Invalid notation
  expect_true(is.na(convert_universal_to_alphanumeric("0")))
  expect_true(is.na(convert_universal_to_alphanumeric("33")))
  expect_true(is.na(convert_universal_to_alphanumeric("Z")))
  expect_true(is.na(convert_universal_to_alphanumeric("AA")))

  # R object edge cases
  expect_equal(convert_universal_to_alphanumeric(NULL), character(0))
  expect_equal(convert_universal_to_alphanumeric(character(0)), character(0))
  expect_true(is.na(convert_universal_to_alphanumeric(NA)))

  # Case insensitivity
  expect_equal(convert_universal_to_alphanumeric("a"), "URE")
})

