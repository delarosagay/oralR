#' Convert Universal notation to alphanumeric notation (UR/UL/LL/LR)
#'
#' This function converts Universal permanent (1–32) and primary (A–T)
#' tooth notation into alphanumeric notation (UR/UL/LL/LR + 1–8 or A–E).
#'
#' @param universal A numeric or character vector with Universal tooth codes.
#' @return A character vector with alphanumeric notation. Invalid codes return NA.
#' @export
convert_universal_to_alphanumeric <- function(universal) {

  # Handle NULL or empty inputs to prevent type errors
  if (is.null(universal) || length(universal) == 0) {
    return(character(0))
  }

  universal_clean <- toupper(as.character(universal))

  # Permanent teeth mapping
  perm_map <- c(
    # UR
    "1" = "UR8", "2" = "UR7", "3" = "UR6", "4" = "UR5",
    "5" = "UR4", "6" = "UR3", "7" = "UR2", "8" = "UR1",

    # UL
    "9"  = "UL1", "10" = "UL2", "11" = "UL3", "12" = "UL4",
    "13" = "UL5", "14" = "UL6", "15" = "UL7", "16" = "UL8",

    # LL
    "17" = "LL8", "18" = "LL7", "19" = "LL6", "20" = "LL5",
    "21" = "LL4", "22" = "LL3", "23" = "LL2", "24" = "LL1",

    # LR
    "25" = "LR1", "26" = "LR2", "27" = "LR3", "28" = "LR4",
    "29" = "LR5", "30" = "LR6", "31" = "LR7", "32" = "LR8"
  )

  # Primary teeth mapping
  primary_map <- c(
    # UR
    "A" = "URE", "B" = "URD", "C" = "URC", "D" = "URB", "E" = "URA",

    # UL
    "F" = "ULA", "G" = "ULB", "H" = "ULC", "I" = "ULD", "J" = "ULE",

    # LL
    "K" = "LLE", "L" = "LLD", "M" = "LLC", "N" = "LLB", "O" = "LLA",

    # LR
    "P" = "LRA", "Q" = "LRB", "R" = "LRC", "S" = "LRD", "T" = "LRE"
  )

  full_map <- c(perm_map, primary_map)

  out <- full_map[universal_clean]

  out <- as.character(out)

  unname(out)
}
