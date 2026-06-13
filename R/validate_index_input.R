#' Validate Input Structure for Periodontal Indices
#'
#' Internal utility to ensure dataset validity before computing BOP, PCR, or PI.
#' The function checks structural requirements, validates periodontal surface
#' names, normalizes common clinical synonyms (V → B, P → L), and ensures that
#' clinical values fall within the expected ranges for each index.
#'
#' Supported surfaces (case-insensitive):
#'   MB, B, DB, ML, L, DL
#'   V → B, P → L
#'   MV → MB, DV → DB, MP → ML, DP → DL
#'
#' @param data A data frame or tibble.
#' @param index A character string: "BOP", "PCR", or "PI".
#'
#' @examples
#' # Example 1: Correct dataset for PCR (returns TRUE invisibly)
#' valid_pcr <- dplyr::tibble(
#'   patient_id = rep("PAT_01", 4),
#'   tooth      = rep("11", 4),
#'   tooth_side = c("M", "D", "V", "P"),
#'   value      = c(0, 1, 0, 1)
#' )
#' validate_index_input(valid_pcr, index = "PCR")
#'
#' @export
validate_index_input <- function(data, index) {

  index <- toupper(index)

  # Determine the value column
  value_col <- if ("value" %in% names(data)) {
    "value"
  } else {
    switch(index,
           "BOP" = "bop",
           "PCR" = "plaque",
           "PI"  = "plaque",
           stop("Unknown index type: Use 'BOP', 'PCR', or 'PI'."))
  }

  # Required columns
  required_cols <- c("patient_id", "tooth", "tooth_side", value_col)
  missing <- setdiff(required_cols, names(data))
  if (length(missing) > 0) {
    stop("Missing required columns for ", index, ": ",
         paste(missing, collapse = ", "))
  }

  # Normalize surfaces
  ts <- toupper(as.character(data$tooth_side))

  # Synonym normalization
  ts[ts == "V"]  <- "B"
  ts[ts == "P"]  <- "L"
  ts[ts == "MV"] <- "MB"
  ts[ts == "DV"] <- "DB"
  ts[ts == "MP"] <- "ML"
  ts[ts == "DP"] <- "DL"

  data$tooth_side <- ts

  # Allowed surfaces
  valid_sides <- c("M","D","B","L","MB","DB","ML","DL")

  actual_sides <- unique(stats::na.omit(ts))
  invalid_found <- setdiff(actual_sides, valid_sides)

  if (length(invalid_found) > 0) {
    stop("Invalid tooth_side values for ", index, ": ",
         paste(invalid_found, collapse = ", "),
         ". Allowed: ", paste(valid_sides, collapse = ", "))
  }

  # Validate duplicate records for the same tooth surface
  # A patient cannot have the same side of the same tooth recorded twice
  dup_rows <- duplicated(data[, c("patient_id", "tooth", "tooth_side")])
  if (any(dup_rows)) {
    dups <- data[dup_rows, c("patient_id", "tooth", "tooth_side")]
    dups_summary <- unique(paste0("Patient ", dups$patient_id, ": Tooth ", dups$tooth, " side '", dups$tooth_side, "'"))
    stop("Duplicate tooth surfaces detected for ", index, ":\n",
         paste("- ", dups_summary, collapse = "\n"))
  }

  # Validate numeric ranges
  vals <- data[[value_col]]
  non_na_vals <- vals[!is.na(vals)]

  if (index %in% c("BOP", "PCR")) {
    if (any(!non_na_vals %in% c(0, 1))) {
      stop(index, " values must be binary (0 or 1).")
    }
  }

  if (index == "PI") {
    if (any(!non_na_vals %in% 0:3)) {
      stop("PI values must be integers between 0 and 3 (Silness-Loe).")
    }
  }

  invisible(TRUE)
}

