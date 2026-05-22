test_that("convert_fdi_to_alphanumeric works for permanent teeth", {
  expect_equal(convert_fdi_to_alphanumeric("11"), "UR1")
  expect_equal(convert_fdi_to_alphanumeric("18"), "UR8")
  expect_equal(convert_fdi_to_alphanumeric("21"), "UL1")
  expect_equal(convert_fdi_to_alphanumeric("28"), "UL8")
  expect_equal(convert_fdi_to_alphanumeric("31"), "LL1")
  expect_equal(convert_fdi_to_alphanumeric("38"), "LL8")
  expect_equal(convert_fdi_to_alphanumeric("41"), "LR1")
  expect_equal(convert_fdi_to_alphanumeric("48"), "LR8")
})

test_that("convert_fdi_to_alphanumeric works for primary teeth", {
  expect_equal(convert_fdi_to_alphanumeric("51"), "URA")
  expect_equal(convert_fdi_to_alphanumeric("55"), "URE")
  expect_equal(convert_fdi_to_alphanumeric("61"), "ULA")
  expect_equal(convert_fdi_to_alphanumeric("65"), "ULE")
  expect_equal(convert_fdi_to_alphanumeric("71"), "LLA")
  expect_equal(convert_fdi_to_alphanumeric("75"), "LLE")
  expect_equal(convert_fdi_to_alphanumeric("81"), "LRA")
  expect_equal(convert_fdi_to_alphanumeric("85"), "LRE")
})

test_that("convert_fdi_to_alphanumeric handles mixed vectors", {
  input <- c("11", "55", "32", "81")
  expected <- c("UR1", "URE", "LL2", "LRA")
  expect_equal(convert_fdi_to_alphanumeric(input), expected)
})

test_that("convert_fdi_to_alphanumeric returns NA for invalid codes", {
  expect_true(is.na(convert_fdi_to_alphanumeric("99")))
  expect_true(is.na(convert_fdi_to_alphanumeric("0")))
  expect_true(is.na(convert_fdi_to_alphanumeric("AA")))
  expect_true(is.na(convert_fdi_to_alphanumeric(NA)))
})

test_that("convert_fdi_to_alphanumeric preserves input length and order", {
  input <- c("11", "99", "21", "AA", "55")
  output <- convert_fdi_to_alphanumeric(input)
  expect_length(output, length(input))
  expect_equal(output[c(1,3,5)], c("UR1", "UL1", "URE"))
  expect_true(is.na(output[2]))
  expect_true(is.na(output[4]))
})

test_that("convert_fdi_to_alphanumeric handles edge cases for R objects", {
  expect_equal(convert_fdi_to_alphanumeric(NULL), character(0))
  expect_equal(convert_fdi_to_alphanumeric(character(0)), character(0))
  expect_true(is.na(convert_fdi_to_alphanumeric(NA)))
})
