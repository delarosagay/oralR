#' Convert Alphanumeric notation to FDI
#'
#' Converts dental alphanumeric notation (Quadrant + Tooth) into FDI notation.
#' Quadrants are identified by "UR", "UL", "LL", or "LR". Permanent teeth
#' are identified by numbers 1–8, and primary teeth by letters A–E.
#'
#' @param alpha A character vector with alphanumeric tooth codes
#'   (e.g., "UR1", "LRA").
#'
#' @return A character vector with FDI notation. Invalid or non‑alphanumeric
#'   codes return `NA`. The returned vector carries the attribute
#'   `ambiguous_as = "FDI"`.
#'
#' @examples
#' # Convert Alphanumeric codes to FDI notation and print the output
#' alphanumeric_codes <- c("UR1", "UL1", "LL6")
#' fdi_codes <- convert_alphanumeric_to_fdi(alphanumeric_codes)
#' fdi_codes
#'
#' @export
convert_alphanumeric_to_fdi <- function(alpha) {

  if (is.null(alpha) || length(alpha) == 0) {
    return(character(0))
  }

  alpha_clean <- toupper(as.character(alpha))

  map <- c(
    # Permanent
    "UR1"="11", "UR2"="12", "UR3"="13", "UR4"="14", "UR5"="15", "UR6"="16", "UR7"="17", "UR8"="18",
    "UL1"="21", "UL2"="22", "UL3"="23", "UL4"="24", "UL5"="25", "UL6"="26", "UL7"="27", "UL8"="28",
    "LL1"="31", "LL2"="32", "LL3"="33", "LL4"="34", "LL5"="35", "LL6"="36", "LL7"="37", "LL8"="38",
    "LR1"="41", "LR2"="42", "LR3"="43", "LR4"="44", "LR5"="45", "LR6"="46", "LR7"="47", "LR8"="48",
    # Primary
    "URA"="51", "URB"="52", "URC"="53", "URD"="54", "URE"="55",
    "ULA"="61", "ULB"="62", "ULC"="63", "ULD"="64", "ULE"="65",
    "LLA"="71", "LLB"="72", "LLC"="73", "LLD"="74", "LLE"="75",
    "LRA"="81", "LRB"="82", "LRC"="83", "LRD"="84", "LRE"="85"
  )

  parsed <- parse_notation(alpha_clean)
  is_alpha <- !is.na(parsed$notation) & parsed$notation == "Alphanumeric"

  results <- rep(NA_character_, length(alpha_clean))
  results[is_alpha] <- map[alpha_clean[is_alpha]]

  # Clear names manually to preserve attributes instead of using unname()
  names(results) <- NULL

  # Mark output explicitly as FDI to avoid re‑introducing ambiguity downstream
  attr(results, "ambiguous_as") <- "FDI"

  return(results)
}
