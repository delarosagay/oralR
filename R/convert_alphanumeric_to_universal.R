#' Convert alphanumeric notation (UR/UL/LL/LR) to Universal notation
#'
#' This function converts alphanumeric permanent teeth (UR/UL/LL/LR + 1–8)
#' and primary teeth (UR/UL/LL/LR + A–E) into Universal notation:
#' 1–32 for permanent teeth and A–T for primary teeth.
#'
#' Invalid or unrecognized alphanumeric codes return NA.
#'
#' @param alpha A character vector containing alphanumeric tooth codes.
#'
#' @return A character vector with Universal notation. Invalid codes return NA.
#'   The returned vector carries the attribute `ambiguous_as = "Universal"`.
#'
#' @examples
#' convert_alphanumeric_to_universal(c("UR1", "UL6", "LL3"))
#' convert_alphanumeric_to_universal(c("URE", "LRA"))
#'
#' @export
convert_alphanumeric_to_universal <- function(alpha) {

  # Handle empty input
  if (is.null(alpha) || length(alpha) == 0) {
    return(character(0))
  }

  alpha_clean <- toupper(as.character(alpha))

  # Permanent teeth mapping (Universal: 1 to 32)
  perm_map <- c(
    "UR8"="1", "UR7"="2", "UR6"="3", "UR5"="4", "UR4"="5", "UR3"="6", "UR2"="7", "UR1"="8",
    "UL1"="9", "UL2"="10", "UL3"="11", "UL4"="12", "UL5"="13", "UL6"="14", "UL7"="15", "UL8"="16",
    "LL8"="17", "LL7"="18", "LL6"="19", "LL5"="20", "LL4"="21", "LL3"="22", "LL2"="23", "LL1"="24",
    "LR1"="25", "LR2"="26", "LR3"="27", "LR4"="28", "LR5"="29", "LR6"="30", "LR7"="31", "LR8"="32"
  )

  # Primary teeth mapping (Universal: A to T)
  primary_map <- c(
    "URE"="A", "URD"="B", "URC"="C", "URB"="D", "URA"="E",
    "ULA"="F", "ULB"="G", "ULC"="H", "ULD"="I", "ULE"="J",
    "LLE"="K", "LLD"="L", "LLC"="M", "LLB"="N", "LLA"="O",
    "LRA"="P", "LRB"="Q", "LRC"="R", "LRD"="S", "LRE"="T"
  )

  full_map <- c(perm_map, primary_map)

  valid_pattern <- "^(UR|UL|LL|LR)([1-8]|[A-E])$"
  is_valid <- grepl(valid_pattern, alpha_clean)

  out <- rep(NA_character_, length(alpha_clean))
  out[is_valid] <- full_map[alpha_clean[is_valid]]

  # Clear names manually to preserve attributes instead of using unname()
  names(out) <- NULL

  # Mark output explicitly as Universal for downstream safety
  attr(out, "ambiguous_as") <- "Universal"

  return(out)
}
