#' Normalize d‑e‑f Format
#'
#' Standardizes primary‑tooth caries data into a validated binary format with
#' mutually exclusive columns \code{D}, \code{E}, and \code{F}. The function
#' accepts exactly one of the following input formats:
#'
#' \itemize{
#'   \item A binary format containing columns \code{D}, \code{E}, and \code{F}.
#'   \item A single-column format \code{status} with values:
#'         \code{"D"} (decayed), \code{"E"} (extracted), \code{"F"} (filled),
#'         \code{"S"} (sound), or \code{NA}. Lowercase values are accepted and
#'         automatically converted to uppercase.
#' }
#'
#' If both systems are present simultaneously, the function raises an error.
#' The output always contains validated and mutually exclusive binary columns
#' \code{D}, \code{E}, and \code{F}, suitable for downstream computation of the
#' d‑e‑f index using \code{compute_def()}.
#'
#' @param data A data frame containing at least \code{patient_id} and
#'   \code{tooth}, plus either:
#'   \itemize{
#'     \item Columns \code{D}, \code{E}, \code{F}, or
#'     \item A column \code{status}.
#'   }
#'
#' @return A tibble with columns \code{patient_id}, \code{tooth}, \code{D},
#'   \code{E}, and \code{F}, with validated and mutually exclusive values.
#'
#' @examples
#' # Status format
#' df <- tibble::tibble(
#'   patient_id = 1,
#'   tooth = c("51", "52", "53"),
#'   status = c("d", "S", "f")
#' )
#' normalize_def_format(df)
#'
#' # Binary format
#' df2 <- tibble::tibble(
#'   patient_id = 1,
#'   tooth = c("51", "52", "53"),
#'   D = c(1, 0, 0),
#'   E = c(0, 0, 0),
#'   F = c(0, 0, 1)
#' )
#' normalize_def_format(df2)
#'
#' @export
normalize_def_format <- function(data) {

  if (!all(c("patient_id", "tooth") %in% names(data))) {
    stop("Input must contain 'patient_id' and 'tooth' columns.")
  }

  has_binary <- all(c("D", "E", "F") %in% names(data))
  has_status <- "status" %in% names(data)

  if (has_binary && has_status) {
    stop("Input cannot contain both D/E/F columns and a 'status' column. Use only one system.")
  }


  # CASE 1: Binary format

  if (has_binary) {

    if (!all(as.matrix(data[, c("D", "E", "F")]) %in% c(0, 1, NA))) {
      stop("Columns D, E, and F must contain only 0, 1, or NA.")
    }

    if (any(rowSums(data[, c("D", "E", "F")], na.rm = TRUE) > 1)) {
      stop("Columns D, E, and F must be mutually exclusive per tooth.")
    }

    return(dplyr::as_tibble(data[, c("patient_id", "tooth", "D", "E", "F")]))
  }


  # CASE 2: Status format

  if (has_status) {

    data$status <- toupper(data$status)

    valid_codes <- c("D", "E", "F", "S", NA)

    if (!all(data$status %in% valid_codes)) {
      stop("Invalid status codes detected. Allowed: 'D', 'E', 'F', 'S', NA.")
    }

    data$D <- ifelse(data$status == "D", 1, 0)
    data$E <- ifelse(data$status == "E", 1, 0)
    data$F <- ifelse(data$status == "F", 1, 0)

    data$D[is.na(data$status)] <- 0
    data$E[is.na(data$status)] <- 0
    data$F[is.na(data$status)] <- 0

    return(dplyr::as_tibble(data[, c("patient_id", "tooth", "D", "E", "F")]))
  }

  stop("Input must contain either D/E/F columns or a 'status' column.")
}
