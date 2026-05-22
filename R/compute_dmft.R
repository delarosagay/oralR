#' Compute DMFT index (Decayed, Missing, Filled Teeth)
#'
#' Calculates the DMFT index per patient. DMFT is the sum of decayed (D),
#' missing (M), and filled (F) permanent teeth. The index is defined only for
#' permanent dentition and requires a complete set of permanent teeth from
#' second molar to second molar (FDI 11–17, 21–27, 31–37, 41–47). Third molars
#' (18, 28, 38, 48) are optional: if present, they are included in the
#' calculation, but they are not required for completeness.
#'
#' @param data A data frame containing \code{patient_id}, \code{tooth}, and
#'   binary columns \code{D}, \code{M}, and \code{F}.
#'
#' @return A tibble with \code{patient_id} and \code{dmft}. Patients with
#'   invalid or incomplete data are omitted with a warning.
#'
#' @export
compute_dmft <- function(data) {

  # 1. Basic validation of required columns
  required_cols <- c("patient_id", "tooth", "D", "M", "F")
  missing_cols <- setdiff(required_cols, names(data))

  if (length(missing_cols) > 0) {
    stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
  }

  # 2. Define dentition sets
  required_perm <- as.character(c(11:17, 21:27, 31:37, 41:47))  # mandatory teeth
  optional_perm <- as.character(c(18, 28, 38, 48))              # third molars
  valid_perm <- c(required_perm, optional_perm)

  primary_teeth <- as.character(c(51:55, 61:65, 71:75, 81:85))

  # 3. Process patients
  patients <- unique(data$patient_id)
  results_list <- list()
  error_list <- list()

  for (pid in patients) {

    pdata <- data[data$patient_id == pid, ]
    pdata$tooth <- as.character(pdata$tooth)

    # 3a. Reject primary teeth
    if (any(pdata$tooth %in% primary_teeth)) {
      error_list[[as.character(pid)]] <- "Primary teeth detected; DMFT applies only to permanent dentition."
      next
    }

    # 3b. Reject invalid FDI codes
    if (!all(pdata$tooth %in% valid_perm)) {
      bad <- unique(pdata$tooth[!pdata$tooth %in% valid_perm])
      error_list[[as.character(pid)]] <- paste0("Invalid permanent FDI codes: ", paste(bad, collapse = ", "))
      next
    }

    # 3c. Check completeness of required permanent dentition
    missing_required <- setdiff(required_perm, pdata$tooth)
    if (length(missing_required) > 0) {
      error_list[[as.character(pid)]] <- paste0(
        "Incomplete permanent dentition; missing teeth: ",
        paste(missing_required, collapse = ", ")
      )
      next
    }

    # 3d. Validate D/M/F values
    dmf <- pdata[, c("D", "M", "F")]
    if (!all(as.matrix(dmf) %in% c(0, 1, NA))) {
      error_list[[as.character(pid)]] <- "D, M, and F values must be 0 or 1."
      next
    }

    # 3e. Exclusivity check
    if (any(rowSums(dmf, na.rm = TRUE) > 1)) {
      error_list[[as.character(pid)]] <- "D, M, and F must be mutually exclusive per tooth."
      next
    }

    # 3f. Compute DMFT
    dmft_value <- sum(pdata$D, pdata$M, pdata$F, na.rm = TRUE)

    results_list[[as.character(pid)]] <- tibble::tibble(
      patient_id = pid,
      dmft = as.integer(dmft_value)
    )
  }

  # 4. Assemble results
  if (length(results_list) == 0) {
    results <- tibble::tibble(patient_id = character(), dmft = integer())
  } else {
    results <- dplyr::bind_rows(results_list)
  }

  # 5. Warning for omitted patients
  if (length(error_list) > 0) {
    warning(
      "Some patients were omitted due to invalid DMFT data:\n",
      paste(paste0("- Patient ", names(error_list), ": ", error_list), collapse = "\n"),
      call. = FALSE
    )
  }

  return(results)
}

