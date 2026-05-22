test_that("detect_notation identifies FDI permanent teeth correctly", {
  # Now returning a list for single inputs too
  expect_equal(detect_notation("11"), list(c("Universal", "FDI")))
  expect_equal(detect_notation("18"), list(c("Universal", "FDI")))
  expect_equal(detect_notation("33"), list("FDI"))
  expect_equal(detect_notation("48"), list("FDI"))
})

test_that("detect_notation identifies FDI primary teeth", {
  expect_equal(detect_notation("51"), list("FDI"))
  expect_equal(detect_notation("85"), list("FDI"))
})

test_that("detect_notation identifies Universal permanent teeth", {
  expect_equal(detect_notation("1"), list("Universal"))
  expect_equal(detect_notation("9"), list("Universal"))
  expect_equal(detect_notation("10"), list("Universal"))
  # 19 and 20 are Universal only (FDI second digit must be 1-8)
  expect_equal(detect_notation("19"), list("Universal"))
  expect_equal(detect_notation("20"), list("Universal"))
})

test_that("detect_notation identifies Universal primary teeth (A–T)", {
  expect_equal(detect_notation("A"), list("Universal"))
  expect_equal(detect_notation("T"), list("Universal"))
  expect_equal(detect_notation("j"), list("Universal")) # Case insensitivity check
})

test_that("detect_notation identifies alphanumeric teeth (all cases)", {
  expect_equal(detect_notation("UR1"), list("Alphanumeric"))
  expect_equal(detect_notation("ll8"), list("Alphanumeric")) # lowercase
  expect_equal(detect_notation("URA"), list("Alphanumeric"))
  expect_equal(detect_notation("LLE"), list("Alphanumeric"))
})

test_that("detect_notation handles invalid or out-of-bounds inputs", {
  expect_equal(detect_notation("99"), list(character(0)))
  expect_equal(detect_notation("39"), list(character(0)))
  expect_equal(detect_notation("40"), list(character(0)))
  expect_equal(detect_notation("0"), list(character(0)))
  expect_equal(detect_notation("UR9"), list(character(0)))
  expect_equal(detect_notation("URF"), list(character(0)))
})

test_that("detect_notation handles empty and NA values", {
  expect_equal(detect_notation(NA), list(character(0)))
  expect_equal(detect_notation(""), list(character(0)))
  expect_equal(detect_notation(NULL), list()) # Added NULL case
})

test_that("detect_notation works vectorized with correct list structure", {
  x <- c("11", "UR1", "9", "99")
  result <- detect_notation(x)

  expect_type(result, "list")
  expect_length(result, 4)
  expect_equal(result[[1]], c("Universal", "FDI"))
  expect_equal(result[[2]], "Alphanumeric")
  expect_equal(result[[3]], "Universal")
  expect_equal(result[[4]], character(0))
})


test_that("detect_notation respects ambiguous_as attribute from handle_ambiguous_notation", {

  x_fdi <- c("11", "24", "36")
  attr(x_fdi, "ambiguous_as") <- "FDI"
  res_fdi <- detect_notation(x_fdi)

  expect_equal(res_fdi[[1]], "FDI")
  expect_equal(res_fdi[[2]], "FDI")
  expect_equal(res_fdi[[3]], "FDI")


  x_uni <- c("11", "24", "36")
  attr(x_uni, "ambiguous_as") <- "Universal"
  res_uni <- detect_notation(x_uni)

  expect_equal(res_uni[[1]], "Universal")
  expect_equal(res_uni[[2]], "Universal")
  expect_equal(res_uni[[3]], "FDI")
})

test_that("detect_notation handles vectors with mixed non-ambiguous elements and attributes", {
  x_mixed <- c("11", "UR1", "99")
  attr(x_mixed, "ambiguous_as") <- "FDI"
  res_mixed <- detect_notation(x_mixed)

  expect_equal(res_mixed[[1]], "FDI")
  expect_equal(res_mixed[[2]], "Alphanumeric")
  expect_equal(res_mixed[[3]], character(0))
})
