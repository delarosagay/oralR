test_that("convert_universal_to_fdi for permanent teeth", {
  # Upper Right
  expect_equal(convert_universal_to_fdi(1),  "18", ignore_attr = TRUE)
  expect_equal(convert_universal_to_fdi(2),  "17", ignore_attr = TRUE)
  expect_equal(convert_universal_to_fdi(3),  "16", ignore_attr = TRUE)
  expect_equal(convert_universal_to_fdi(8),  "11", ignore_attr = TRUE)

  # Upper Left
  expect_equal(convert_universal_to_fdi(9),  "21", ignore_attr = TRUE)
  expect_equal(convert_universal_to_fdi(12), "24", ignore_attr = TRUE)
  expect_equal(convert_universal_to_fdi(16), "28", ignore_attr = TRUE)

  # Lower Left
  expect_equal(convert_universal_to_fdi(17), "38", ignore_attr = TRUE)
  expect_equal(convert_universal_to_fdi(20), "35", ignore_attr = TRUE)
  expect_equal(convert_universal_to_fdi(24), "31", ignore_attr = TRUE)

  # Lower Right
  expect_equal(convert_universal_to_fdi(25), "41", ignore_attr = TRUE)
  expect_equal(convert_universal_to_fdi(28), "44", ignore_attr = TRUE)
  expect_equal(convert_universal_to_fdi(32), "48", ignore_attr = TRUE)

  # Vector test for permanent teeth
  expect_equal(
    convert_universal_to_fdi(c(1, 16, 32)),
    c("18", "28", "48"),
    ignore_attr = TRUE
  )
})

test_that("convert_universal_to_fdi for primary teeth", {
  # Upper Right
  expect_equal(convert_universal_to_fdi("A"), "55", ignore_attr = TRUE)
  expect_equal(convert_universal_to_fdi("E"), "51", ignore_attr = TRUE)

  # Upper Left
  expect_equal(convert_universal_to_fdi("F"), "61", ignore_attr = TRUE)
  expect_equal(convert_universal_to_fdi("J"), "65", ignore_attr = TRUE)

  # Lower Left
  expect_equal(convert_universal_to_fdi("K"), "75", ignore_attr = TRUE)
  expect_equal(convert_universal_to_fdi("O"), "71", ignore_attr = TRUE)

  # Lower Right
  expect_equal(convert_universal_to_fdi("P"), "81", ignore_attr = TRUE)
  expect_equal(convert_universal_to_fdi("T"), "85", ignore_attr = TRUE)

  # Vector test for primary teeth
  expect_equal(
    convert_universal_to_fdi(c("A", "F", "P")),
    c("55", "61", "81"),
    ignore_attr = TRUE
  )
})

test_that("convert_universal_to_fdi handles invalid and edge cases", {
  # Invalid inputs
  expect_true(is.na(convert_universal_to_fdi("Z")))
  expect_true(is.na(convert_universal_to_fdi(99)))
  expect_true(is.na(convert_universal_to_fdi(" ")))

  # Mixed valid + invalid
  expect_equal(
    convert_universal_to_fdi(c("A", "Z")),
    c("55", NA_character_),
    ignore_attr = TRUE
  )

  # R object edge cases
  expect_equal(convert_universal_to_fdi(NULL), character(0), ignore_attr = TRUE)
  expect_equal(convert_universal_to_fdi(character(0)), character(0), ignore_attr = TRUE)
  expect_true(is.na(convert_universal_to_fdi(NA)))

  # Case insensitivity
  expect_equal(convert_universal_to_fdi("a"), "55", ignore_attr = TRUE)
})


test_that("convert_universal_to_fdi sets the ambiguous_as attribute correctly", {
  out <- convert_universal_to_fdi(c(1, "A"))

  # Check that the attribute exists and is exactly "FDI"
  expect_equal(attr(out, "ambiguous_as"), "FDI")

  # Ensure vector names were stripped correctly to avoid interfering with attributes
  expect_null(names(out))
})
