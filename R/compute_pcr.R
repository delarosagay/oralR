#' Compute Plaque Control Record (PCR, O'Leary index)
#'
#' Calculates the Plaque Control Record (PCR) per patient as the percentage
#' of surfaces with plaque. Each tooth must have exactly four sites: M, D, B, and L.
#'
#' @param data A data frame (ideally processed by \code{tidy_dental}).
#' @return A tibble with \code{patient_id}, \code{total_points},
#'    \code{plaque_points}, and \code{pcr_percent}.
#' @export
compute_pcr <- function(data) {

  # 1. Validate structure (handles 'plaque' or 'value' columns automatically)
  validate_index_input(data, "PCR")

  # 2. Identify the value column (support both raw and tidy formats)
  val_col <- if ("value" %in% names(data)) "value" else "plaque"

  # 3. Clean and Normalize
  data <- data[!is.na(data[[val_col]]) & !is.na(data$tooth_side), ]
  data$tooth_side <- toupper(as.character(data$tooth_side))

  # 4. Process each patient
  patients <- unique(data$patient_id)
  results_list <- list()
  error_list <- list()

  # Valid FDI teeth (Permanent + Primary)
  valid_fdi <- as.character(c(11:18, 21:28, 31:38, 41:48, 51:55, 61:65, 71:75, 81:85))

  for (pid in patients) {
    pdata <- data[data$patient_id == pid, ]
    pdata$tooth <- as.character(pdata$tooth)

    # 4a. Validate FDI range
    if (!all(pdata$tooth %in% valid_fdi)) {
      bad <- unique(pdata$tooth[!pdata$tooth %in% valid_fdi])
      error_list[[as.character(pid)]] <- paste0(
        "Invalid FDI tooth numbers: ", paste(bad, collapse = ", ")
      )
      next
    }

    # 4b. Check for duplicated sites
    dups <- pdata %>%
      dplyr::count(tooth, tooth_side) %>%
      dplyr::filter(n > 1)

    if (nrow(dups) > 0) {
      error_list[[as.character(pid)]] <- "Duplicated tooth-side entries detected."
      next
    }

    # 4c. Verify 4-site requirement per tooth (PCR standard)
    site_counts <- pdata %>%
      dplyr::count(tooth) %>%
      dplyr::filter(n != 4)

    if (nrow(site_counts) > 0) {
      error_list[[as.character(pid)]] <- paste0(
        "Teeth with incorrect site counts (must be 4): ",
        paste(site_counts$tooth, collapse = ", ")
      )
      next
    }

    # 4d. Calculation
    results_list[[as.character(pid)]] <- pdata %>%
      dplyr::summarise(
        patient_id = pid,
        total_points = dplyr::n(),
        plaque_points = sum(.data[[val_col]]),
        pcr_percent = (plaque_points / total_points) * 100
      )
  }

  # 5. Finalize
  if (length(results_list) == 0) {
    results <- dplyr::tibble(
      patient_id = character(),
      total_points = integer(),
      plaque_points = numeric(),
      pcr_percent = numeric()
    )
  } else {
    results <- dplyr::bind_rows(results_list)
  }

  # 6. Issue warnings for omitted data
  if (length(error_list) > 0) {
    warning(
      "Some patients were omitted due to invalid data:\n",
      paste(paste0("- Patient ", names(error_list), ": ", error_list), collapse = "\n"),
      call. = FALSE
    )
  }

  return(results)
}
