#' Convert FDI notation to alphanumeric notation (UR/UL/LL/LR)
#'
#' Converts permanent and primary FDI notation into alphanumeric notation.
#'
#' @param fdi A numeric or character vector with FDI tooth codes.
#' @return A character vector with alphanumeric notation. Invalid codes return NA.
#' @export
convert_fdi_to_alphanumeric <- function(fdi) {

  # Handle NULL or empty input early
  if (is.null(fdi) || length(fdi) == 0) {
    return(character(0))
  }

  # Normalize input to character and remove potential whitespace
  fdi_clean <- trimws(as.character(fdi))

  # Permanent teeth mapping (FDI 11–48)
  perm_map <- c(
    "11"="UR1","12"="UR2","13"="UR3","14"="UR4","15"="UR5","16"="UR6","17"="UR7","18"="UR8",
    "21"="UL1","22"="UL2","23"="UL3","24"="UL4","25"="UL5","26"="UL6","27"="UL7","28"="UL8",
    "31"="LL1","32"="LL2","33"="LL3","34"="LL4","35"="LL5","36"="LL6","37"="LL7","38"="LL8",
    "41"="LR1","42"="LR2","43"="LR3","44"="LR4","45"="LR5","46"="LR6","47"="LR7","48"="LR8"
  )

  # Primary teeth mapping (FDI 51–85)
  primary_map <- c(
    "51"="URA","52"="URB","53"="URC","54"="URD","55"="URE",
    "61"="ULA","62"="ULB","63"="ULC","64"="ULD","65"="ULE",
    "71"="LLA","72"="LLB","73"="LLC","74"="LLD","75"="LLE",
    "81"="LRA","82"="LRB","83"="LRC","84"="LRD","85"="LRE"
  )

  full_map <- c(perm_map, primary_map)

  # Direct lookup
  out <- full_map[fdi_clean]

  # Ensure the result is a character vector and clean up names
  out <- as.character(out)
  unname(out)
}
