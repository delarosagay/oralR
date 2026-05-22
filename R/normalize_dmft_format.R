#' Normalize DMFT Format
#'
#' Converts DMFT data into a standardized binary structure with mutually
#' exclusive columns \code{D}, \code{M}, and \code{F}. The function accepts
#' exactly one of the following input formats:
#'
#' \itemize{
#'   \item A binary format containing columns \code{D}, \code{M}, and \code{F}.
#'   \item A single-column format \code{status} with values:
#'         \code{"D"} (decayed), \code{"M"} (missing), \code{"F"} (filled),
#'         \code{"S"} (sound), or \code{NA}. Lowercase values are accepted and
#'         automatically converted to uppercase.
#' }
#'
#' If both formats are present, the function raises an error. The output always
#' contains validated and mutually exclusive binary columns \code{D}, \code{M},
#' and \code{F}, suitable for downstream computation of DMFT.
#'
#' @param data A data frame containing at least \code{patient_id} and
#'   \code{tooth}. It must include either:
#'   \itemize{
#'     \item Columns \code{D}, \code{M}, \code{F}, or
#'     \item A column \code{status}.
#'   }
#'
#' @return A tibble with columns \code{patient_id}, \code{tooth}, \code{D},
#'   \code{M}, and \code{F}, with validated and mutually exclusive values.
#'
#' @examples
#' # Status format
#' df <- tibble::tibble(
#'   patient_id = 1,
#'   tooth = c("11", "12", "13"),
#'   status = c("d", "S", "f")
#' )
#' normalize_dmft_format(df)
#'
#' # Binary format
#' df2 <- tibble::tibble(
#'   patient_id = 1,
#'   tooth = c("11", "12", "13"),
#'   D = c(1, 0, 0),
#'   M = c(0, 0, 0),
#'   F = c(0, 0, 1)
#' )
#' normalize_dmft_format(df2)
#'
#' @export
normalize_dmft_format <- function(data) {

  # Validate required columns
  if (!all(c("patient_id", "tooth") %in% names(data))) {
    stop("Input must contain 'patient_id' and 'tooth' columns.")
  }

  # Detect formats
  has_binary <- all(c("D", "M", "F") %in% names(data))
  has_status <- "status" %in% names(data)

  if (has_binary && has_status) {
    stop("Input cannot contain both D/M/F columns and a 'status' column. Use only one system.")
  }


  # CASE 1: Binary format

  if (has_binary) {

    # Validate binary values
    if (!all(as.matrix(data[, c("D", "M", "F")]) %in% c(0, 1, NA))) {
      stop("Columns D, M, and F must contain only 0, 1, or NA.")
    }

    # Validate mutual exclusivity
    if (any(rowSums(data[, c("D", "M", "F")], na.rm = TRUE) > 1)) {
      stop("Columns D, M, and F must be mutually exclusive per tooth.")
    }

    return(dplyr::as_tibble(data[, c("patient_id", "tooth", "D", "M", "F")]))
  }


  # CASE 2: Status format

  if (has_status) {

    # Normalize to uppercase
    data$status <- toupper(data$status)

    valid_codes <- c("D", "M", "F", "S", NA)

    if (!all(data$status %in% valid_codes)) {
      stop("Invalid status codes detected. Allowed: 'D', 'M', 'F', 'S', NA.")
    }

    # Convert to binary columns
    data$D <- ifelse(data$status == "D", 1, 0)
    data$M <- ifelse(data$status == "M", 1, 0)
    data$F <- ifelse(data$status == "F", 1, 0)

    # NA status → all zeros
    data$D[is.na(data$status)] <- 0
    data$M[is.na(data$status)] <- 0
    data$F[is.na(data$status)] <- 0

    return(dplyr::as_tibble(data[, c("patient_id", "tooth", "D", "M", "F")]))
  }

  # No valid format detected
  stop("Input must contain either D/M/F columns or a 'status' column.")
}
