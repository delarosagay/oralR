test_that("parse_notation identifies single digits as Universal", {
  result <- parse_notation("1")
  expect_equal(unname(result$notation), "Universal")
  expect_equal(unname(result$type), "permanent")
  expect_equal(unname(result$quadrant), 1)
})

test_that("parse_notation identifies ambiguous numeric codes", {
  result <- parse_notation("11")
  expect_equal(unname(result$notation), "ambiguous")
  expect_true(is.na(result$quadrant))
  expect_true(is.na(result$type))
})

test_that("parse_notation handles Alphanumeric primary teeth", {
  result <- parse_notation("URE")
  expect_equal(unname(result$notation), "Alphanumeric")
  expect_equal(unname(result$type), "primary")
  expect_equal(unname(result$quadrant), 1)
})

test_that("parse_notation respects ambiguous_as = 'Universal'", {
  x <- c("11", "24", "12", "31", "32")
  attr(x, "ambiguous_as") <- "Universal"

  result <- parse_notation(x)

  expect_equal(unname(result$notation), rep("Universal", length(x)))
  expect_equal(unname(result$type), rep("permanent", length(x)))
  expect_equal(unname(result$quadrant),
               c(2, 3, 2, 4, 4))  # 4 quadrants
})

