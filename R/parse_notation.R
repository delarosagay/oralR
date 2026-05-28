#' Parse Dental Notation Codes into Structured Components
#'
#' Identifies the dental notation system used in each input code and extracts
#' standardized components such as quadrant and tooth type. The function supports
#' Universal notation (permanent 1–32 and primary A–T), Alphanumeric notation
#' (UR/UL/LL/LR followed by a number or letter), and FDI notation. Numeric codes
#' that can belong to more than one system are treated as ambiguous unless a
#' user-defined preference is provided through the `ambiguous_as` attribute,
#' typically set by `handle_ambiguous_notation()`.
#'
#' @param x A character vector containing dental codes to be parsed. The vector
#'   may carry an attribute `ambiguous_as` indicating how ambiguous numeric
#'   codes should be interpreted (e.g., `"Universal"` or `"FDI"`).
#' @param ... Additional arguments (currently unused).
#'
#' @return A tibble with the following columns:
#' \describe{
#'   \item{input}{The original input code.}
#'   \item{notation}{Detected notation system: `"Universal"`, `"Alphanumeric"`,
#'                   `"FDI"`, `"ambiguous"`, or `NA`.}
#'   \item{quadrant}{Quadrant number (1–4) when determinable, otherwise `NA`.}
#'   \item{type}{Tooth type: `"permanent"`, `"primary"`, or `NA`.}
#' }
#'
#' @examples
#' # Parse a heterogeneous vector of tooth codes from different notation systems
#' mixed_codes <- c("11", "46", "URB", "A", "30")
#' parse_notation(mixed_codes)
#'
#' @export
parse_notation <- function(x, ...) {

  if (length(x) == 0) {
    return(dplyr::tibble(
      input = character(),
      notation = character(),
      quadrant = numeric(),
      type = character()
    ))
  }

  clean_x <- as.character(x)
  ambiguous_as <- attr(x, "ambiguous_as")

  # Ambiguous numeric codes: can be Universal or FDI
  ambiguous_numeric <- as.character(c(11:18, 21:28, 31:32))

  # Valid FDI numeric codes (permanent + primary)
  fdi_numeric <- as.character(c(
    11:18, 21:28, 31:38, 41:48,  # permanent
    51:55, 61:65, 71:75, 81:85   # primary
  ))

  # Valid Universal numeric codes
  universal_numeric <- as.character(1:32)

  resolve_code <- function(code) {
    if (is.na(code) || code == "" || code == "character(0)") return(NA_character_)

    # Alphanumeric (UR/UL/LL/LR + suffix)
    if (grepl("^(UR|UL|LL|LR)", code, ignore.case = TRUE)) return("Alphanumeric")

    # Universal primary letters A–T
    if (grepl("^[A-Ta-t]$", code)) return("Universal")

    # Pure numeric codes
    if (grepl("^[0-9]+$", code)) {

      # Ambiguous numeric: use attribute if present
      if (code %in% ambiguous_numeric) {
        if (!is.null(ambiguous_as) && ambiguous_as == "Universal") return("Universal")
        if (!is.null(ambiguous_as) && ambiguous_as == "FDI")       return("FDI")
        return("ambiguous")
      }

      # Non-ambiguous FDI
      if (code %in% fdi_numeric) return("FDI")

      # Non-ambiguous Universal
      if (code %in% universal_numeric) return("Universal")

      return(NA_character_)
    }

    return(NA_character_)
  }

  notations <- vapply(clean_x, resolve_code, FUN.VALUE = character(1))

  out <- dplyr::tibble(
    input = clean_x,
    notation = notations,
    quadrant = NA_real_,
    type = NA_character_
  )

  # Alphanumeric: quadrant + type
  alpha_idx <- which(out$notation == "Alphanumeric")
  if (length(alpha_idx) > 0) {
    quads <- toupper(substr(out$input[alpha_idx], 1, 2))
    out$quadrant[alpha_idx] <- dplyr::case_when(
      quads == "UR" ~ 1,
      quads == "UL" ~ 2,
      quads == "LL" ~ 3,
      quads == "LR" ~ 4,
      TRUE ~ NA_real_
    )
    suffix <- substr(out$input[alpha_idx], 3, nchar(out$input[alpha_idx]))
    out$type[alpha_idx] <- ifelse(
      grepl("^[A-Ea-e]$", suffix),
      "primary",
      "permanent"
    )
  }

  # Universal primary letters
  uni_letter_idx <- which(out$notation == "Universal" &
                            grepl("^[A-Ta-t]$", out$input))
  if (length(uni_letter_idx) > 0) {
    letters <- toupper(out$input[uni_letter_idx])
    out$quadrant[uni_letter_idx] <- dplyr::case_when(
      letters %in% LETTERS[1:5]   ~ 1,
      letters %in% LETTERS[6:10]  ~ 2,
      letters %in% LETTERS[11:15] ~ 3,
      letters %in% LETTERS[16:20] ~ 4,
      TRUE ~ NA_real_
    )
    out$type[uni_letter_idx] <- "primary"
  }

  # Universal numeric permanent
  uni_num_idx <- which(out$notation == "Universal" &
                         grepl("^[0-9]+$", out$input))
  if (length(uni_num_idx) > 0) {
    nums <- as.numeric(out$input[uni_num_idx])
    out$quadrant[uni_num_idx] <- dplyr::case_when(
      nums %in% 1:8   ~ 1,
      nums %in% 9:16  ~ 2,
      nums %in% 17:24 ~ 3,
      nums %in% 25:32 ~ 4,
      TRUE ~ NA_real_
    )
    out$type[uni_num_idx] <- "permanent"
  }

  # FDI numeric (permanent + primary)
  fdi_idx <- which(out$notation == "FDI")
  if (length(fdi_idx) > 0) {

    codes <- as.numeric(out$input[fdi_idx])
    quadrant_fdi <- floor(codes / 10)
    tooth_number <- codes %% 10

    type <- ifelse(quadrant_fdi <= 4, "permanent", "primary")

    quadrant_clinic <- ifelse(quadrant_fdi > 4,
                              quadrant_fdi - 4,
                              quadrant_fdi)

    out$quadrant[fdi_idx] <- quadrant_clinic
    out$type[fdi_idx] <- type
  }

  out
}

