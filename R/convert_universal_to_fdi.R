#' Convert Universal notation to FDI notation
#'
#' Converts Universal permanent (1–32) and primary (A–T)
#' tooth notation into FDI notation (11-18, 21-28, 31-38, 41–48 for permanent,
#' 51-55, 61-65, 71-75, 81–85 for primary).
#'
#' @param universal A numeric or character vector with Universal tooth codes.
#' @return A character vector with FDI notation. Invalid codes return NA.
#'   The returned vector carries the attribute `ambiguous_as = "FDI"`.
#'
#' @examples
#' # Convert Universal codes to FDI notation and print the output
#' universal_codes <- c("8", "9", "30")
#' fdi_codes <- convert_universal_to_fdi(universal_codes)
#' fdi_codes
#'
#' @export
convert_universal_to_fdi <- function(universal) {

  # Guard clause for empty or NULL inputs
  if (is.null(universal) || length(universal) == 0) {
    return(character(0))
  }

  universal_clean <- toupper(as.character(universal))

  # Permanent teeth mapping
  perm_map <- c(
    # UR (1–8 → 18–11)
    "8"="11","7"="12","6"="13","5"="14","4"="15","3"="16","2"="17","1"="18",

    # UL (9–16 → 21–28)
    "9"="21","10"="22","11"="23","12"="24","13"="25","14"="26","15"="27","16"="28",

    # LL (17–24 → 38–31)
    "24"="31","23"="32","22"="33","21"="34","20"="35","19"="36","18"="37","17"="38",

    # LR (25–32 → 41–48)
    "25"="41","26"="42","27"="43","28"="44","29"="45","30"="46","31"="47","32"="48"
  )

  # Primary teeth mapping
  primary_map <- c(
    # UR (A–E → 55–51)
    "A"="55","B"="54","C"="53","D"="52","E"="51",

    # UL (F–J → 61–65)
    "F"="61","G"="62","H"="63","I"="64","J"="65",

    # LL (K–O → 75–71)
    "K"="75","L"="74","M"="73","N"="72","O"="71",

    # LR (P–T → 81–85)
    "P"="81","Q"="82","R"="83","S"="84","T"="85"
  )

  full_map <- c(perm_map, primary_map)

  out <- full_map[universal_clean]
  out <- as.character(out)

  # Strip names manually so it doesn't wipe out attributes downstream
  names(out) <- NULL

  # The entire output vector is now strictly in FDI format.
  # We mark it as "FDI" to protect any ambiguous values (11-18, 21-28, 31-32)
  # from being misparsed as Universal later on.
  attr(out, "ambiguous_as") <- "FDI"

  return(out)
}
