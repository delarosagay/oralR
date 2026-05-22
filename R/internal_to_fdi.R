#' Internal tooth code standardizer
#'
#' Converts alphanumeric dental notation (UR, UL, LL, LR) to FDI notation.
#' Codes already expressed in FDI or Universal notation are preserved.
#' If the input carries an 'ambiguous_as' attribute (from handle_ambiguous_notation()),
#' this resolution is preserved and passed to parse_notation().
#'
#' This function is internal and not exported.
#'
#' @param x A character vector of tooth codes.
#'
#' @return A character vector with FDI-standardized tooth codes.
#' @noRd
.internal_to_fdi <- function(x) {

  x_chr <- as.character(x)

  ambiguous_as <- attr(x, "ambiguous_as")
  if (!is.null(ambiguous_as)) {
    attr(x_chr, "ambiguous_as") <- ambiguous_as
  }

  parsed <- parse_notation(x_chr)

  out <- x_chr

  is_alpha <- !is.na(parsed$notation) & parsed$notation == "Alphanumeric"
  out[is_alpha] <- convert_alphanumeric_to_fdi(out[is_alpha])

  if (!is.null(ambiguous_as)) {
    attr(out, "ambiguous_as") <- ambiguous_as
  }

  out
}
