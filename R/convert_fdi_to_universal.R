#' Convert FDI tooth notation to Universal tooth notation
#'
#' Converts permanent and primary FDI tooth notation into the Universal Numbering System.
#' Invalid or unrecognized codes are safely coerced to \code{NA}.
#'
#' @param fdi A numeric or character vector containing FDI tooth codes.
#'
#' @return A character vector with Universal notation. Invalid codes return NA.
#'   The returned vector carries the attribute \code{ambiguous_as = "Universal"}.
#'
#' @examples
#' convert_fdi_to_universal(c(11, 21, 36))
#' convert_fdi_to_universal(c("51", "85"))
#'
#' @export
convert_fdi_to_universal <- function(fdi) {

  if (is.null(fdi) || length(fdi) == 0) {
    return(character(0))
  }

  fdi_clean <- as.character(fdi)

  perm_map <- c(
    "11"="8",  "12"="7",  "13"="6",  "14"="5",  "15"="4",  "16"="3",  "17"="2",  "18"="1",
    "21"="9",  "22"="10", "23"="11", "24"="12", "25"="13", "26"="14", "27"="15", "28"="16",
    "31"="24", "32"="23", "33"="22", "34"="21", "35"="20", "36"="19", "37"="18", "38"="17",
    "41"="25", "42"="26", "43"="27", "44"="28", "45"="29", "46"="30", "47"="31", "48"="32"
  )

  primary_map <- c(
    "51"="E", "52"="D", "53"="C", "54"="B", "55"="A",
    "61"="F", "62"="G", "63"="H", "64"="I", "65"="J",
    "71"="O", "72"="N", "73"="M", "74"="L", "75"="K",
    "81"="P", "82"="Q", "83"="R", "84"="S", "85"="T"
  )

  full_map <- c(perm_map, primary_map)

  out <- full_map[fdi_clean]
  out <- as.character(out)

  # Strip names manually to protect attributes from R's internal behaviors
  names(out) <- NULL

  # The output vector is now strictly in Universal format. We stamp it
  # as "Universal" to ensure any numbers in the ambiguous ranges (11-18, 21-28, 31-32)
  # are correctly handled as Universal downstream.
  attr(out, "ambiguous_as") <- "Universal"

  return(out)
}

