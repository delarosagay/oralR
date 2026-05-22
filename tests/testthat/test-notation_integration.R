test_that("Universal → Alphanumeric → Universal is consistent", {

  universal <- c("1", "8", "16", "24", "32", "A", "E", "J", "O", "T")

  alpha <- convert_universal_to_alphanumeric(universal)
  back  <- convert_alphanumeric_to_universal(alpha)

  expect_equal(as.character(back), universal)
})


test_that("Alphanumeric → FDI → Alphanumeric is consistent", {

  alpha <- c("UR1", "UL8", "LL3", "LR7", "URA", "ULC", "LLD", "LRE")

  fdi   <- convert_alphanumeric_to_fdi(alpha)
  back  <- convert_fdi_to_alphanumeric(fdi)

  expect_equal(as.character(back), alpha)
})


test_that("FDI → Alphanumeric → FDI is consistent", {

  fdi <- c("11", "28", "36", "48", "51", "63", "74", "85")

  alpha <- convert_fdi_to_alphanumeric(fdi)
  back  <- convert_alphanumeric_to_fdi(alpha)

  expect_equal(as.character(back), fdi)
})


test_that("Universal → FDI → Universal is consistent (via alphanumeric)", {

  universal <- c("1", "12", "24", "32", "A", "H", "O", "T")

  alpha <- convert_universal_to_alphanumeric(universal)
  fdi   <- convert_alphanumeric_to_fdi(alpha)
  back_alpha <- convert_fdi_to_alphanumeric(fdi)
  back_universal <- convert_alphanumeric_to_universal(back_alpha)

  expect_equal(as.character(back_universal), universal)
})


test_that("Invalid values propagate NA through conversion chains", {

  invalid <- c("XYZ", "99", "UR9", "LLZ", "123", "AA")

  # Universal → Alphanumeric → Universal
  expect_true(all(is.na(convert_alphanumeric_to_universal(
    convert_universal_to_alphanumeric(invalid)
  ))))

  # Alphanumeric → FDI → Alphanumeric
  expect_true(all(is.na(convert_alphanumeric_to_fdi(invalid))))

  # FDI → Alphanumeric → FDI
  expect_true(all(is.na(convert_fdi_to_alphanumeric(invalid))))
})

