test_that("handle_ambiguous_notation marks ambiguous values as FDI with attribute", {
  x <- c("11", "21", "31")
  out <- handle_ambiguous_notation(x, "as_fdi")

  # Check that values remain the same
  expect_equal(as.character(out), x)

  # Attribute correctly set
  expect_equal(attr(out, "ambiguous_as"), "FDI")
})

test_that("handle_ambiguous_notation marks ambiguous values as Universal with attribute", {
  x <- c("11", "15", "32")
  out <- handle_ambiguous_notation(x, "as_universal")

  # Check that values remain the same
  expect_equal(as.character(out), x)

  # Attribute correctly set
  expect_equal(attr(out, "ambiguous_as"), "Universal")
})

test_that("handle_ambiguous_notation handles the 'remove' and 'na' actions", {
  x <- c("11", "48", "UR1") # 11 is ambiguous, others are not

  # Action: remove
  expect_equal(handle_ambiguous_notation(x, "remove"), c("48", "UR1"))

  # Action: na
  out_na <- handle_ambiguous_notation(x, "na")
  expect_true(is.na(out_na[1]))
  expect_equal(as.character(out_na[2:3]), c("48", "UR1"))
})

test_that("handle_ambiguous_notation sets attribute even if no ambiguous values are currently present", {
  # Even if "45" isn't ambiguous, the user wants to mark the vector context
  x <- c("45", "UR1", "A")
  out <- handle_ambiguous_notation(x, "as_fdi")

  expect_equal(as.character(out), as.character(x))
  expect_equal(attr(out, "ambiguous_as"), "FDI")
})

test_that("handle_ambiguous_notation is case-insensitive and handles numeric input", {
  x <- c(11, 12)
  out <- handle_ambiguous_notation(x, "as_fdi")

  expect_equal(attr(out, "ambiguous_as"), "FDI")
})

test_that("handle_ambiguous_notation handles the 'remove' and 'na' actions", {
  # '11' is ambiguous (FDI and Universal)
  # '19' and '20' are Universal only, so they should not be treated as ambiguous
  # '48' and 'UR1' are not ambiguous
  x <- c("11", "19", "20", "48", "UR1")

  # Action: remove (only '11' should be removed)
  expect_equal(handle_ambiguous_notation(x, "remove"), c("19", "20", "48", "UR1"))

  # Action: na (only '11' should become NA)
  out_na <- handle_ambiguous_notation(x, "na")
  expect_true(is.na(out_na[1]))
  expect_equal(as.character(out_na[2:5]), c("19", "20", "48", "UR1"))
})
