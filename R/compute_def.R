#' Compute d-e-f index (Decayed, Extracted, Filled) for primary teeth
#'
#' Calculates the d-e-f index for primary dentition using FDI notation
#' (51–55, 61–65, 71–75, 81–85). The function validates that each patient
#' presents a complete primary dentition from second molar to second molar.
#' Patients with permanent teeth, missing primary teeth, or non‑FDI notations
#' are omitted from the calculation.
#'
#' @param data A data frame containing \code{patient_id}, \code{tooth}, and
#'   binary columns \code{D}, \code{E}, and \code{F}.
#'
#' @return A tibble with \code{patient_id} and \code{def}, containing only
#'   patients with valid and complete primary dentition.
#'
#' @examples
#' # Create a compliant 20-tooth dataset for 2 pediatric patients
#' primary_teeth <- as.character(c(51:55, 61:65, 71:75, 81:85))
#' full_primary_data <- dplyr::tibble(
#'   patient_id = rep(c("PED_001", "PED_002"), each = 20),
#'   tooth      = rep(primary_teeth, 2),
#'   D          = dplyr::if_else(patient_id == "PED_001" & tooth == "51", 1, 0),
#'   E          = dplyr::if_else(patient_id == "PED_001" & tooth == "64", 1, 0),
#'   F          = dplyr::if_else(patient_id == "PED_002" & tooth == "75", 1, 0)
#' )
#'
#' # Compute the def index
#' compute_def(full_primary_data)
#'
#'
#' @export
compute_def <- function(data) {

  required_cols <- c("patient_id", "tooth", "D", "E", "F")
  missing_cols <- setdiff(required_cols, names(data))
  if (length(missing_cols) > 0) {
    stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
  }

  valid_fdi_primary   <- as.character(c(51:55, 61:65, 71:75, 81:85))
  valid_fdi_permanent <- as.character(c(11:18, 21:28, 31:38, 41:48))

  universal_perm    <- as.character(1:32)
  universal_primary <- LETTERS[1:20]

  alpha_perm    <- paste0(rep(c("UR","UL","LR","LL"), each = 8), 1:8)
  alpha_primary <- paste0(rep(c("UR","UL","LR","LL"), each = 5), LETTERS[1:5])

  required_primary <- valid_fdi_primary

  patients <- unique(data$patient_id)
  results_list <- list()
  error_list <- list()

  for (pid in patients) {

    pdata <- data[data$patient_id == pid, ]
    teeth <- as.character(pdata$tooth)

    is_perm <- teeth %in% c(valid_fdi_permanent, universal_perm, alpha_perm)
    if (any(is_perm)) {
      error_list[[as.character(pid)]] <- "Permanent teeth detected. DEF is for primary teeth only."
      next
    }

    is_non_fdi_primary <- teeth %in% c(universal_primary, alpha_primary)
    if (any(is_non_fdi_primary)) {
      error_list[[as.character(pid)]] <- "Non-FDI primary notation detected. Use FDI."
      next
    }

    if (!all(teeth %in% valid_fdi_primary)) {
      bad <- unique(teeth[!teeth %in% valid_fdi_primary])
      error_list[[as.character(pid)]] <- paste0("Invalid FDI primary teeth: ", paste(bad, collapse = ", "))
      next
    }

    missing_teeth <- setdiff(required_primary, teeth)
    if (length(missing_teeth) > 0) {
      error_list[[as.character(pid)]] <- paste0(
        "Incomplete primary dentition; missing teeth: ",
        paste(missing_teeth, collapse = ", ")
      )
      next
    }

    def_matrix <- as.matrix(pdata[, c("D", "E", "F")])
    if (!all(def_matrix %in% c(0, 1, NA))) {
      error_list[[as.character(pid)]] <- "D, E, and F values must be 0 or 1."
      next
    }

    if (any(rowSums(def_matrix, na.rm = TRUE) > 1)) {
      error_list[[as.character(pid)]] <- "D/E/F are mutually exclusive per tooth."
      next
    }

    results_list[[as.character(pid)]] <- tibble::tibble(
      patient_id = pid,
      def = as.integer(sum(pdata$D, pdata$E, pdata$F, na.rm = TRUE))
    )
  }

  if (length(results_list) == 0) {
    results <- tibble::tibble(patient_id = character(), def = integer())
  } else {
    results <- dplyr::bind_rows(results_list)
  }

  if (length(error_list) > 0) {
    warning(
      "Some patients were omitted due to invalid DEF data:\n",
      paste(paste0("- Patient ", names(error_list), ": ", error_list), collapse = "\n"),
      call. = FALSE
    )
  }

  return(results)
}
