#' Handle ambiguous dental notation values
#'
#' Identifies tooth codes that could belong to both FDI and Universal systems
#' (e.g., "11" through "32") and applies a specified action to resolve
#' the ambiguity.
#'
#' @param x A character or numeric vector of tooth codes.
#' @param action Character string specifying how to handle ambiguous values:
#'    \itemize{
#'      \item \code{"keep"}: Returns the vector as is (default).
#'      \item \code{"as_fdi"}: Adds an attribute marking ambiguous values as FDI.
#'      \item \code{"as_universal"}: Adds an attribute marking ambiguous values as Universal.
#'      \item \code{"remove"}: Returns the vector without the ambiguous entries.
#'      \item \code{"na"}: Replaces ambiguous entries with \code{NA}.
#'    }
#'
#' @return A modified version of \code{x}. For \code{"as_fdi"} and
#'    \code{"as_universal"}, the vector includes an attribute \code{ambiguous_as}.
#' @export
handle_ambiguous_notation <- function(x, action = c("keep", "as_fdi", "as_universal", "remove", "na")) {

  action <- match.arg(action)

  if (is.null(x)) return(NULL)
  if (length(x) == 0) return(x)

  # Ensure character for matching
  x_char <- toupper(as.character(x))

  # Ambiguous range:
  # FDI permanent (11-18, 21-28, 31-38, 41-48)
  # overlap with Universal permanent (1-32).
  # The real conflict occurs for numbers 11 through 32.
  ambiguous_values <- as.character(c(11:18, 21:28, 31:32))
  is_ambiguous <- x_char %in% ambiguous_values

  # If no ambiguous values found, just return x (but maybe with the attribute)
  if (!any(is_ambiguous, na.rm = TRUE) && !action %in% c("as_fdi", "as_universal")) {
    return(x)
  }

  # Execute actions
  result <- switch(action,
                   "keep" = x,
                   "na" = {
                     x[is_ambiguous] <- NA
                     x
                   },
                   "remove" = {
                     x[!is_ambiguous]
                   },
                   "as_fdi" = {
                     attr(x, "ambiguous_as") <- "FDI"
                     x
                   },
                   "as_universal" = {
                     attr(x, "ambiguous_as") <- "Universal"
                     x
                   }
  )

  return(result)
}
