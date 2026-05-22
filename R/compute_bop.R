#' Compute Bleeding on Probing (BOP) index
#'
#' Calculates the Bleeding on Probing (BOP) index per patient as the percentage
#' of bleeding sites. Each present tooth must have exactly six sites:
#' MB, B, DB, ML, L, and DL.
#'
#' @param data A data frame (ideally processed by \code{tidy_dental}).
#' @return A tibble with \code{patient_id}, \code{total_points},
#'    \code{bleeding_points}, and \code{bop_percent}.
#' @export
compute_bop <- function(data) {

  # 1. Validate structure (handles 'bop' or 'value' columns automatically)
  validate_index_input(data, "BOP")

  # 2. Identify the value column (support both raw and tidy formats)
  val_col <- if ("value" %in% names(data)) "value" else "bop"

  # 3. Clean and Normalize
  # Remove NAs and ensure tooth_side is uppercase
  data <- data[!is.na(data[[val_col]]) & !is.na(data$tooth_side), ]
  data$tooth_side <- toupper(as.character(data$tooth_side))

  # 4. Process each patient
  patients <- unique(data$patient_id)
  results_list <- list()
  error_list <- list()

  # Valid FDI teeth (Permanent only)
  valid_fdi <- as.character(c(11:18, 21:28, 31:38, 41:48))

  for (pid in patients) {
    pdata <- data[data$patient_id == pid, ]

    # 4a. Validate tooth notation and FDI range
    pdata$tooth <- as.character(pdata$tooth)

    if (!all(pdata$tooth %in% valid_fdi)) {
      bad <- unique(pdata$tooth[!pdata$tooth %in% valid_fdi])
      error_list[[as.character(pid)]] <- paste0(
        "Invalid or non-permanent FDI teeth: ", paste(bad, collapse = ", ")
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

    # 4c. Verify 6-site requirement per tooth
    site_counts <- pdata %>%
      dplyr::count(tooth) %>%
      dplyr::filter(n != 6)

    if (nrow(site_counts) > 0) {
      error_list[[as.character(pid)]] <- paste0(
        "Teeth with incorrect site counts (must be 6): ",
        paste(site_counts$tooth, collapse = ", ")
      )
      next
    }

    # 4d. Calculation
    results_list[[as.character(pid)]] <- pdata %>%
      dplyr::summarise(
        patient_id = pid,
        total_points = dplyr::n(),
        bleeding_points = sum(.data[[val_col]]),
        bop_percent = (bleeding_points / total_points) * 100
      )
  }

  # 5. Finalize (Return empty tibble if no valid data remains)
  if (length(results_list) == 0) {
    results <- dplyr::tibble(
      patient_id = character(),
      total_points = integer(),
      bleeding_points = numeric(),
      bop_percent = numeric()
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
