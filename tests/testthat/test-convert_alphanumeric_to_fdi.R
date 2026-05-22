test_that("convert_alphanumeric_to_fdi converts permanent teeth correctly", {
  expect_equal(as.character(convert_alphanumeric_to_fdi("UR1")), "11")
  expect_equal(as.character(convert_alphanumeric_to_fdi("UR6")), "16")
  expect_equal(as.character(convert_alphanumeric_to_fdi("UL1")), "21")
  expect_equal(as.character(convert_alphanumeric_to_fdi("UL8")), "28")
  expect_equal(as.character(convert_alphanumeric_to_fdi("LL1")), "31")
  expect_equal(as.character(convert_alphanumeric_to_fdi("LL8")), "38")
  expect_equal(as.character(convert_alphanumeric_to_fdi("LR3")), "43")
  expect_equal(as.character(convert_alphanumeric_to_fdi("LR8")), "48")
})

test_that("convert_alphanumeric_to_fdi converts primary teeth correctly", {
  expect_equal(as.character(convert_alphanumeric_to_fdi("URA")), "51")
  expect_equal(as.character(convert_alphanumeric_to_fdi("ULC")), "63")
  expect_equal(as.character(convert_alphanumeric_to_fdi("LLD")), "74")
  expect_equal(as.character(convert_alphanumeric_to_fdi("LRE")), "85")
})

test_that("convert_alphanumeric_to_fdi handles vectors", {
  input <- c("UR1", "UL2", "LLA", "LR8")
  expected <- c("11", "22", "71", "48")
  expect_equal(as.character(convert_alphanumeric_to_fdi(input)), expected)
})

test_that("convert_alphanumeric_to_fdi handles case insensitivity", {
  expect_equal(as.character(convert_alphanumeric_to_fdi("ur1")), "11")
  expect_equal(as.character(convert_alphanumeric_to_fdi("llA")), "71")
})

test_that("convert_alphanumeric_to_fdi returns NA for invalid alphanumeric codes", {
  expect_true(is.na(convert_alphanumeric_to_fdi("XYZ")))   # Tooth XYZ does not exist
  expect_true(is.na(convert_alphanumeric_to_fdi("UR9")))   # Tooth UR9 does not exist
  expect_true(is.na(convert_alphanumeric_to_fdi("ULZ")))   # Tooth ULZ does not exist
  expect_true(is.na(convert_alphanumeric_to_fdi("LL0")))   # Tooth LL0 does not exist
  expect_true(is.na(convert_alphanumeric_to_fdi("LRF")))   # Tooth LRF does not exist
  expect_true(is.na(convert_alphanumeric_to_fdi("URA1")))  # Tooth URA1 does not exist
})

test_that("convert_alphanumeric_to_fdi returns NA for other notation systems", {
  expect_true(is.na(convert_alphanumeric_to_fdi("A")))     # Universal primary
  expect_true(is.na(convert_alphanumeric_to_fdi("12")))    # Universal permanent
  expect_true(is.na(convert_alphanumeric_to_fdi("21")))    # FDI permanent
  expect_true(is.na(convert_alphanumeric_to_fdi("55")))    # FDI primary
  expect_true(is.na(convert_alphanumeric_to_fdi("11")))    # Ambiguous FDI-Universal
})

test_that("convert_alphanumeric_to_fdi handles edge cases for R objects", {
  expect_equal(as.character(convert_alphanumeric_to_fdi(NULL)), character(0))
  expect_equal(as.character(convert_alphanumeric_to_fdi(character(0))), character(0))
  expect_true(is.na(convert_alphanumeric_to_fdi(NA)))
})

test_that("convert_alphanumeric_to_fdi sets the ambiguous_as attribute correctly", {
  out <- convert_alphanumeric_to_fdi(c("UR1", "UL2"))

  # Check that the attribute exists and is correct
  expect_equal(attr(out, "ambiguous_as"), "FDI")

  # Ensure names were stripped correctly and didn't interfere
  expect_null(names(out))
})
