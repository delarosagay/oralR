#' Compute Periodontal Screening Index (PSI / CPI)
#'
#' Calculates the Periodontal Screening Index (PSI) per patient. The final score
#' is the maximum value recorded across all sextants. Supports both tooth-level
#' and sextant-level input formats.
#'
#' @param data A data frame containing PSI data.
#' @return A tibble with \code{patient_id} and \code{psi}.
#' @export
compute_psi <- function(data) {

  # 1. Column detection and basic validation
  # Supports both 'psi_code' (standard) and 'psi' (common synonym)
  psi_col <- if ("psi_code" %in% names(data)) {
    "psi_code"
  } else if ("psi" %in% names(data)) {
    "psi"
  } else {
    stop("Missing required column: 'psi_code' or 'psi'.")
  }

  if (!"patient_id" %in% names(data)) {
    stop("Missing required column: 'patient_id'.")
  }

  has_tooth <- "tooth" %in% names(data)
  has_sextant <- "sextant" %in% names(data)

  if (!has_tooth && !has_sextant) {
    stop("Input must contain either 'tooth' or 'sextant' column.")
  }

  # 2. Setup constants (PSI only uses Permanent teeth)
  valid_fdi <- as.character(c(11:18, 21:28, 31:38, 41:48))

  # Map teeth to sextants
  sextant_map <- list(
    "1" = 14:18, "2" = c(11:13, 21:23), "3" = 24:28,
    "4" = 34:38, "5" = c(31:33, 41:43), "6" = 44:48
  )

  # Flatten map for faster lookup
  tooth_to_sextant <- stats::setNames(
    rep(1:6, times = vapply(sextant_map, length, integer(1))),
    unlist(sextant_map)
  )

  # 3. Process each patient
  patients <- unique(data$patient_id)
  results_list <- list()
  error_list <- list()

  for (pid in patients) {
    pdata <- data[data$patient_id == pid, ]
    pdata <- pdata[!is.na(pdata[[psi_col]]), ]

    if (nrow(pdata) == 0) {
      error_list[[as.character(pid)]] <- "No valid PSI values found."
      next
    }

    # Determine mode based on presence of non-NA values in columns
    has_tooth_values   <- has_tooth && any(!is.na(pdata$tooth))
    has_sextant_values <- has_sextant && any(!is.na(pdata$sextant))

    if (!has_tooth_values && !has_sextant_values) {
      error_list[[as.character(pid)]] <- "Both 'tooth' and 'sextant' columns are empty or NA."
      next
    }

    # TOOTH-LEVEL MODE
    if (has_tooth_values) {
      pdata$tooth <- as.character(pdata$tooth)
      # Extract only non-NA entries for checking
      teeth_present <- pdata$tooth[!is.na(pdata$tooth)]

      # Strict FDI validation: IF there are teeth codes, ALL must be valid
      if (!all(teeth_present %in% valid_fdi)) {
        bad_teeth <- unique(teeth_present[!teeth_present %in% valid_fdi])
        error_list[[as.character(pid)]] <- paste0(
          "Invalid FDI tooth numbers: ", paste(bad_teeth, collapse = ", ")
        )
        next
      }

      # Validate PSI values (0-4)
      if (any(pdata[[psi_col]] < 0 | pdata[[psi_col]] > 4)) {
        error_list[[as.character(pid)]] <- "PSI values must be between 0 and 4."
        next
      }

      # Assign sextants internally (optional metadata, but ensures structure)
      pdata$sextant_idx <- tooth_to_sextant[pdata$tooth]
      psi_final <- max(pdata[[psi_col]], na.rm = TRUE)
    }

    # SEXTANT-LEVEL MODE
    else {
      # Extract non-NA sextants
      sextants_present <- pdata$sextant[!is.na(pdata$sextant)]

      # Strict Sextant validation
      if (!all(sextants_present %in% 1:6)) {
        bad_sextants <- unique(sextants_present[!sextants_present %in% 1:6])
        error_list[[as.character(pid)]] <- paste0(
          "Invalid sextant identifiers (must be 1-6): ", paste(bad_sextants, collapse = ", ")
        )
        next
      }

      # Validate PSI values (0-4)
      if (any(pdata[[psi_col]] < 0 | pdata[[psi_col]] > 4)) {
        error_list[[as.character(pid)]] <- "PSI values must be between 0 and 4."
        next
      }

      psi_final <- max(pdata[[psi_col]], na.rm = TRUE)
    }

    # Save valid result
    results_list[[as.character(pid)]] <- tibble::tibble(
      patient_id = pid,
      psi = as.integer(psi_final)
    )
  }

  # 4. Finalize Output
  if (length(results_list) == 0) {
    results <- tibble::tibble(
      patient_id = character(),
      psi = integer()
    )
  } else {
    results <- dplyr::bind_rows(results_list)
  }

  # 5. Issue warnings for omitted data
  if (length(error_list) > 0) {
    warning(
      "Some patients were omitted due to invalid PSI data:\n",
      paste(paste0("- Patient ", names(error_list), ": ", error_list), collapse = "\n"),
      call. = FALSE
    )
  }

  return(results)
}

