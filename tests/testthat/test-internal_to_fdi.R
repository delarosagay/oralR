test_that(".internal_to_fdi() preserves FDI codes unchanged", {
  x <- c("11", "24", "36", "48")
  out <- .internal_to_fdi(x)
  expect_equal(out, x)
})

test_that(".internal_to_fdi() converts alphanumeric notation to FDI", {
  x <- c("UR1", "UL6", "LL3", "LR7")
  out <- .internal_to_fdi(x)
  expect_equal(out, c("11", "26", "33", "47"))
})

test_that(".internal_to_fdi() handles mixed FDI and alphanumeric inputs", {
  x <- c("UR2", "12", "LL5", "45")
  out <- .internal_to_fdi(x)
  expect_equal(out, c("12", "12", "35", "45"))
})

test_that(".internal_to_fdi() preserves ambiguous_as attribute", {
  x <- c("11", "UR1")
  attr(x, "ambiguous_as") <- "Universal"

  out <- .internal_to_fdi(x)

  expect_true(!is.null(attr(out, "ambiguous_as")))
  expect_equal(attr(out, "ambiguous_as"), "Universal")
})

test_that(".internal_to_fdi() only converts alphanumeric notation", {
  x <- c("UR4", "14", "UL1", "21")
  out <- .internal_to_fdi(x)

  expect_equal(out, c("14", "14", "21", "21"))
})

test_that(".internal_to_fdi() returns character output", {
  x <- c("UR6", "LL2")
  out <- .internal_to_fdi(x)
  expect_type(out, "character")
})

test_that(".internal_to_fdi() handles empty input gracefully", {
  x <- character(0)
  out <- .internal_to_fdi(x)
  expect_equal(out, character(0))
})
