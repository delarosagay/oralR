#' Compute overall ICON scores and derived clinical decisions
#'
#' Aggregates Index of Complexity, Outcome and Need (ICON) component scores
#' into weighted totals per patient and timepoint. It derives treatment need,
#' complexity grades, and improvement scales according to Daniels & Richmond (2000).
#'
#' @param data A data frame containing raw clinical measurements.
#' @param max_discrepancy_allowed Numeric. Maximum allowed mm for crowding/spacing calculations.
#' @param .on_error Character. One of "collect" (returns a list with errors) or "stop" (throws error).
#' @param .warn Logical; if TRUE, emits warnings for skipped or problematic rows.
#' @param ... Additional arguments passed to \code{tidy_dental}.
#'
#' @return A \code{tibble} (if .on_error = "stop") or a \code{list} containing scores and error logs.
#' @importFrom dplyr tibble mutate select rename case_when arrange count filter bind_rows
#' @importFrom tidyr pivot_wider
#' @export
compute_icon <- function(data,
                         max_discrepancy_allowed = 20,
                         .on_error = c("collect", "stop"),
                         .warn = FALSE,
                         ...) {

  .on_error <- match.arg(.on_error)

  # 1. Standardize input format
  data_tidy <- tryCatch({
    tidy_dental(data, ...)
  }, error = function(e) {
    if (.on_error == "stop") stop(e$message)
    data
  })

  # 2. Calculate component scores
  scored_res <- score_icon_components(
    data_tidy,
    max_discrepancy_allowed = max_discrepancy_allowed,
    .on_error = if (.on_error == "stop") "stop" else "collect",
    .warn = .warn
  )

  if (.on_error == "stop") {
    comp_df <- scored_res
    errors_df <- dplyr::tibble()
  } else {
    comp_df <- scored_res$scores
    errors_df <- scored_res$errors
  }

  # Handle empty results
  if (nrow(comp_df) == 0) {
    empty <- dplyr::tibble(
      patient_id = character(),
      icon_pre = numeric(),
      icon_post = numeric(),
      icon_improvement = numeric(),
      treatment_need = logical(),
      complexity_grade = factor(levels = c("Easy", "Mild", "Moderate", "Difficult", "Very difficult")),
      outcome_acceptable = logical(),
      improvement_grade = factor(levels = c("Not improved or worse", "Minimally improved",
                                            "Moderately improved", "Substantially improved", "Greatly improved"))
    )
    return(if (.on_error == "stop") empty else list(scores = empty, errors = errors_df))
  }

  # 3. Apply ICON Weights (Daniels & Richmond, 2000)
  comp_weighted <- comp_df %>%
    dplyr::mutate(
      icon_score = (7 * aesthetic_component) +
        (5 * crossbite_score) +
        (5 * upper_arch_crowding_score) +
        (4 * vertical_score) +
        (3 * buccal_ap_score)
    )

  # 4. Data Quality Control: Validate longitudinal consistency per patient
  dup_check <- comp_weighted %>%
    dplyr::count(patient_id, time) %>%
    dplyr::filter(n > 1)

  if (nrow(dup_check) > 0) {
    bad_patients <- unique(dup_check$patient_id)
    msg_err <- paste("Duplicate entries found for the same time point (pre/post) for patients:",
                     paste(bad_patients, collapse = ", "))

    if (.on_error == "stop") {
      stop(msg_err)
    } else {
      if (.warn) warning(msg_err)

      new_errors <- dplyr::tibble(
        row = NA_integer_,
        patient_id = bad_patients,
        error = "Duplicate entries found for the same time point (pre/post)"
      )
      errors_df <- dplyr::bind_rows(errors_df, new_errors)

      comp_weighted <- comp_weighted %>%
        dplyr::filter(!patient_id %in% bad_patients)

      if (nrow(comp_weighted) == 0) {
        empty <- dplyr::tibble(
          patient_id = character(), icon_pre = numeric(), icon_post = numeric(),
          icon_improvement = numeric(), treatment_need = logical(),
          complexity_grade = factor(levels = c("Easy", "Mild", "Moderate", "Difficult", "Very difficult")),
          outcome_acceptable = logical(),
          improvement_grade = factor(levels = c("Not improved or worse", "Minimally improved",
                                                "Moderately improved", "Substantially improved", "Greatly improved"))
        )
        return(list(scores = empty, errors = errors_df))
      }
    }
  }

  # 5. Pivot to patient-level structure for comparison
  wide <- comp_weighted %>%
    dplyr::select(patient_id, time, icon_score) %>%
    tidyr::pivot_wider(names_from = time, values_from = icon_score)

  # Ensure time point columns exist to prevent calculation errors
  if (!"pre" %in% names(wide)) wide$pre <- NA_real_
  if (!"post" %in% names(wide)) wide$post <- NA_real_

  # 6. Classifications and clinical decisions
  out <- wide %>%
    dplyr::rename(icon_pre = pre, icon_post = post) %>%
    dplyr::mutate(
      # Improvement formula: I = Pre - 4*Post
      icon_improvement = icon_pre - (4 * icon_post),

      # Treatment Need Threshold (>= 43)
      treatment_need = icon_pre >= 43,

      # Complexity Grading (based on pre-treatment score)
      complexity_grade = dplyr::case_when(
        icon_pre <= 29 ~ "Easy",
        icon_pre <= 50 ~ "Mild",
        icon_pre <= 63 ~ "Moderate",
        icon_pre <= 77 ~ "Difficult",
        icon_pre > 77  ~ "Very difficult",
        TRUE           ~ NA_character_
      ),

      # Post-treatment acceptability (score < 31)
      outcome_acceptable = icon_post < 31,

      # Improvement Grading based on Daniels & Richmond thresholds
      improvement_grade = dplyr::case_when(
        icon_improvement >= 0   ~ "Greatly improved",
        icon_improvement >= -25 ~ "Substantially improved",
        icon_improvement >= -53 ~ "Moderately improved",
        icon_improvement >= -85 ~ "Minimally improved",
        icon_improvement < -85  ~ "Not improved or worse",
        TRUE                    ~ NA_character_
      )
    ) %>%
    dplyr::mutate(
      complexity_grade = factor(complexity_grade,
                                levels = c("Easy", "Mild", "Moderate", "Difficult", "Very difficult")),
      improvement_grade = factor(improvement_grade,
                                 levels = c("Not improved or worse", "Minimally improved",
                                            "Moderately improved", "Substantially improved", "Greatly improved"))
    ) %>%
    dplyr::arrange(patient_id)

  if (.on_error == "stop") return(out)

  return(list(scores = out, errors = errors_df))
}
