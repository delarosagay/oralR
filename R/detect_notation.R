#' Detect possible dental notation systems
#'
#' Evaluates a character string or numeric value to determine which dental
#' notation systems it might belong to: FDI, Universal, or Alphanumeric.
#' If the vector carries a resolving attribute from downstream handling
#' (e.g., from \code{handle_ambiguous_notation}), that specific notation
#' is strictly enforced for all overlapping ambiguous codes.
#'
#' @param x A character vector or numeric vector containing dental codes.
#'
#' @return A list of character vectors containing matching systems ("FDI", "Universal", or "Alphanumeric").
#'
#' @examples
#' detect_notation("UR1")   # Returns "Alphanumeric"
#' detect_notation("11")    # Returns c("Universal", "FDI")
#' detect_notation("A")     # Returns "Universal"
#'
#' # Using handle_ambiguous_notation to enforce a strict system
#' x <- handle_ambiguous_notation(c("11", "24", "36"), action = "as_fdi")
#' detect_notation(x)       # Enforces "FDI" for the ambiguous 11 and 24 codes
#'
#' @export
detect_notation <- function(x) {
  # Handle NULL or empty input
  if (is.null(x) || length(x) == 0) {
    return(list())
  }

  # Capture explicit notation overrides from attributes
  forced_notation <- attr(x, "ambiguous_as")

  # Generate baseline anatomical detection list
  raw_detection <- lapply(x, detect_notation_single)

  # If an attribute is present, override overlapping ambiguous elements
  if (!is.null(forced_notation)) {
    ambiguous_universal <- as.character(c(1:18, 21:28, 31:32))

    raw_detection <- lapply(seq_along(x), function(i) {
      tooth <- toupper(trimws(as.character(x[i])))

      # Enforce the resolved notation if the code is in the collision range
      if (!is.na(tooth) && tooth %in% ambiguous_universal) {
        return(forced_notation)
      }
      return(raw_detection[[i]])
    })
  }

  return(raw_detection)
}

#' @keywords internal
detect_notation_single <- function(x) {
  # Handle NA or empty strings
  if (is.na(x) || as.character(x) == "") {
    return(character(0))
  }

  x_str <- toupper(trimws(as.character(x)))
  systems <- character(0)

  # 1. Alphanumeric
  # Matches UR/UL/LL/LR followed by 1-8 (permanent) or A-E (primary)
  if (grepl("^(UR|UL|LL|LR)([1-8]|[A-E])$", x_str)) {
    systems <- c(systems, "Alphanumeric")
  }

  # 2. Universal (Primary letters A through T)
  if (grepl("^[A-T]$", x_str)) {
    systems <- c(systems, "Universal")
  }

  # 3. Numeric analysis (FDI and Universal permanent)
  if (grepl("^[0-9]+$", x_str)) {
    n <- as.integer(x_str)

    # Universal Permanent: 1 to 32
    if (!is.na(n) && n >= 1 && n <= 32) {
      systems <- c(systems, "Universal")
    }

    # FDI Permanent: Quadrants 1-4, tooth positions 1-8
    is_fdi_perm <- grepl("^[1-4][1-8]$", x_str)

    # FDI Primary: Quadrants 5-8, tooth positions 1-5
    is_fdi_temp <- grepl("^[5-8][1-5]$", x_str)

    if (is_fdi_perm || is_fdi_temp) {
      systems <- c(systems, "FDI")
    }
  }

  return(unique(systems))
}

