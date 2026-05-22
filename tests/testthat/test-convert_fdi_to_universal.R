test_that("convert_fdi_to_universal works for permanent teeth", {

  # Single permanent teeth
  expect_equal(convert_fdi_to_universal(11), "8",  ignore_attr = TRUE)
  expect_equal(convert_fdi_to_universal(12), "7",  ignore_attr = TRUE)
  expect_equal(convert_fdi_to_universal(18), "1",  ignore_attr = TRUE)

  expect_equal(convert_fdi_to_universal(21), "9",   ignore_attr = TRUE)
  expect_equal(convert_fdi_to_universal(24), "12",  ignore_attr = TRUE)
  expect_equal(convert_fdi_to_universal(28), "16",  ignore_attr = TRUE)

  expect_equal(convert_fdi_to_universal(31), "24",  ignore_attr = TRUE)
  expect_equal(convert_fdi_to_universal(32), "23",  ignore_attr = TRUE)
  expect_equal(convert_fdi_to_universal(36), "19",  ignore_attr = TRUE)
  expect_equal(convert_fdi_to_universal(38), "17",  ignore_attr = TRUE)

  expect_equal(convert_fdi_to_universal(41), "25",  ignore_attr = TRUE)
  expect_equal(convert_fdi_to_universal(44), "28",  ignore_attr = TRUE)
  expect_equal(convert_fdi_to_universal(48), "32",  ignore_attr = TRUE)

  # Vector of permanent teeth
  expect_equal(
    convert_fdi_to_universal(c(11, 21, 36, 48)),
    c("8", "9", "19", "32"),
    ignore_attr = TRUE
  )
})

test_that("convert_fdi_to_universal works for primary teeth", {

  # UR primary (51–55 → E–A)
  expect_equal(convert_fdi_to_universal(51), "E", ignore_attr = TRUE)
  expect_equal(convert_fdi_to_universal(55), "A", ignore_attr = TRUE)

  # UL primary (61–65 → F–J)
  expect_equal(convert_fdi_to_universal(61), "F", ignore_attr = TRUE)
  expect_equal(convert_fdi_to_universal(65), "J", ignore_attr = TRUE)

  # LL primary (71–75 → O–K)
  expect_equal(convert_fdi_to_universal(71), "O", ignore_attr = TRUE)
  expect_equal(convert_fdi_to_universal(75), "K", ignore_attr = TRUE)

  # LR primary (81–85 → P–T)
  expect_equal(convert_fdi_to_universal(81), "P", ignore_attr = TRUE)
  expect_equal(convert_fdi_to_universal(85), "T", ignore_attr = TRUE)

  # Vector of primary teeth
  expect_equal(
    convert_fdi_to_universal(c(51, 62, 83)),
    c("E", "G", "R"),
    ignore_attr = TRUE
  )
})

test_that("convert_fdi_to_universal handles invalid inputs", {

  # Single invalid
  expect_equal(convert_fdi_to_universal(99), NA_character_, ignore_attr = TRUE)

  # Mixed valid + invalid
  expect_equal(
    convert_fdi_to_universal(c("11", "99")),
    c("8", NA),
    ignore_attr = TRUE
  )

  # Non-numeric strings
  expect_equal(convert_fdi_to_universal("XYZ"), NA_character_, ignore_attr = TRUE)

  # Empty input
  expect_equal(convert_fdi_to_universal(character(0)), character(0), ignore_attr = TRUE)
})

test_that("convert_fdi_to_universal handles NULL", {
  expect_equal(convert_fdi_to_universal(NULL), character(0), ignore_attr = TRUE)
})

test_that("convert_fdi_to_universal sets the ambiguous_as attribute correctly", {
  out <- convert_fdi_to_universal(c(11, 51))

  # Check that the attribute exists and is exactly "Universal"
  expect_equal(attr(out, "ambiguous_as"), "Universal")

  # Ensure names were stripped correctly to prevent R from destroying the attribute
  expect_null(names(out))
})

