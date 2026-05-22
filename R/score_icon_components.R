#' Score ICON components from clinical measurements
#'
#' Converts raw clinical measurements into weighted ICON component scores (0–5)
#' following the Daniels & Richmond (2000) standards.
#'
#' @param data A data frame containing ICON clinical columns.
#' @param max_discrepancy_allowed Maximum allowed mm for crowding/spacing (default 20).
#' @param .on_error One of c("collect", "stop").
#' @param .warn Logical (default FALSE). If TRUE, emits warnings for skipped rows.
#' @return A tibble of component scores or a list including error logs.
#' @importFrom dplyr mutate case_when if_else select tibble
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#' @export
score_icon_components <- function(data,
                                  max_discrepancy_allowed = 20,
                                  .on_error = c("collect", "stop"),
                                  .warn = FALSE) {
  .on_error <- match.arg(.on_error)

  # Internal Helpers
  is_whole_number <- function(x) {
    if (!is.numeric(x)) return(rep(FALSE, length(x)))
    abs(x - round(x)) < .Machine$double.eps^0.5
  }

  coerce_to_logical <- function(x, colname, .warn) {
    if (is.logical(x)) return(x)
    out <- rep(NA, length(x))
    changed <- FALSE
    if (is.numeric(x)) {
      out <- ifelse(is.na(x), NA, x == 1)
      changed <- TRUE
    } else if (is.character(x) || is.factor(x)) {
      xc <- tolower(as.character(x))
      out[xc %in% c("true", "t", "yes", "y", "1")] <- TRUE
      out[xc %in% c("false", "f", "no", "n", "0")] <- FALSE
      changed <- TRUE
    }
    if (changed && isTRUE(.warn)) {
      warning(sprintf("Column '%s' coerced to logical.", colname), call. = FALSE)
    }
    out
  }

  add_error <- function(msg_vec, cond, msg) {
    cond <- !is.na(cond) & cond
    if (any(cond)) {
      sep <- ifelse(nzchar(msg_vec[cond]), " | ", "")
      msg_vec[cond] <- paste0(msg_vec[cond], sep, msg)
    }
    msg_vec
  }

  # Column Validation
  required_cols <- c(
    "patient_id", "time", "aesthetic_component",
    "upper_crowding_mm", "upper_spacing_mm",
    "crossbite", "incisor_openbite_mm",
    "incisor_overbite_category", "buccal_ap_left", "buccal_ap_right"
  )

  missing <- setdiff(required_cols, names(data))
  if (length(missing) > 0) {
    stop("Missing required columns: ", paste(missing, collapse = ", "))
  }

  # Pre-processing
  if (!"impacted_teeth" %in% names(data)) data$impacted_teeth <- FALSE
  data$crossbite <- coerce_to_logical(data$crossbite, "crossbite", .warn)
  data$impacted_teeth <- coerce_to_logical(data$impacted_teeth, "impacted_teeth", .warn)

  # Row-level Validation
  n <- nrow(data)
  error_msg <- rep("", n)

  # 1. Aesthetic (1-10)
  error_msg <- add_error(error_msg, is.na(data$aesthetic_component) |
                           !is_whole_number(data$aesthetic_component) |
                           data$aesthetic_component < 1 | data$aesthetic_component > 10,
                         "aesthetic_component must be integer [1,10]")

  # 2. Crowding/Spacing
  error_msg <- add_error(error_msg, is.na(data$upper_crowding_mm) & is.na(data$upper_spacing_mm),
                         "Need crowding or spacing value")

  # 3. Vertical & Buccal AP
  error_msg <- add_error(error_msg, is.na(data$buccal_ap_left) | is.na(data$buccal_ap_right),
                         "Both buccal_ap sides required")

  has_error <- nzchar(error_msg)

  if (any(has_error) && .on_error == "stop") {
    stop("Validation failed for ICON components. Set .on_error='collect' to see details.")
  }

  # Computation logic
  d_valid <- data[!has_error, ]

  if (nrow(d_valid) > 0) {
    scores <- d_valid %>%
      dplyr::mutate(
        # 1. Crowding/Spacing score
        max_c_s = pmax(.data$upper_crowding_mm, .data$upper_spacing_mm, na.rm = TRUE),
        upper_arch_crowding_score = dplyr::case_when(
          .data$impacted_teeth == TRUE ~ 5L,
          .data$max_c_s < 2            ~ 0L,
          .data$max_c_s <= 5           ~ 1L,
          .data$max_c_s <= 9           ~ 2L,
          .data$max_c_s <= 13          ~ 3L,
          .data$max_c_s <= 17          ~ 4L,
          .data$max_c_s > 17           ~ 5L,
          TRUE                         ~ 0L
        ),

        # 2. Crossbite
        crossbite_score = dplyr::if_else(.data$crossbite, 1L, 0L),

        # 3. Vertical score
        obs_score = dplyr::case_when(
          .data$incisor_openbite_mm <= 0 ~ 0L,
          .data$incisor_openbite_mm <= 1 ~ 1L,
          .data$incisor_openbite_mm <= 2 ~ 2L,
          .data$incisor_openbite_mm <= 4 ~ 3L,
          .data$incisor_openbite_mm > 4  ~ 4L,
          TRUE                           ~ 0L
        ),
        vertical_score = pmax(.data$obs_score, as.integer(.data$incisor_overbite_category), na.rm = TRUE),

        # 4. Buccal AP score
        buccal_ap_score = as.integer(.data$buccal_ap_left + .data$buccal_ap_right)
      ) %>%
      dplyr::select(
        "patient_id",
        "time",
        "aesthetic_component",
        "upper_arch_crowding_score",
        "crossbite_score",
        "vertical_score",
        "buccal_ap_score"
      )
  } else {
    scores <- dplyr::tibble(
      patient_id = character(),
      time = character(),
      aesthetic_component = integer(),
      upper_arch_crowding_score = integer(),
      crossbite_score = integer(),
      vertical_score = integer(),
      buccal_ap_score = integer()
    )
  }

  if (.on_error == "stop") return(scores)

  return(list(
    scores = scores,
    errors = dplyr::tibble(
      row = which(has_error),
      patient_id = data$patient_id[has_error],
      error = sub("^ \\| ", "", error_msg[has_error])
    )
  ))
}
