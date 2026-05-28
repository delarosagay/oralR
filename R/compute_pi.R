#' Compute Plaque Index (PI, Silness and Löe)
#'
#' Calculates the Plaque Index (PI) per patient as the mean score across
#' all examined surfaces, providing the total evaluated sites, the cumulative
#' plaque score, and the final average index. Each tooth must have exactly four
#' sites: M, D, B, and L. Plaque scores must be integers between 0 and 3.
#'
#' @param data A data frame (ideally processed by \code{tidy_dental}).
#' @return A tibble with \code{patient_id}, \code{total_sites}, \code{total_score},
#'   and \code{pi_index}.
#'
#' @examples
#' # Create a compact tidy dataset with valid Plaque Index scores (integers 0-3)
#' mock_pi_data <- dplyr::tibble(
#'   patient_id = rep("PAT_001", 8),
#'   tooth      = rep(c("16", "11"), each = 4),
#'   tooth_side = rep(c("M", "D", "V", "P"), 2),
#'   value      = c(0, 1, 2, 1,  0, 0, 3, 2)  # Clinical scores
#' )
#'
#' # Compute the Plaque Index (PI) summary
#' compute_pi(mock_pi_data)
#'
#' @export
compute_pi <- function(data) {

  # 1. Validate structure (PI allows values 0-3, handled by validate_index_input)
  validate_index_input(data, "PI")

  # 2. Identify the value column
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

    # 4c. Verify 4-site requirement per tooth
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

    # 4d. Calculation (Metrics for Silness-Loe Index)
    results_list[[as.character(pid)]] <- pdata %>%
      dplyr::summarise(
        patient_id  = pid,
        total_sites = dplyr::n(),
        total_score = sum(.data[[val_col]], na.rm = TRUE),
        pi_index    = mean(.data[[val_col]], na.rm = TRUE)
      )
  }

  # 5. Finalize
  if (length(results_list) == 0) {
    results <- dplyr::tibble(
      patient_id  = character(),
      total_sites = integer(),
      total_score = numeric(),
      pi_index    = numeric()
    )
  } else {
    results <- dplyr::bind_rows(results_list)
  }

  # 6. Issue warnings
  if (length(error_list) > 0) {
    warning(
      "Some patients were omitted due to invalid data:\n",
      paste(paste0("- Patient ", names(error_list), ": ", error_list), collapse = "\n"),
      call. = FALSE
    )
  }

  return(results)
}
