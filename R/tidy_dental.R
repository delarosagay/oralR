#' Convert dental datasets into a standardized tidy format
#'
#' This function detects and harmonizes multiple dental data formats, including
#' periodontal wide-format structures (tooth column + surface columns),
#' tooth-level wide formats (e.g., "11_MB"), and long-format datasets.
#' It normalizes surface names, converts tooth codes to FDI notation,
#' validates dental integrity, and preserves non-dental variables.
#'
#' @param data A data.frame or tibble containing dental clinical data.
#' @param patient_col Character. Name of the patient identifier column. Default is "patient_id".
#'
#' @return A tibble in standardized long format with columns: patient_id, tooth, tooth_side, value, and others.
#' @importFrom dplyr rename sym mutate select distinct everything all_of
#' @importFrom tidyr pivot_longer separate
#'
#' @examples
#' # Create a raw dataset with alphanumeric, inconsistent tooth codes and wide format surfaces
#' raw_data <- dplyr::tibble(
#'   patient_id = rep(1:3, each = 4),
#'   tooth = c("ur6", "UR6", "UL1", "ll3",
#'             "UR6", "ul1", "LL3", "lr7",
#'             "UR6", "UL1", "LL3", "LR7"),
#'   m = c(1, 0, 1, 0, 1, 1, 0, 0, 0, 1, 1, 0),
#'   d = c(0, 1, 0, 1, 1, 0, 1, 0, 0, 0, 1, 1),
#'   v = c(1, 0, 0, 1, 0, 1, 0, 1, 1, 0, 0, 1),
#'   p = c(0, 1, 1, 0, 1, 0, 0, 1, 1, 1, 0, 0),
#'   examiner = c("A", "A", "B", "B", "A", "B", "A", "A", "B", "B", "A", "B")
#' )
#'
#' # Tidy the dental dataset using explicit package prefix
#' tidy_data <- tidy_dental(raw_data)
#' print(tidy_data)
#'
#' @export
tidy_dental <- function(data, patient_col = "patient_id") {

  # 1. Normalize column names to avoid dot/dash issues in symbols
  names(data) <- gsub("[\\.-]", "_", names(data))
  patient_col_norm <- gsub("[\\.-]", "_", patient_col)

  if (!patient_col_norm %in% names(data)) {
    stop("Column '", patient_col, "' not found in dataset.")
  }

  # 2. Standardize patient identifier column
  if (patient_col_norm != "patient_id") {
    if ("patient_id" %in% names(data)) data$patient_id <- NULL
    data <- dplyr::rename(data, patient_id = !!dplyr::sym(patient_col_norm))
  }

  # 3. Define normalization map for clinical surfaces (e.g., Buccal/Vestibular)
  norm_map <- c(
    "v"="B", "b"="B",
    "p"="L", "l"="L",
    "m"="M", "d"="D",
    "mb"="MB", "db"="DB",
    "ml"="ML", "dl"="DL",
    "mv"="MB", "dv"="DB",
    "mp"="ML", "dp"="DL"
  )
  periodontal_surfaces <- names(norm_map)

  # 4. Structural detection logic
  dental_regex_wide <- "^[A-Za-z0-9]{1,3}_[A-Za-z]{1,2}$"

  # Case: Periodontal wide (Surface names as columns)
  surf_cols <- names(data)[tolower(names(data)) %in% periodontal_surfaces]
  has_periodontal_wide <- length(surf_cols) > 0 && "tooth" %in% names(data)

  # Case: Wide with underscores (e.g., 11_MB, 26_D)
  wide_cols_underscore <- names(data)[vapply(names(data), function(col) {
    if (col %in% c("patient_id", "tooth", "tooth_side", "sextant", "time")) return(FALSE)
    grepl(dental_regex_wide, col)
  }, logical(1))]
  has_wide_underscore <- length(wide_cols_underscore) > 0

  # Basic formats
  has_long <- all(c("tooth", "tooth_side") %in% names(data))
  has_sext <- "sextant" %in% names(data)
  has_tooth_lvl <- "tooth" %in% names(data) && !has_long && !has_periodontal_wide && !has_wide_underscore

  # Safety check for conflicting structures
  if (sum(c(has_long, has_sext, has_tooth_lvl, has_periodontal_wide, has_wide_underscore)) > 1) {
    stop("Mixed dental formats detected. Please ensure the dataset follows a single structural convention.")
  }

  # 5. Internal Validation Helper (Checks for valid FDI/Universal codes)
  validate_teeth <- function(tooth_vector) {
    invalid <- vapply(tooth_vector, function(t) {
      length(detect_notation_single(t)) == 0
    }, logical(1))

    if (any(invalid)) {
      bad_values <- unique(tooth_vector[invalid])
      stop(paste0("Invalid dental codes detected: ", paste(bad_values, collapse = ", ")))
    }
  }

  # 6. Transformation Execution

  # FORMAT: Long or Simple Tooth-Level
  if (has_long | has_tooth_lvl) {
    data$tooth <- .internal_to_fdi(data$tooth)
    validate_teeth(data$tooth)
    return(dplyr::distinct(data))
  }

  # FORMAT: Sextant-based data
  if (has_sext) return(dplyr::distinct(data))

  # FORMAT: Wide with Underscore (e.g., 11_MB)
  if (has_wide_underscore) {
    out <- data %>%
      tidyr::pivot_longer(
        cols = dplyr::all_of(wide_cols_underscore),
        names_to = "raw_col",
        values_to = "value"
      ) %>%
      tidyr::separate(raw_col, into = c("tooth_code", "tooth_side"), sep = "_", fill = "right") %>%
      dplyr::mutate(
        tooth = .internal_to_fdi(tooth_code),
        tooth_side_low = tolower(tooth_side),
        tooth_side = ifelse(tooth_side_low %in% names(norm_map), norm_map[tooth_side_low], toupper(tooth_side))
      )

    validate_teeth(out$tooth)

    return(out %>%
             dplyr::select(patient_id, tooth, tooth_side, value, dplyr::everything()) %>%
             dplyr::select(-tooth_code, -tooth_side_low) %>%
             dplyr::distinct())
  }

  # FORMAT: Periodontal Wide (Column 'tooth' + Surface columns)
  if (has_periodontal_wide) {
    out <- data %>%
      tidyr::pivot_longer(
        cols = dplyr::all_of(surf_cols),
        names_to = "raw_side",
        values_to = "value"
      ) %>%
      dplyr::mutate(
        raw_side_low = tolower(raw_side),
        tooth_side = ifelse(raw_side_low %in% names(norm_map), norm_map[raw_side_low], toupper(raw_side)),
        tooth = .internal_to_fdi(tooth)
      )

    validate_teeth(out$tooth)

    return(out %>%
             dplyr::select(-raw_side, -raw_side_low) %>%
             dplyr::distinct())
  }

  # Default: Return distinct rows if no special format is detected
  return(dplyr::distinct(data))
}
