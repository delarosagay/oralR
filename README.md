
# **oralR: Tools for Dental Data Analysis in R**

`oralR` is an R package designed to streamline clinical and
epidemiological dental research by providing a workflow for data
cleaning, standardization, index computation, and statistical analysis.

The package includes four major groups of functionality:

1.  Dental notation tools:

- `detect_notation()`: identifies the notation system used in each input
- `handle_ambiguous_notation()`: resolves identifiers valid in both FDI
  and Universal
- `parse_notation()`: extracts structured components from dental codes
- six bidirectional conversion functions between FDI, Universal and
  Alphanumeric (e.g., `convert_fdi_to_universal()`,
  `convert_universal_to_fdi()`, etc.)

2.  Data cleaning and tidy transformation:

`tidy_dental()` performs some core data‑cleaning and harmonisation steps
required for downstream analysis, as it:

- detects dataset format and converts it into a standard tidy structure
- performs automatic conversion of Alphanumeric codes into FDI notation
- harmonisation of surfaces, tooth-level and periodontal formats
- preparation of datasets for some periodontal index computation (BOP,
  PI, PCR)

3.  Clinical index computation:

- Caries indices:

  `normalize_dmft_format()`, `compute_dmft()` `normalize_def_format()`,
  `compute_def()`

- Periodontal indices:

  `validate_index_input()`: required before using surface‑based indices
  `compute_bop()`, `compute_pi()`, `compute_pcr()`, `compute_psi()`

- Orthodontic index:

  `score_icon_components()`, `compute_icon()`

4.  Statistical tools:

- `analyze_descriptives()`: generates descriptive summaries
- `analyze_prevalence()`: computes prevalence estimates by group or
  population.

`oralR` bridges the gap between raw dental charting and statistical
analysis, ensuring reproducible workflows in clinical, research, and
educational contexts. `oralR` aims to provide a consistent, reliable,
and extensible framework for handling dental data in clinical, research,
and educational contexts.

## **Supported notation systems**

`oralR` supports the three major notation systems (FDI, Universal,
Alphanumeric) and provides full bidirectional conversion between them.

Some identifiers (such as “11”, “14”, or “24”) are valid in both FDI and
Universal systems. `oralR` detects these ambiguous cases explicitly and
offers dedicated tools to interpret or resolve them safely.

## **Why `oralR`?**

Dental datasets are often heterogeneous, inconsistently structured, and
difficult to analyse reproducibly. Clinical data may mix different
notation systems (FDI, Universal, Alphanumeric), combine tooth‑level and
surface‑level formats, or include partially tidy and partially wide
structures. These inconsistencies make automated analysis error‑prone
and time‑consuming.

`oralR` provides a unified, reliable and reproducible framework for:

- detecting, interpreting and converting dental notation systems
- cleaning and harmonizing raw clinical data sets into a standard tidy
  structure
- preparing periodontal, caries and orthodontic data for downstream
  analysis
- computing clinical indices (DMFT, def, BOP, PI, PCR, PSI, ICON) in a
  consistent and validated way
- integrating seamlessly with data frames and tidyverse workflows
- producing descriptive and prevalence‑based summaries

The goal of `oralR` is to make dental data processing from raw input to
clinical indices accurate, standardized and fully reproducible,
supporting research, epidemiology, education and clinical data analysis.

## **Installation**

The package is currently under development and not yet available on
CRAN.

### Development Version from GitHub

You can install the development version from GitHub with:

``` r
# If you don't have remotes installed:
# install.packages("remotes")

remotes::install_github("delarosagay/oralR")
```

## **Workflow and data‑handling helpers**

`oralR` is designed to integrate into R workflows. All functions are:

- vectorized, making them suitable for large clinical datasets
- fully compatible with `data.frames` and `tidyverse` pipelines
- consistent across notation systems, with helper tools to convert
  Universal or Alphanumeric inputs into FDI when required
- built to support the complete analysis pipeline, from raw data
  cleaning to clinical index computation and statistical summarization

These design principles ensure that `oralR` can be used reliably in
epidemiology, clinical research, teaching, and routine data processing.

## **Package structure**

The package follows the standard R package layout:

``` text
oralR/
├── DESCRIPTION        # Package metadata and dependencies
├── NAMESPACE          # Exported functions and package imports
├── R/                 # Core R functions and source code
├── man/               # Function documentation (generated via roxygen2)
├── tests/             # Automated unit tests and test suites
├── vignettes/         # Long-form documentation and workflow examples
└── inst/              # Extra files (CITATION for academic references)
```

## **Overview of functions**

### **Core functionality**

#### **`detect_notation()`:**

Identifies the notation system of each tooth identifier.  
Returns `"FDI"`, `"Universal"`, `"Alphanumeric"`, or
`c("FDI", "Universal")` when a value can belong to both systems.

**Returns:**

- a single string (“FDI”, “Universal”, or “Alphanumeric”) if the match
  is unique.
- a character vector, c(“Universal”, “FDI”), when a value is ambiguous
  (e.g., “11”)
- character(0) when the input does not match any known notation.
- for vector inputs, returns a list of character vectors, one per
  element.

**Key Logic:**

- Alphanumeric: Detects quadrant-based codes like “UR1” (Upper Right 1)
  or “LLC”.
- Universal: Identifies permanent numbers (1–32) and primary letters
  (A–T).
- FDI: Validates two-digit codes based on quadrant (1–4 for permanent,
  5-7 for primary) and tooth position (1–8 for permanent, 1–5 for
  primary)

### **Ambiguity handling**

#### **`handle_ambiguous_notation()`:**

Dental notation has some overlaps: for example, the identifier “11”
refers to a permanent upper right incisor in FDI, but a permanent upper
left canine in Universal. `handle_ambiguous_notation()` resolves theses
overlaps between FDI and Universal values (values 11-18, 21-28, and
31-32) before parsing or conversion.

**Strategies (action):**

- `"keep"`: leave ambiguous values unchanged  
- `"na"`: replace ambiguous values with `NA`  
- `"remove"`: drop ambiguous values  
- `"as_fdi"`: interpret ambiguous values as FDI  
- `"as_universal"`: interpret ambiguous values as Universal

### **Parsing**

#### **`parse_notation()`:**

Parses one or more tooth identifiers into structured components. It
decomposes dental identifiers into a structured tibble, extracting
hierarchical properties for each tooth.

**Key Features:**

- Universal mapping: quadrants are normalized to the 1–4 convention (1:
  Upper Right, 2: Upper Left, 3: Lower Left, 4: Lower Right) for both
  permanent and primary teeth.
- Clinical detail: identifies the dentition type (permanent/primary) and
  extracts the specific tooth number or letter.
- Ambiguity aware: if a value is ambiguous (e.g., “11”), it remains as
  “ambiguous” unless a preference was set using
  `handle_ambiguous_notation()`.

**Note:**

This function does not split or extract multiple identifiers from free
text; each element of the input vector is treated as a single
identifier.

### **Conversion functions (between all three systems)**

The package provides a set of conversion utilities between FDI,
Universal, and Alphanumeric notation. These functions can be called
directly by the user whenever explicit conversion is required.

**Important:**  
Conversion functions do not block or fail when given ambiguous numeric
values (e.g., “11”, “14”, “24”). They assume that the user already knows
(or has detected using `detect_notation()`) which notation the input
belongs to. If the user wants to resolve ambiguities before conversion,
this must be done explicitly using `handle_ambiguous_notation()`.

#### **FDI ↔ Universal:**

##### `convert_fdi_to_universal()`:

Converts permanent or primary teeth from FDI notation to Universal
notation.

##### `convert_universal_to_fdi()`:

Converts permanent or primary teeth from Universal notation to FDI
notation.

#### **FDI ↔ Alphanumeric:**

##### `convert_fdi_to_alphanumeric()`:

Converts FDI identifiers to alphanumeric notation.

##### `convert_alphanumeric_to_fdi()`:

Converts alphanumeric identifiers to FDI notation.

#### **Universal ↔ Alphanumeric:**

##### `convert_universal_to_alphanumeric()`:

Converts Universal identifiers to alphanumeric notation.

##### `convert_alphanumeric_to_universal()`:

Converts alphanumeric identifiers to Universal notation.

**Relation to tidy_dental():**  
`tidy_dental()` performs Alphanumeric into FDI conversion. It does not
convert between FDI and Universal. Users should apply the conversion
functions when needed.

### **Standardize dental datasets into a unified tidy format**

#### **`tidy_dental()`**

It detects the structure of a dental dataset and converts it into a
standardized long format suitable for downstream computations such as
`compute_bop()`, `compute_pcr()` and `compute_pi()`. It acts as a
pre‑processor that harmonizes tooth identifiers, reshapes wide formats,
and ensures consistent column structure across all index functions.

**Supported input formats**  
`tidy_dental()` automatically recognizes and processes the following
dataset types:

1.  Periodontal wide format: `tidy_dental()` automatically recognizes
    and reshapes two distinct wide structures:

    - **Tooth-Surface Headers:** Datasets where each column represents a
      single tooth and surface combination using underscores or dots
      (e.g., `UR6_MB`, `16.DB`, `LL7_L`). These are parsed and split
      into structured variables.
    - **Surface-Only Columns:** Datasets that feature an explicit
      `tooth` column alongside individual clinical surface columns
      (e.g., `M`, `D`, `B`, `L`), which is typical for plaque and
      bleeding charts (such as PCR or BOP records).

2.  Periodontal long format

Columns:

- `tooth`  
- `tooth_side`  
- value column (index‑specific)

3.  Tooth‑level format. Used by DMFT, def, PSI tooth‑level mode.

Columns:

- `tooth`  
- status/value column

4.  Sextant‑level format. Used by PSI/CPI.

Columns:

- `sextant`  
- `psi_code`

**Note:**

sextant‑level datasets are detected but not reshaped, as PSI does not
require tooth‑ or surface‑level harmonization.

The function determines the format automatically and raises an error if
multiple formats are mixed in the same dataset.

**Tooth notation handling**.`tidy_dental()` supports all notation
systems recognized by `detect_notation()` and `parse_notation()`: FDI,
Universal, and Alphanumeric.

The function performs the following operations:

– Automatic conversion of Alphanumeric notation into FDI  
– FDI notation is preserved without modification – Universal notation is
preserved; no automatic conversion is applied – Ambiguous numeric codes
are preserved exactly as provided - Includes rigorous tooth-code
validation: invalid entries trigger an error instead of processing
inconsistent data.

Users who require explicit conversions (e.g.,
`convert_universal_to_fdi()`) should apply them before calling
`tidy_dental()`.

If no dental structure is present (tooth codes, surfaces, or wide
periodontal formats), the function normalizes column names, standardizes
the patient identifier to `patient_id`, and returns the dataset with
unique rows (`dplyr::distinct()`). This ensures that summary‑level
indices such as DMFT/DEF, PCR, BOP, PI, PSI or ICON preserve their core
data structure while removing any exact duplicate rows and ensuring
consistent metadata across your pipeline.

**Key behaviors:**

- Column names are normalized (hyphens and dots → underscores).  

- The patient ID column is standardized to `patient_id`.  

- Periodontal wide formats (with or without underscores) are reshaped
  into long format.  

- Tooth identifiers are parsed and converted only when the notation is
  Alphanumeric.  

- Invalid or unrecognized tooth codes propagate as `NA`.  

- Mixed formats (e.g., wide + long) trigger an error.  

- Duplicate rows are removed to ensure one unique entry per
  tooth/surface.  

- Non‑dental variables (e.g., age, gender, examiner) are preserved in
  the output.  

- The resulting tibble always contains at least:

  - `patient_id`  
  - `tooth` (FDI or Universal)  
  - `tooth_side` (if applicable)  
  - value column(s)

Surface names must follow periodontal standards (MB, B, DB, ML, L,
DL).  
Lowercase is accepted. Synonyms `v / B` and `p / L` are automatically
normalized.  
Non‑standard abbreviations (e.g., “buc”, “ling”) are not supported.

**Returned value**: A tibble in standardized long format, ready for use
in all downstream index functions.

**Why `tidy_dental()`:**

By centralizing format detection, notation parsing, safe
Alphanumeric‑to‑FDI conversion, wide‑to‑long reshaping, and structural
harmonization, `tidy_dental()` ensures that all index functions operate
on a consistent and validated dataset. This reduces the risk of
structural errors and provides a reliable foundation for clinical
computations.

### **Compute Periodontal Index**

#### **`validate_index_input()`:**

The function `validate_index_input()` performs the shared structural
validation required by periodontal indices that operate on site‑level
data (BOP, PCR, PI). It ensures that the dataset has the correct global
format before these indices computation begins.

This function is not used for indices that rely on different data models
(e.g., PSI/CPI, DMFT, def, ICON), which implement their own dedicated
validation logic.

`validate_index_input()` may be used manually, but `compute_bop()`,
`compute_pi()`, and `compute_pcr()` call it automatically and internally
to guarantee consistent structural validation and tooth‑side
normalization.

**Purpose:** `validate_index_input()` performs global checks that are
common across BOP, PCR and PI indices:

- Ensures that required columns are present:

  `patient_id`, `tooth`, `tooth_side`, and the index‑specific value
  column.

- Verifies that `tooth_side` values match the expected set for the
  selected index:

  - BOP (6 sites): MB, B/V, DB, ML, L/P, DL
  - PCR / PI (4 sites): M, D, B/V, L/P

- Validates numeric ranges when global validation is safe:

  - BOP and PCR: values must be 0 or 1  
  - PI: values must be integers between 0 and 3 (Silness & Löe scale).

- Ensures that the dataset does not contain unexpected or malformed
  structural elements before deeper validation occurs.

- The function handles international nomenclature. V (Vestibular) is
  accepted as B (Buccal), and P (Palatal) is accepted as L (Lingual).
  All inputs are case‑insensitive (e.g., “mb” is treated as “MB”).

If the dataset passes all checks, the function returns invisible(TRUE)
and produces no console output. Messages are shown only when structural
errors are detected. If structural errors are detected, the function
stops execution immediately, preventing downstream functions from
operating on malformed data.

**Used by:**

- `compute_bop()`  
- `compute_pcr()`  
- `compute_pi()`

These functions rely on `validate_index_input()` to guarantee that the
dataset has a valid global structure before running their own
index‑specific checks. These later checks include, for example, FDI
validation, detection of duplicate sites, missing surfaces, or incorrect
numbers of sites.

**Not used by**

- `compute_psi()`: PSI/CPI uses tooth‑level or sextant‑level data and
  requires a different validation model.
- `compute_dmft()`, `compute_def()`: These indices operate on
  tooth‑level status codes (D/M/F or d/e/f) and do not involve surfaces
  or site‑level values.
- `compute_icon()`

**Why this separation:** By isolating global structural validation in
`validate_index_input()` and leaving index‑specific rules inside each
compute function, the package remains:

- modular  
- easier to maintain  
- consistent across indices  
- robust against malformed input

This design ensures that each index function focuses only on the rules
that are unique to that index, while shared structural checks are
handled centrally.

#### **`compute_bop()`:**

Computes the Bleeding on Probing (BOP) index for each patient. BOP is
defined as the percentage of bleeding sites relative to the total number
of probed sites.  
The function applies strict structural validation to ensure that only
complete and coherent periodontal data are used. `compute_bop()`
automatically calls validate_index_input(), which performs global
structural checks and normalizes tooth‑side nomenclature (e.g., V→B,
P→L). As a result, users do not need to run `validate_index_input()`
manually.

**Supported input format:** The function requires tooth‑surface–level
data, with one row per tooth surface.

**Required columns:**

- `patient_id`
- `tooth` (FDI permanent notation)
- `tooth_side` (one of: MB, B, DB, ML, L, DL)
- `bop` (0 or 1)

Missing teeth should simply be omitted from the dataset (i.e., no rows
for absent teeth).

**Key rules:**

- Each present tooth must contribute exactly six sites: MB, B, DB, ML,
  L, DL  
  (one row per site). All tooth‑side values are already normalized
  before the index‑specific validation begins.

- Tooth identifiers must be valid FDI permanent teeth.  
  Teeth outside the permanent range (e.g., 51, 75, 99) cause the patient
  to be omitted.

- Duplicate tooth–site combinations are not allowed.

- Rows with `bop = NA` or `tooth_side = NA` are removed before
  per‑patient processing.

- Exclusion criteria: patients with the following are omitted:

  - invalid tooth notation  
  - non‑permanent FDI numbers  
  - missing or duplicated sites  
  - any structural inconsistency

- A single combined warning is issued listing all omitted patients and
  their errors.

**Returned values (per patient):**

- `total_points` — number of examined sites  
- `bleeding_points` — number of sites with bleeding (`bop = 1`)  
- `bop_percent` — percentage of bleeding sites

#### **`compute_pi()`:**

Computes the Plaque Index (PI) for each patient following the Silness &
Löe method.  
PI is defined as the mean plaque score across the four surfaces of each
present tooth: M, D, B, and L. Plaque scores must be integers from 0 to
3. `compute_pi()` automatically calls `validate_index_input()`, which
performs global structural checks and normalizes tooth‑side nomenclature
(e.g., V→B, P→L). Users do not need to run validate_index_input()
manually.

**Key rules:**

- Each present tooth must contribute exactly four surfaces: M, D, B, and
  L.

- It accepts V (Vestibular) as a synonym for B, and P (Palatal) for L.
  All inputs are case-insensitive (e.g., “v” is treated as “B”).

- Missing teeth or rows with NA values are automatically omitted from
  the calculation.  

- Tooth identifiers must be valid FDI permanent or primary teeth. If
  your dataset uses other systems (Universal or Alphanumeric), you
  should normalize them first. Use `tidy_dental()` for automatic
  conversion of Alphanumeric to FDI. If your data uses Universal
  notation, apply an explicit conversion beforehand using helpers such
  as `convert_universal_to_fdi()`.

- Duplicate tooth–surface combinations are not allowed.  

- Plaque values must be integers in the range 0–3; any value outside
  this range (e.g., 9 or 2.5) will trigger a terminal error and halt
  execution via validate_index_input() to maintain clinical accuracy.

- Patients with invalid data are omitted, and a combined warning is
  issued.  

- The function returns, per patient:

  - total_sites: number of examined surfaces (integer)
  - total_score: cumulative sum of plaque scores across all surfaces
    (numeric)
  - pi_index: mean plaque score across all recorded surfaces (numeric,
    range 0–3)

#### **`compute_pcr()`:**

Computes the Plaque Control Record (PCR), following O’Leary’s method,
for each patient. PCR is defined as the percentage of tooth surfaces
with plaque (0/1) relative to the total number of examined surfaces.
Each present tooth must contribute exactly four surfaces: M, D, B and L.
`compute_pcr()` automatically calls `validate_index_input()`, which
performs global structural checks and normalizes tooth‑side nomenclature
(e.g., V→B, P→L). Users do not need to run `validate_index_input()`
manually.

**Key rules:**

- Each present tooth must appear with exactly four surfaces (M, D, B,
  and L).

- Missing teeth must be omitted from the dataset (i.e., no rows should
  exist for absent teeth).

- Tooth identifiers must use valid FDI permanent or primary tooth
  numbers.

- Duplicate tooth–surface combinations are not allowed.

- Plaque values must be binary (0 or 1); any invalid value results in
  exclusion of the patient.

- Patients with invalid tooth notation, invalid FDI numbers, duplicated
  sites, or incomplete four‑surface mapping are omitted and collected
  into a combined warning message.

- The function returns, per patient:

  - total_points: total number of examined surfaces
  - plaque_points: number of surfaces with plaque (=1)
  - pcr_percent: percentage of plaque‑positive surfaces across all
    recorded sites

#### **`compute_psi()`:**

Computes the Periodontal Screening Index (PSI, also known as CPI) for
each patient.  
The function accepts both tooth‑level and sextant‑level input and
automatically determines the appropriate mode per patient.

**Supported input formats:**

**1. Tooth‑level data:**

- Required columns: `patient_id`, `tooth` (FDI notation, two digits),
  `psi_code`

- Only permanent teeth are accepted (FDI 11-18, 21-28, 31-38, 41–48)

- If tooth values are present, every single entry for that patient must
  be a valid permanent FDI code. Any invalid format (e.g., “UR1”, “XX”,
  “9”) or primary dentition code (e.g., “51”) will fail validation and
  cause the entire patient record to be omitted to ensure clinical data
  integrity.

- Each valid tooth is automatically assigned to its sextant using
  standard CPI sextant definitions:

  - Sextant 1 includes teeth 18 to 14
  - Sextant 2 includes teeth 13 to 11 and 21 to 23
  - Sextant 3 includes teeth 24 to 28
  - Sextant 4 includes teeth 38 to 34
  - Sextant 5 includes teeth 33 to 31 and 41 to 43
  - Sextant 6 includes teeth 44 to 48

- Sextant score = maximum `psi_code` among its teeth

- Final PSI = maximum sextant score

**2. Sextant‑level data:**

- Required columns: `patient_id`, `sextant` (1–6), `psi_code`
- Sextant values are used directly
- Final PSI = maximum sextant score

**Key rules:**

- Mode is determined independently for each patient based on whether
  non-NA values exist in the tooth or sextant columns.
- Tolerant-zero policy: To protect statistical and clinical conclusions
  from data-entry typos, the function does not silently filter out
  anomalies.
- Patients are omitted from the final output table if they exhibit any
  of the following:
  - Invalid FDI tooth numbers (including primary teeth or format
    errors).
  - Invalid sextant identifiers (values outside the 1–6 range).
  - Invalid PSI codes (values must be integers between 0 and 4).
  - No valid, non-NA psi_code values available.
- A single combined, detailed warning is issued at the end of the
  execution, listing all omitted patient_ids along with their specific
  error reasons.

**Returned values (per patient):**

- `patient_id`  
- `psi`: final PSI score (maximum sextant value)

### **Compute Decay Index:**

#### **`normalize_dmft_format()`:**

Standardizes DMFT input into a clean binary format (D, M, F) suitable
for `compute_dmft()`. This function ensures that the dataset uses
exactly one scoring system: - Binary format: Columns D, M, F must be
present and contain only 0/1/NA. - Status format: A single column status
containing one of: “D” (decayed), “M” (missing), “F” (filled), “S”
(sound), or NA. If both systems are present simultaneously, the function
raises an error to avoid ambiguity.

Accepts status codes in either uppercase or lowercase. All values are
internally converted to uppercase before validation.

**Key rules:**

- Exactly one scoring system must be used per dataset:

  - If D/M/F exist → status must not exist.
  - If status exists → D/M/F must not exist.

- Status values are converted to binary D/M/F columns.

- Binary format is validated:

  - Only 0/1/NA allowed.
  - D/M/F must be mutually exclusive.

- The output always contains: patient_id, tooth, D, M, F.

**Return values:** A tibble with validated and mutually exclusive binary
columns D, M, F.

**Notes:**

- This function does not compute DMFT; it only prepares the dataset.
- It should be applied before calling `compute_dmft()`.

#### **`compute_dmft()`**

Computes the DMFT (Decayed, Missing, Filled Teeth)index for each
patient.  
DMFT is defined as the sum of Decayed (D), Missing (M), and Filled (F)
permanent teeth for a given patient. Each tooth can contribute at most
one of D/M/F (mutually exclusive).

**Key rules:**

- Tooth notation is validated using `detect_notation()`:
  - If no possible notation is detected: the patient is omitted.
  - Otherwise, the tooth is coerced to an integer and validated as FDI.
- Only permanent FDI teeth (11-18, 21–28, 31-38, 41-48) are allowed; the
  presence of primary teeth results in omission of the patient.
- Complete permanent dentition is required: the dataset must include all
  permanent teeth from second molar to second molar (11–17, 21–27,
  31–37, 41–47). Missing any of these teeth results in omission of the
  patient.
- Third molars (18, 28, 38, 48) are optional and ignored if present.
- Required columns: `patient_id`, `tooth`, `D`, `M`, `F`.
- `D`/`M`/`F` must be binary (0/1); any non‑binary value causes the
  patient to be omitted.
- Mutual exclusivity: for each tooth, only one of `D`, `M`, or `F` may
  equal 1 (ties/conflicts lead to omission).
- Missing teeth should simply be absent from the input (i.e., no rows
  for teeth not present/assessed).
- Patients with invalid data are omitted; the function continues with
  the rest and issues a combined warning\* summarizing all errors.

**Return values (per patient):**

- `patient_id`
- `dmft`: integer count equal to `sum(D + M + F)` across all valid
  permanent teeth for that patient

**Notes:**

- The function does not infer caries status; it expects pre‑scored D/M/F
  flags per tooth.
- Primary teeth are intentionally excluded because DMFT is defined for
  permanent dentition (use `compute_def()` for primary teeth).

#### **`normalize_def_format()`:**

Standardizes primary‑tooth caries input into a clean binary format (D,
E, F) suitable for `compute_def()`. This function ensures that the
dataset uses exactly one scoring system:

- Binary format: Columns D, E, F must be present and contain only
  0/1/NA.
- Status format: A single column status containing one of:“D” (decayed),
  “E” (extracted), “F” (filled), “S” (sound), or NA.

If both systems are present simultaneously, the function raises an error
to avoid ambiguity.

Accepts status codes in either uppercase or lowercase. All values are
internally converted to uppercase before validation.

**Key rules:**

- Exactly one scoring system must be used per dataset:

  - If D/E/F exist: status must not exist.
  - If status exists: D/E/F must not exist.

- Status values are converted to binary D/E/F columns.

- Binary format is validated:

  - Only 0/1/NA allowed.
  - D/E/F must be mutually exclusive.

The output always contains: patient_id, tooth, D, E, F.

**Return values:**A tibble with validated and mutually exclusive binary
columns D, E, F.

**Notes:**

- This function does not compute the d‑e‑f index; it only prepares the
  dataset.
- It should be applied before calling `compute_def()`.

#### **`compute_def()`:**

Computes the d‑e‑f index (Decayed, Extracted due to caries, Filled) per
patient, restricted strictly to primary teeth in FDI notation. Only the
FDI primary teeth are accepted (51–55, 61–65, 71–75, 81–85). The
function also requires a complete primary dentition from second molar to
second molar.  
If any of the required primary FDI teeth (51–55, 61–65, 71–75, 81–85)
are missing, the entire patient is omitted.

Any tooth that is not a valid FDI primary tooth causes the entire
patient to be omitted, including:

- Permanent teeth, in any notation (FDI, Universal, Alphanumeric)
- Primary teeth written in Universal (A–T) or Alphanumeric (URA–URE,
  etc.)
- Numeric‑like tokens that do not correspond to FDI primary teeth (e.g.,
  “57”, “82.5”, “999”)
- Undetectable or syntactically invalid identifiers (e.g., “XYZ”)

The function also enforces strict validation of the D/E/F indicators:

- Must be 0/1/NA
- Only one of D, E, or F may be 1 per tooth

When invalid teeth or invalid D/E/F values are found:

- the entire patient is omitted
- a combined warning is emitted listing all omitted patients and the
  reason(s) – missing required primary teeth also cause the patient to
  be omitted.

The return value always includes a tibble with columns:

- patient_id
- def — the total number of D + E + F findings across valid primary FDI
  teeth

**Note:** The function never stops execution (unless deliberately
modified); invalid patients are skipped. The warning summarizes all
omissions at the end of processing.

### **Compute ICON Orthodontic Index**

#### **`score_icon_components()`:**

Computes the individual ICON component scores required to later derive
the final ICON score (`compute_icon()` function). This function performs
strict validation of clinical measurements and returns a clean,
standardised dataset. The function scores the five ICON components:

- Aesthetic Component (1–10): Scores the aesthetic impairment using the
  IOTN Aesthetic Component scale, where 1 indicates minimal aesthetic
  concern and 10 represents the most severe aesthetic impact.

- Upper arch crowding (0–5): Based on maximum irregularity (crowding or
  spacing). If impacted_teeth == TRUE, the crowding score is forced to 5
  regardless of measurements.

- Crossbite (0–1): A logical flag: TRUE → 1, FALSE → 0.

- Vertical discrepancy (0–4): Takes the maximum of the openbite
  component and the overbite category:

  - Open bite scoring (0–4): in millimetres at the mid‑incisal edge of
    the most deviated upper incisor:

    - 0: No open bite (complete incisal contact)
    - 1: \>0 to 1 mm
    - 2: \>1 to 2 mm
    - 3: \>2 to 4 mm
    - 4: \>4 mm

  - Overbite scoring (0–3): proportion of lower incisor crown coverage
    at the deepest point of the overbite:

    - 0: Up to one‑third coverage
    - 1: One‑third to two‑thirds coverage
    - 2: Two‑thirds up to full coverage
    - 3: Fully covered

- Buccal A‑P occlusion (0–4): evaluates the sagittal relationship of the
  posterior segments on the left and right sides. Each side is scored
  independently on a 0–2 scale based on the cusp relationship, following
  the original ICON protocol:

  - 0: Cusp‑to‑embrasure relationship (normal Class I)
  - 1: Any cusp relationship up to cusp‑to‑cusp. This reflects a mild
    sagittal deviation.
  - 2: Cusp‑to‑cusp or worse

The ICON buccal A‑P component score is the sum of the left and right
scores, yielding a final range of 0–4.

**Input requirements:**

The function expects one row per patient/time‑point, with the following
variables:

- patient_id
- time (“pre” or “post”, case‑insensitive)
- aesthetic_component (integer 1–10)
- upper_crowding_mm (≥ 0)
- upper_spacing_mm (≥ 0) (At least one of these two must be provided).
- crossbite (logical TRUE/FALSE; “yes”/“no” and 0/1 are allowed and
  coerced)
- incisor_openbite_mm (≥ 0)
- incisor_overbite_category (integer 0–3) (At least one of these two
  must be provided).
- buccal_ap_left, buccal_ap_right (each integer 0–2)
- impacted_teeth (logical; optional; missing defaults to FALSE)

**Error handling:**

The function implements exhaustive validation:

- Missing required pairs (e.g., both crowding and spacing missing; both
  openbite and overbite missing)
- Out‑of‑range numeric values(negative values, values above
  max_discrepancy_allowed, incorrect categories)
- Non‑logical crossbite or impacted teeth
- Missing buccal A‑P sides
- Non‑integer components where integers are required

Invalid rows are never partially processed. For each patient:

- If any required component is invalid: The entire patient is skipped.
- A tibble errors documents every exclusion in detail.
- If .on_error = “stop” is used, execution stops with a consolidated
  message.

**Return value:**

If .on_error = “collect” (default):

- A list with:

  - scores: tibble containing all valid ICON component scores
  - errors: tibble with row index, patient ID, and reason(s) for
    exclusion

If .on_error = “stop”:

- A tibble of valid patients only (or an error if any patient is
  invalid)

The resulting scores tibble is designed to be fed directly into
`compute_icon()`, which aggregates component scores into the final ICON
score following the Daniels & Richmond methodology.

#### **`compute_icon()`:**

The function `compute_icon()` aggregates the ICON component scores
produced by `score_icon_components()` and computes the overall ICON
score for each patient at each timepoint (pre and post).  
Using these weighted totals, it derives all clinical classifications
defined by Daniels & Richmond (2000): treatment need, complexity grade,
outcome acceptability, and improvement grade.  
The function is designed for datasets containing one row per patient per
timepoint.

**Purpose:**

`compute_icon()`:

- always runs `score_icon_components()` internally; users do not need to
  call it manually,
- computes the weighted ICON score for each valid row,  
- reshapes the data into a wide pre/post structure,  
- and applies all official ICON classification rules.

The output is a standardized dataset ready for clinical interpretation
or research analysis.

**Weighted ICON score:**

The overall ICON score is calculated using the official component
weights:

- Aesthetic Component × 7  
- Crossbite Score × 5  
- Upper Arch Crowding Score × 5  
- Vertical Score × 4  
- Buccal AP Score × 3

The function returns:

- `icon_pre` — pretreatment ICON score  
- `icon_post` — posttreatment ICON score

If a patient has only one timepoint, the missing score is returned as
`NA`.

**Derived classifications:**

The function automatically computes all ICON‑defined clinical
classifications.

**1. Treatment need:**

A case is considered to require treatment when:

- `treatment_need = TRUE` if icon_pre ≥ 43  
- `treatment_need = FALSE` if icon_pre \< 43  
- `NA` if the pretreatment score is missing

**2. Complexity grade:**

The complexity of the case is determined from the pretreatment ICON
score.  
The function assigns one of the following categories:

- Easy when the score is ≤ 29  
- Mild when the score is 30–50
- Moderate when the score is 51–63  
- Difficult when the score is 64–77
- Very difficult when the score is \> 77

If `icon_pre` is missing, the complexity grade is `NA`.

**3. Outcome acceptability:**

The posttreatment result is considered acceptable when:

- `outcome_acceptable = TRUE` if icon_post \< 31  
- `outcome_acceptable = FALSE` if icon_post ≥ 31  
- `NA` if the posttreatment score is missing

**4. Improvement grade:**.

Improvement is computed using the ICON formula: I=-4,

Based on the value of *I*, the function assigns:

- Greatly improved when I \> -1  
- Substantially improved when I is between -25 and -1  
- Moderately improved when I is between -53 and -26  
- Minimally improved when I is between -85 and -54  
- Not improved or worse when I \< -85

If either pre or post score is missing, the improvement grade is `NA`.

**Duplicate handling:**

If a patient has more than one row for the same timepoint:

- with `.on_error = "stop"`: the function stops and reports the
  duplication,  
- with `.on_error = "collect"`: only the first row is kept, and a
  warning is issued when `.warn = TRUE`.

**Error handling:**

The function mirrors the behavior of `score_icon_components()`:

`.on_error = "stop"` - Stops immediately if any component‑level error is
detected.  
- Returns only fully valid patients.

`.on_error = "collect"` (default)  
- Processes only valid patients.  
- Returns a list containing:

- `scores`: final ICON results  

- `errors`: rows excluded during component scoring

- When `.warn = TRUE`, a summary warning is issued.

**Return value:**

Depending on the error mode:

If `.on_error = "stop"`, returns a tibble with:

- `patient_id`  
- `icon_pre`, `icon_post`  
- `icon_improvement`  
- `treatment_need`  
- `complexity_grade`  
- `outcome_acceptable`  
- `improvement_grade`

If `.on_error = "collect"`, returns a list with:

- `scores` — tibble containing all valid ICON results  
- `errors` — tibble with `row`, `patient_id`, and `error` messages

### **Statistical Summary Tools:**

#### **`analyze_descriptives()`**

The function `analyze_descriptives()` generates a structured statistical
summary for any numeric vector. It is designed as a general‑purpose
analytical tool that complements the clinical index functions (DMFT,
DEF, PSI, ICON, etc.) without being tied to any specific index.  
Unlike the index‑calculation functions, `analyze_descriptives()` does
not validate clinical data; instead, it focuses on summarizing numeric
results.

This separation allows users to compute an index once and then apply the
same statistical summary function to any variable, subgroup, or dataset.

**Purpose:**

`analyze_descriptives()` provides a compact and comprehensive
statistical overview, including:

- basic descriptive statistics (mean, median, standard deviation),
- distributional characteristics (quartiles, range),
- a normality test (Shapiro–Wilk),
- and outlier detection using the IQR method.

The function is intended for quick exploratory analysis, reporting, and
epidemiological summaries.

**Input:**

- The function accepts x - a numeric vector, or a character vector
  convertible to numeric (e.g., dmft_scores$dmft, icon_scores$icon_pre,
  etc.).

- Missing values (NA) are automatically removed from all calculations.

**Computed statistics:**

For every numeric vector, the function returns:

1.  Basic statistics:

- n (number of non‑missing observations)  
- mean (arithmetic mean)
- median  
- sd (standard deviation; NA if n \< 2)

2.  Range and quartiles:

- min, max  
- p25, p75 ( first and third quartiles; computed using the standard
  quantile method)

3.  Normality test:

- normality_p (p‑value from the Shapiro–Wilk test)

  - Returned as NA if n \< 3  
  - Helps assess whether the distribution is compatible with normality

4.  Outlier detection. Outliers are identified using the IQR rule:

- A value is an outlier if  
  $x < Q1 - 1.5 \cdot IQR$ or  
  $x > Q3 + 1.5 \cdot IQR$

The function returns:

- NA if no outliers are detected or if n \< 4
- a comma-separated list of unique outlier values sorted numerically.

**Validation rules:** The function applies minimal but essential
validation:

1.  Input Coercion: The function attempts to coerce input to numeric
    using as.numeric(). If conversion fails (e.g., non-numeric strings),
    it returns a row of NA values instead of stopping with an error.

2.  Missing values are ignored. If all values are NA, the function
    returns a tibble with NA in all fields.

3.  Statistics depend on sample size. Sample size constraints: sd = NA
    if n \< 2; normality_p = NA if n \< 3 or variance is zero; outliers
    = NA if n \< 4.

**Returned value:**

The function always returns a single‑row tibble with the following
columns:

- `n`  
- `mean`, `median`, `sd`  
- `min`, `max`  
- `p25`, `p75`  
- `normality_p`  
- `outliers`

#### **`analyze_prevalence()`:**

The function `analyze_prevalence()` computes prevalence and 95%
confidence intervals for any binary clinical indicator. It is designed
as a general‑purpose analytical tool that complements the clinical index
functions (DMFT, DEF, PSI, ICON, etc.) by providing a standardized way
to quantify the proportion of positive cases in any dataset.

Unlike index‑calculation functions, `analyze_prevalence()` does not
validate clinical data or compute indices. Instead, it focuses on
summarizing binary outcomes such as presence/absence, disease/no
disease, or treatment need. This separation allows users to compute an
index once and then apply the same prevalence function to any binary
variable, subgroup, or dataset.

**Purpose:**

`analyze_prevalence()` provides a statistical summary of binary
outcomes, including:

- number of observations and number of positive cases,  
- prevalence (proportion of positives),  
- confidence intervals using the Wilson method (95% by default,
  adjustable via conf_level), - automatic handling of NA values.

**Input:** The function accepts x as a logical, numeric, or character
vector representing presence/absence:

- Values may be TRUE/FALSE, 0/1, numeric (where non-zero is TRUE), or
  strings convertible to logical (e.g., “T”, “TRUE”, “F”, “FALSE”).
- Missing values (NA) are automatically removed.

**Computed statistics:**

For every binary vector, the function returns:

1.  Basic counts  

- n: number of non‑missing observations  
- n_positive: number of TRUE or non‑zero values

2.  Prevalence (proportion of positive cases)

3.  Confidence interval. Computed using the Wilson method, which
    provides stable estimates even with small sample sizes:

- ci_low: lower bound  
- ci_high: upper bound

**Validation rules:**

The function applies this validation:

1.  Flexible coercion: The input is converted using as.logical().
    Non-convertible values are treated as NA. The function handles these
    without triggering an error.

2.  If all values are NA, the function returns a tibble where n is 0,
    and all other statistical fields (n_positive, prevalence, ci_low,
    ci_high) are set to NA.

3.  Binary interpretation: The input vector must represent dichotomous
    presence/absence data. While as.logical() technically coerces any
    non-zero numeric value to TRUE, passing continuous indices or
    percentages will lead to incorrect clinical interpretations.

**Returned value:**

The function always returns a single‑row tibble with the following
columns:

- `n`  
- `n_positive`  
- `prevalence`  
- `ci_low`  
- `ci_high`

## **Examples**

Before running the examples, make sure to load the package along with
the following libraries to construct sample dental datasets, manipulate
tables, and plot results:

``` r
library(oralR)
library(tidyr)
library(tibble)
library(dplyr)
library(ggplot2)
```

### 1. Convert between dental notation systems

``` r
# Convert from FDI to Universal
convert_fdi_to_universal("11")
#> [1] "8"
#> attr(,"ambiguous_as")
#> [1] "Universal"
convert_fdi_to_universal("85")
#> [1] "T"
#> attr(,"ambiguous_as")
#> [1] "Universal"

# Convert from FDI to alphanumeric
convert_fdi_to_alphanumeric("11")
#> [1] "UR1"
convert_fdi_to_alphanumeric("84")
#> [1] "LRD"

# Convert from Universal to FDI
convert_universal_to_fdi("30")
#> [1] "46"
#> attr(,"ambiguous_as")
#> [1] "FDI"
convert_universal_to_fdi("B")
#> [1] "54"
#> attr(,"ambiguous_as")
#> [1] "FDI"

# Convert from Universal to Alphanumeric
convert_universal_to_alphanumeric("30")
#> [1] "LR6"
convert_universal_to_alphanumeric("J")
#> [1] "ULE"

# Convert from Alphanumeric to Universal
convert_alphanumeric_to_universal("LR6") 
#> [1] "30"
#> attr(,"ambiguous_as")
#> [1] "Universal"
convert_alphanumeric_to_universal("ULC")   
#> [1] "H"
#> attr(,"ambiguous_as")
#> [1] "Universal"

# Invalid input
convert_universal_to_alphanumeric("99")
#> [1] NA
convert_alphanumeric_to_universal("??") 
#> [1] NA
#> attr(,"ambiguous_as")
#> [1] "Universal"
convert_fdi_to_alphanumeric("XX")
#> [1] NA
```

### 2. Automatically detect the notation system

#### 2.1. Ambiguous cases (FDI and Universal)

``` r
detect_notation(c("11", "24", "14"))
#> [[1]]
#> [1] "Universal" "FDI"      
#> 
#> [[2]]
#> [1] "Universal" "FDI"      
#> 
#> [[3]]
#> [1] "Universal" "FDI"
```

#### 2.2. FDI‑only cases

``` r
detect_notation("36")
#> [[1]]
#> [1] "FDI"
```

#### 2.3. Universal‑only cases

``` r
detect_notation(c("3", "29"))
#> [[1]]
#> [1] "Universal"
#> 
#> [[2]]
#> [1] "Universal"
```

#### 2.4. Alphanumeric notation

``` r
detect_notation(c("UR1", "UL7", "LR3", "LL8"))
#> [[1]]
#> [1] "Alphanumeric"
#> 
#> [[2]]
#> [1] "Alphanumeric"
#> 
#> [[3]]
#> [1] "Alphanumeric"
#> 
#> [[4]]
#> [1] "Alphanumeric"
```

#### 2.5. Invalid or non‑matching strings

``` r
detect_notation("UR9")
#> [[1]]
#> character(0)
detect_notation("UpperRight1")
#> [[1]]
#> character(0)
detect_notation("R1")
#> [[1]]
#> character(0)
```

### 3. Parse mixed or unstructured dental strings

``` r
parse_notation(c("11","46","URB","A","30"))
#> # A tibble: 5 × 4
#>   input notation     quadrant type     
#>   <chr> <chr>           <dbl> <chr>    
#> 1 11    ambiguous          NA <NA>     
#> 2 46    FDI                 4 permanent
#> 3 URB   Alphanumeric        1 primary  
#> 4 A     Universal           1 primary  
#> 5 30    Universal           4 permanent
```

**Note:**

`parse_notation()` treats each element of the input vector as a single
tooth identifier. It does not split or extract multiple identifiers from
free text.

### 4. Handle ambiguous identifiers

#### 4.1. Keep ambiguous values unchanged

``` r
handle_ambiguous_notation(c("11", "24", "36"), action = "keep")
#> [1] "11" "24" "36"
```

#### 4.2. Replace ambiguous values with NA

``` r
handle_ambiguous_notation(c("11", "24", "36"), action = "na")
#> [1] NA   NA   "36"
```

#### 4.3. Remove ambiguous values

``` r
handle_ambiguous_notation(c("11", "24", "36"), action = "remove")
#> [1] "36"
```

#### 4.4. Treat ambiguous values as FDI

``` r
x <- handle_ambiguous_notation(c("11", "24", "36"), action = "as_fdi")
x
#> [1] "11" "24" "36"
#> attr(,"ambiguous_as")
#> [1] "FDI"
```

#### 4.5. Treat ambiguous values as Universal

``` r
x <- handle_ambiguous_notation(c("11", "24", "36"), action = "as_universal")
x
#> [1] "11" "24" "36"
#> attr(,"ambiguous_as")
#> [1] "Universal"
```

**Note:**

Non‑ambiguous values (e.g., `"36"`) are not affected by `"as_fdi"` or
`"as_universal"`.

### 5. Working with dataframes

#### 5.1. Detect notation in a dataset

``` r
df <- data.frame(
  id = 1:6,
  tooth = c("11", "24", "36", "UR1", "29", "14")
)

df %>%
  mutate(notation = detect_notation(tooth))
#>   id tooth       notation
#> 1  1    11 Universal, FDI
#> 2  2    24 Universal, FDI
#> 3  3    36            FDI
#> 4  4   UR1   Alphanumeric
#> 5  5    29      Universal
#> 6  6    14 Universal, FDI
```

#### 5.2. Handle ambiguous values before conversion

``` r
df <- data.frame(
  id = 1:6,
  tooth = c("11", "14", "24", "36", "48", "21")
)

df_clean <- df %>%
  mutate(tooth = handle_ambiguous_notation(tooth, action = "as_fdi"))

df_clean
#>   id tooth
#> 1  1    11
#> 2  2    14
#> 3  3    24
#> 4  4    36
#> 5  5    48
#> 6  6    21
```

**Note:**

Only ambiguous values are affected by “as_fdi” or “as_universal”. For
example, “11”, “14”, “21” and “24” are ambiguous between FDI and
Universal, while values like “36” are not. Using action = “as_fdi”
forces ambiguous identifiers to be interpreted as FDI before parsing.

#### 5.3. Parse a column of tooth identifiers

``` r
# Extracting the parsed information as a clean data frame
parse_notation(df_clean$tooth)
#> # A tibble: 6 × 4
#>   input notation quadrant type     
#>   <chr> <chr>       <dbl> <chr>    
#> 1 11    FDI             1 permanent
#> 2 14    FDI             1 permanent
#> 3 24    FDI             2 permanent
#> 4 36    FDI             3 permanent
#> 5 48    FDI             4 permanent
#> 6 21    FDI             2 permanent
```

#### 5.4. Convert valid codes to another notation

``` r
df_clean %>%
  mutate(tooth_universal = convert_fdi_to_alphanumeric(tooth))
#>   id tooth tooth_universal
#> 1  1    11             UR1
#> 2  2    14             UR4
#> 3  3    24             UL4
#> 4  4    36             LL6
#> 5  5    48             LR8
#> 6  6    21             UL1
```

#### 5.5. Standardize a complete dataset with `tidy_dental()`

From wide format to tidy FDI:

``` r
# A periodontal wide dataset with Alphanumeric notation
df_wide <- tibble(
    patient_id = 1,
    UR6_MB = 1,   # Alphanumeric → FDI (UR6 → 16)
    UR6_DB = 0,   # Alphanumeric → FDI
    UL1_MB = 1    # Alphanumeric → FDI (UL1 → 21)
)

# tidy_dental() reshapes to long format and converts only Alphanumeric → FDI
tidy_dental(df_wide)
#> # A tibble: 3 × 4
#>   patient_id tooth tooth_side value
#>        <dbl> <chr> <chr>      <dbl>
#> 1          1 16    MB             1
#> 2          1 16    DB             0
#> 3          1 21    MB             1
```

From long Alphanumeric format to tidy FDI:

``` r

df_alph_long <- tribble(
    ~patient_id, ~tooth, ~tooth_side, ~bop,
    1,           "UR6",   "MB",        1,
    1,           "UR6",   "DB",        0,
    1,           "UL1",   "B",         1,
    1,           "LL3",   "L",         0,
    1,           "LR2",   "MB",        1
)

df_tidy <- tidy_dental(df_alph_long)
df_tidy
#> # A tibble: 5 × 4
#>   patient_id tooth tooth_side   bop
#>        <dbl> <chr> <chr>      <dbl>
#> 1          1 16    MB             1
#> 2          1 16    DB             0
#> 3          1 21    B              1
#> 4          1 33    L              0
#> 5          1 42    MB             1
```

Handling ambiguous or Universal codes:

``` r
df_clinical <- tibble(
  patient_id = c("P001", "P001", "P002", "P002"),
  tooth      = c("24",   "UR6",  "8",    "36"), # FDI, Alphanumeric, Universal notations
  M          = c(1,      2,      0,      3),    # Plaque Index (values 0-3), mesial surface
  D          = c(0,      1,      1,      2),    # Distal surface  
  B          = c(2,      0,      0,      3),    # Buccal surface   
  L          = c(1,      1,      2,      1)     # Lingual surface   
)

df_tidy <- tidy_dental(df_clinical)
df_tidy
#> # A tibble: 16 × 4
#>    patient_id tooth value tooth_side
#>    <chr>      <chr> <dbl> <chr>     
#>  1 P001       24        1 M         
#>  2 P001       24        0 D         
#>  3 P001       24        2 B         
#>  4 P001       24        1 L         
#>  5 P001       16        2 M         
#>  6 P001       16        1 D         
#>  7 P001       16        0 B         
#>  8 P001       16        1 L         
#>  9 P002       8         0 M         
#> 10 P002       8         1 D         
#> 11 P002       8         0 B         
#> 12 P002       8         2 L         
#> 13 P002       36        3 M         
#> 14 P002       36        2 D         
#> 15 P002       36        3 B         
#> 16 P002       36        1 L
```

### 6. Compute Periodontal Index

#### 6.1. validate_index_input()

#### 6.1.1. BOP Validation Examples

##### 6.1.1.1. Valid data (should pass)

``` r
df_bop_ok <- tibble::tibble(
  patient_id = c(1,1,1,1,1,1),
  tooth      = "11",
  tooth_side = c("MB","B","DB","ML","L","DL"),
  bop        = c(0,1,0,0,1,0)
)

validate_index_input(df_bop_ok, "BOP")
```

##### 6.1.1.2. Invalid `tooth_side`

``` r
df_bop_bad_side <- tibble::tibble(
  patient_id = 1,
  tooth      = "11",
  tooth_side = "X",
  bop        = 1
)

validate_index_input(df_bop_bad_side, "BOP")
#> Error in validate_index_input(df_bop_bad_side, "BOP"): Invalid tooth_side values for BOP: X. Allowed: M, D, B, L, MB, DB, ML, DL
```

##### 6.1.1.3. `bop` column missing

``` r
df_bop_missing <- tibble::tibble(
  patient_id = 1,
  tooth      = "11",
  tooth_side = "MB",
 
)
validate_index_input(df_bop_missing, "BOP")
#> Error in validate_index_input(df_bop_missing, "BOP"): Missing required columns for BOP: bop
```

##### 6.1.1.4. Invalid BOP value (must be 0 or 1)

``` r
df_bop_bad_value <- tibble::tibble(
  patient_id = 1,
  tooth      = "11",
  tooth_side = "MB",
  bop        = 5
)

validate_index_input(df_bop_bad_value, "BOP")
#> Error in validate_index_input(df_bop_bad_value, "BOP"): BOP values must be binary (0 or 1).
```

#### 6.1.2. PI — Validation Examples

##### 6.1.2.1. Valid data

``` r
df_pi_ok <- tibble::tibble(
  patient_id = 1,
  tooth      = "11",
  tooth_side = c("M","D","B","L"),
  plaque     = c(0,2,3,1)
)
validate_index_input(df_pi_ok, "PI")
```

##### 6.1.2.2. Invalid PI value

``` r
df_pi_bad_value <- tibble::tibble(
  patient_id = 1, tooth = "11", tooth_side = "M", plaque = 99
)
# Error: PI (Plaque Index) values must be integers between 0 and 3.
validate_index_input(df_pi_bad_value, "PI")
#> Error in validate_index_input(df_pi_bad_value, "PI"): PI values must be integers between 0 and 3 (Silness-Loe).
```

#### 6.1.3. PCR — Validation Examples

##### 6.1.3.1. Valid data (0/1 values)

``` r
df_pcr_ok <- tibble::tibble(
  patient_id = c(1,1,1,1),
  tooth      = "11",
  tooth_side = c("M","D","B","L"),
  plaque     = c(0,1,0,1)
)

validate_index_input(df_pcr_ok, "PCR")
```

##### 6.1.3.2. Invalid PCR value (must be 0 or 1)

``` r
df_pcr_bad_value <- tibble::tibble(
  patient_id = 1,
  tooth      = "11",
  tooth_side = "M",
  plaque     = 2
)

validate_index_input(df_pcr_bad_value, "PCR")
#> Error in validate_index_input(df_pcr_bad_value, "PCR"): PCR values must be binary (0 or 1).
```

#### 6.2. Compute Bleeding on Probing (BOP) index

6.2.1. Valid patients with complete 6‑site data per tooth

``` r
df1 <- tibble::tibble(
  patient_id = rep("P01", 12),
  tooth      = rep(c("11","12"), each = 6),
  tooth_side = rep(c("MB","B","DB","ML","L","DL"), 2),
  bop        = c(1,0,0,1,0,0,   # tooth 11: 2 bleeding sites
                 0,0,1,0,0,0)   # tooth 12: 1 bleeding site
)

compute_bop(df1)
#> # A tibble: 1 × 4
#>   patient_id total_points bleeding_points bop_percent
#>   <chr>             <int>           <dbl>       <dbl>
#> 1 P01                  12               3          25
```

6.2.2. Multiple valid patients processed independently

``` r
df2 <- tibble::tibble(
  patient_id = c(rep("A", 6), rep("B", 6)),
  tooth      = c(rep("11", 6), rep("21", 6)),
  tooth_side = rep(c("MB","B","DB","ML","L","DL"), 2),
  bop        = c(0,1,0,0,0,0,   # A → 1/6
                 1,1,1,0,0,0)   # B → 3/6
)

compute_bop(df2)
#> # A tibble: 2 × 4
#>   patient_id total_points bleeding_points bop_percent
#>   <chr>             <int>           <dbl>       <dbl>
#> 1 A                     6               1        16.7
#> 2 B                     6               3        50
```

6.2.3. Invalid characters: patient omitted

``` r
df3 <- tibble::tibble(
  patient_id = "BAD1",
  tooth      = c("11","XX","12","13","14","15"),
  tooth_side = rep("MB", 6),
  bop        = c(0,1,0,0,0,0)
)

compute_bop(df3)
#> Warning: Some patients were omitted due to invalid data:
#> - Patient BAD1: Invalid or non-permanent FDI teeth: XX
#> # A tibble: 0 × 4
#> # ℹ 4 variables: patient_id <chr>, total_points <int>, bleeding_points <dbl>,
#> #   bop_percent <dbl>
```

6.2.4. Invalid FDI tooth numbers: patient omitted

``` r
df4 <- tibble::tibble(
  patient_id = "BAD2",
  tooth      = c("11","12","99","13","14","15"),
  tooth_side = rep("MB", 6),
  bop        = 0
)

compute_bop(df4)
#> Warning: Some patients were omitted due to invalid data:
#> - Patient BAD2: Invalid or non-permanent FDI teeth: 99
#> # A tibble: 0 × 4
#> # ℹ 4 variables: patient_id <chr>, total_points <int>, bleeding_points <dbl>,
#> #   bop_percent <dbl>
```

6.2.5. Duplicate tooth‑side entries: patient omitted

``` r
df5 <- tibble::tibble(
  patient_id = "DUP",
  tooth      = c("11","11","11","11","11","11","11"),
  tooth_side = c("MB","MB","B","DB","ML","L","DL"),  # MB duplicated
  bop        = 0
)

compute_bop(df5)
#> Warning: Some patients were omitted due to invalid data:
#> - Patient DUP: Duplicated tooth-side entries detected.
#> # A tibble: 0 × 4
#> # ℹ 4 variables: patient_id <chr>, total_points <int>, bleeding_points <dbl>,
#> #   bop_percent <dbl>
```

6.2.6. Incorrect number of sites: patient omitted

``` r
df6 <- tibble::tibble(
  patient_id = "WRONG",
  tooth      = c("21","21","21","21"),  # only 4 sites
  tooth_side = c("MB","B","DB","ML"),
  bop        = c(0,1,0,0)
)

compute_bop(df6)
#> Warning: Some patients were omitted due to invalid data:
#> - Patient WRONG: Teeth with incorrect site counts (must be 6): 21
#> # A tibble: 0 × 4
#> # ℹ 4 variables: patient_id <chr>, total_points <int>, bleeding_points <dbl>,
#> #   bop_percent <dbl>
```

6.2.7. Mixed valid and invalid patients (processing continues)

``` r
df7 <- tibble::tibble(
  patient_id = c(rep("GOOD", 6), rep("BAD", 5)),
  tooth      = c(rep("31", 6),  "41","41","41","41","41"),  # BAD has only 5 sites
  tooth_side = c(rep(c("MB","B","DB","ML","L","DL"), 1),
                 c("MB","B","DB","ML","L")),
  bop        = c(1,0,0,0,0,0,   
                 0,0,0,0,0)
)

compute_bop(df7)
#> Warning: Some patients were omitted due to invalid data:
#> - Patient BAD: Teeth with incorrect site counts (must be 6): 41
#> # A tibble: 1 × 4
#>   patient_id total_points bleeding_points bop_percent
#>   <chr>             <int>           <dbl>       <dbl>
#> 1 GOOD                  6               1        16.7
```

### 6.3. Compute Plaque Index (PI, Silness & Löe)

6.3.1. Valid patients with complete 4‑site data per tooth

``` r
df1 <- tibble::tibble(
  patient_id = rep("P01", 8),
  tooth      = rep(c("11","12"), each = 4),
  tooth_side = rep(c("M","D","B","L"), 2),
  plaque     = c(0,1,1,0,   
                 2,1,0,1)   
)

compute_pi(df1)
#> # A tibble: 1 × 4
#>   patient_id total_sites total_score pi_index
#>   <chr>            <int>       <dbl>    <dbl>
#> 1 P01                  8           6     0.75
```

6.3.2. Multiple valid patients processed independently

``` r
df2 <- tibble::tibble(
  patient_id = c(rep("A", 4), rep("B", 4)),
  tooth      = c(rep("21", 4), rep("75", 4)),
  tooth_side = rep(c("M","D","B","L"), 2),
  plaque     = c(0,0,1,0,   
                 3,2,1,0)   
)

compute_pi(df2)
#> # A tibble: 2 × 4
#>   patient_id total_sites total_score pi_index
#>   <chr>            <int>       <dbl>    <dbl>
#> 1 A                    4           1     0.25
#> 2 B                    4           6     1.5
```

6.3.3. Invalid FDI tooth notation: patient omitted

``` r
df3 <- tibble::tibble(
  patient_id = "BAD1",
  tooth      = c("11","12","XX","13"),
  tooth_side = c("M","D","B","L"),
  plaque     = c(0,1,0,1)
)

compute_pi(df3)
#> Warning: Some patients were omitted due to invalid data:
#> - Patient BAD1: Invalid FDI tooth numbers: XX
#> # A tibble: 0 × 4
#> # ℹ 4 variables: patient_id <chr>, total_sites <int>, total_score <dbl>,
#> #   pi_index <dbl>
```

6.3.4. Invalid FDI tooth numbers: patient omitted

``` r
df4 <- tibble::tibble(
  patient_id = "BAD2",
  tooth      = c("11","12","99","13"),
  tooth_side = c("M","D","B","L"),
  plaque     = c(0,1,0,1)
)

compute_pi(df4)
#> Warning: Some patients were omitted due to invalid data:
#> - Patient BAD2: Invalid FDI tooth numbers: 99
#> # A tibble: 0 × 4
#> # ℹ 4 variables: patient_id <chr>, total_sites <int>, total_score <dbl>,
#> #   pi_index <dbl>
```

6.3.5. Duplicate tooth‑side entries: patient omitted

``` r
df5 <- tibble::tibble(
  patient_id = "DUP",
  tooth      = c("31","31","31","31","31"),
  tooth_side = c("M","M","D","B","L"),  # M duplicated
  plaque     = c(0,1,0,0,1)
)

compute_pi(df5)
#> Warning: Some patients were omitted due to invalid data:
#> - Patient DUP: Duplicated tooth-side entries detected.
#> # A tibble: 0 × 4
#> # ℹ 4 variables: patient_id <chr>, total_sites <int>, total_score <dbl>,
#> #   pi_index <dbl>
```

6.3.6. Incorrect number of sites: patient omitted

``` r
df6 <- tibble::tibble(
  patient_id = "WRONG",
  tooth      = c("41","41","41"),  # only 3 sites
  tooth_side = c("M","D","B"),
  plaque     = c(0,1,0)
)

compute_pi(df6)
#> Warning: Some patients were omitted due to invalid data:
#> - Patient WRONG: Teeth with incorrect site counts (must be 4): 41
#> # A tibble: 0 × 4
#> # ℹ 4 variables: patient_id <chr>, total_sites <int>, total_score <dbl>,
#> #   pi_index <dbl>
```

6.3.7. Invalid PI values (must be integers 0–3)

``` r
df7 <- tibble::tibble(
  patient_id = "BADVAL",
  tooth      = rep("11", 4),
  tooth_side = c("M","D","B","L"),
  plaque     = c(0,4,1,-1)   # invalid: 4 and -1
)

compute_pi(df7)
#> Error in validate_index_input(data, "PI"): PI values must be integers between 0 and 3 (Silness-Loe).
```

6.3.8. Mixed valid and invalid patients (processing continues)

``` r
df8 <- tibble::tibble(
  patient_id = c(rep("GOOD", 4), rep("BAD", 3)),
  tooth      = c(rep("22", 4),  rep("33", 3)),  # BAD has only 3 sites
  tooth_side = c("M","D","B","L", "M","D","B"),
  plaque     = c(1,0,1,0, 0,0,1)
)

compute_pi(df8)
#> Warning: Some patients were omitted due to invalid data:
#> - Patient BAD: Teeth with incorrect site counts (must be 4): 33
#> # A tibble: 1 × 4
#>   patient_id total_sites total_score pi_index
#>   <chr>            <int>       <dbl>    <dbl>
#> 1 GOOD                 4           2      0.5
```

### 6.4. Compute Plaque Control Record (PCR, O’Leary index)

6.4.1. Valid patient with complete 4‑site data per tooth

``` r
df1 <- tibble::tibble(
  patient_id = rep("P01", 8),
  tooth      = rep(c("11","12"), each = 4),
  tooth_side = rep(c("M","D","B","L"), 2),
  plaque     = c(1,0,0,1,   
                 0,0,1,0)   
)

compute_pcr(df1)
#> # A tibble: 1 × 4
#>   patient_id total_points plaque_points pcr_percent
#>   <chr>             <int>         <dbl>       <dbl>
#> 1 P01                   8             3        37.5
```

6.4.2. Multiple valid patients processed independently

``` r
df2 <- tibble::tibble(
  patient_id = c(rep("A", 4), rep("B", 4)),
  tooth      = c(rep("21", 4), rep("75", 4)),
  tooth_side = rep(c("M","D","B","L"), 2),
  plaque     = c(0,1,0,0,   # A → 1/4 = 25%
                 1,1,1,0)   # B → 3/4 = 75%
)

compute_pcr(df2)
#> # A tibble: 2 × 4
#>   patient_id total_points plaque_points pcr_percent
#>   <chr>             <int>         <dbl>       <dbl>
#> 1 A                     4             1          25
#> 2 B                     4             3          75
```

6.4.3. Invalid FDI tooth notation: patient omitted

``` r
df3 <- tibble::tibble(
  patient_id = "BAD1",
  tooth      = c("11","12","XX","13"),
  tooth_side = c("M","D","B","L"),
  plaque     = c(0,1,0,1)
)

compute_pcr(df3)
#> Warning: Some patients were omitted due to invalid data:
#> - Patient BAD1: Invalid FDI tooth numbers: XX
#> # A tibble: 0 × 4
#> # ℹ 4 variables: patient_id <chr>, total_points <int>, plaque_points <dbl>,
#> #   pcr_percent <dbl>
```

6.4.4. Invalid FDI tooth numbers: patient omitted

``` r
df4 <- tibble::tibble(
  patient_id = "BAD2",
  tooth      = c("11","12","99","13"),
  tooth_side = c("M","D","B","L"),
  plaque     = c(0,1,0,1)
)

compute_pcr(df4)
#> Warning: Some patients were omitted due to invalid data:
#> - Patient BAD2: Invalid FDI tooth numbers: 99
#> # A tibble: 0 × 4
#> # ℹ 4 variables: patient_id <chr>, total_points <int>, plaque_points <dbl>,
#> #   pcr_percent <dbl>
```

6.4.5. Duplicate tooth‑side entries: patient omitted

``` r
df5 <- tibble::tibble(
  patient_id = "DUP",
  tooth      = c("31","31","31","31","31"),
  tooth_side = c("M","M","D","B","L"),  # M duplicated
  plaque     = c(0,1,0,0,1)
)

compute_pcr(df5)
#> Warning: Some patients were omitted due to invalid data:
#> - Patient DUP: Duplicated tooth-side entries detected.
#> # A tibble: 0 × 4
#> # ℹ 4 variables: patient_id <chr>, total_points <int>, plaque_points <dbl>,
#> #   pcr_percent <dbl>
```

6.4.6. Incorrect number of sites: patient omitted

``` r
df6 <- tibble::tibble(
  patient_id = "WRONG",
  tooth      = c("41","41","41"),  # only 3 sites
  tooth_side = c("M","D","B"),
  plaque     = c(0,1,0)
)

compute_pcr(df6)
#> Warning: Some patients were omitted due to invalid data:
#> - Patient WRONG: Teeth with incorrect site counts (must be 4): 41
#> # A tibble: 0 × 4
#> # ℹ 4 variables: patient_id <chr>, total_points <int>, plaque_points <dbl>,
#> #   pcr_percent <dbl>
```

6.4.7. Mixed valid and invalid patients (processing continues)

``` r
df7 <- tibble::tibble(
  patient_id = c(rep("GOOD", 4), rep("BAD", 3)),
  tooth      = c(rep("22", 4),  rep("33", 3)),  # BAD has only 3 sites
  tooth_side = c("M","D","B","L", "M","D","B"),
  plaque     = c(1,0,1,0, 0,0,1)
)

compute_pcr(df7)
#> Warning: Some patients were omitted due to invalid data:
#> - Patient BAD: Teeth with incorrect site counts (must be 4): 33
#> # A tibble: 1 × 4
#>   patient_id total_points plaque_points pcr_percent
#>   <chr>             <int>         <dbl>       <dbl>
#> 1 GOOD                  4             2          50
```

### 6.5. Compute Periodontal Screening Index (PSI / CPI)

6.5.1. Tooth‑level input (valid patient)

``` r
df1 <- tibble::tibble(
  patient_id = rep("P01", 6),
  tooth      = c("14","15","16","24","25","26"),
  psi_code   = c(1,2,0,3,1,2)
)

compute_psi(df1)
#> # A tibble: 1 × 2
#>   patient_id   psi
#>   <chr>      <int>
#> 1 P01            3
```

6.5.2. Sextant‑level input (valid patient)

``` r
df2 <- tibble::tibble(
  patient_id = "S1",
  sextant    = 1:6,
  psi_code   = c(0,1,2,1,0,3)
)

compute_psi(df2)
#> # A tibble: 1 × 2
#>   patient_id   psi
#>   <chr>      <int>
#> 1 S1             3
```

6.5.3. Mixed input per patient (tooth‑level takes priority)

``` r
df3 <- tibble::tibble(
  patient_id = c(rep("M1", 3), rep("M1", 2)),
  tooth      = c("14","15","16", NA, NA),
  sextant    = c(NA, NA, NA, 1, 2),
  psi_code   = c(1,3,2, 0,1)
)

compute_psi(df3)
#> # A tibble: 1 × 2
#>   patient_id   psi
#>   <chr>      <int>
#> 1 M1             3
```

6.5.4. Invalid FDI tooth notation: patient omitted

``` r
df4 <- tibble::tibble(
  patient_id = "BAD1",
  tooth      = c("14","XX","16"),
  psi_code   = c(1,2,3)
)

compute_psi(df4)
#> Warning: Some patients were omitted due to invalid PSI data:
#> - Patient BAD1: Invalid FDI tooth numbers: XX
#> # A tibble: 0 × 2
#> # ℹ 2 variables: patient_id <chr>, psi <int>
```

6.5.5. Invalid FDI tooth numbers: patient omitted

``` r
df5 <- tibble::tibble(
  patient_id = "BAD2",
  tooth      = c("14","15","99"),
  psi_code   = c(1,2,3)
)

compute_psi(df5)
#> Warning: Some patients were omitted due to invalid PSI data:
#> - Patient BAD2: Invalid FDI tooth numbers: 99
#> # A tibble: 0 × 2
#> # ℹ 2 variables: patient_id <chr>, psi <int>
```

6.5.6. Invalid PSI values (must be integers 0–4)

``` r
df6 <- tibble::tibble(
  patient_id = "BADVAL",
  tooth      = c("14","15","16"),
  psi_code   = c(0,5,-1)   # invalid: 5 and -1
)

compute_psi(df6)
#> Warning: Some patients were omitted due to invalid PSI data:
#> - Patient BADVAL: PSI values must be between 0 and 4.
#> # A tibble: 0 × 2
#> # ℹ 2 variables: patient_id <chr>, psi <int>
```

6.5.7. Sextant‑level input with invalid sextant numbers

``` r
df7 <- tibble::tibble(
  patient_id = "BADSEXT",
  sextant    = c(1,2,7),   # 7 invalid
  psi_code   = c(1,2,3)
)

compute_psi(df7)
#> Warning: Some patients were omitted due to invalid PSI data:
#> - Patient BADSEXT: Invalid sextant identifiers (must be 1-6): 7
#> # A tibble: 0 × 2
#> # ℹ 2 variables: patient_id <chr>, psi <int>
```

6.5.8. Tooth‑level input where sextant cannot be assigned (primary
dentition)

``` r
df8 <- tibble::tibble(
  patient_id = "NOSEXT",
  tooth      = c("51","52","53"),  # primary teeth (FDI notation)
  psi_code   = c(1,2,3)
)

compute_psi(df8)
#> Warning: Some patients were omitted due to invalid PSI data:
#> - Patient NOSEXT: Invalid FDI tooth numbers: 51, 52, 53
#> # A tibble: 0 × 2
#> # ℹ 2 variables: patient_id <chr>, psi <int>
```

6.5.9. Mixed valid and invalid patients (processing continues)

``` r
df9 <- tibble::tibble(
  patient_id = c(rep("GOOD", 3), rep("BAD", 3)),
  tooth      = c("14","15","16", "14","XX","16"),
  psi_code   = c(1,2,3, 1,2,3)
)

compute_psi(df9)
#> Warning: Some patients were omitted due to invalid PSI data:
#> - Patient BAD: Invalid FDI tooth numbers: XX
#> # A tibble: 1 × 2
#>   patient_id   psi
#>   <chr>      <int>
#> 1 GOOD           3
```

### 7. Compute Decay Index

#### 7.1. Compute DMFT index (Decayed, Missing, Filled Teeth)

Includes `normalize_dmft_format()` and `compute_dmft()` functions.

7.1.1. Valid patients with permanent FDI teeth only

``` r

# Patient 1: status format
teeth <- c(as.character(11:17), as.character(21:27),
           as.character(31:37), as.character(41:47))

df_status <- tibble(
  patient_id = 1,
  tooth = teeth,
  status = "S"
)

df_status$status[df_status$tooth == "11"] <- "D"
df_status$status[df_status$tooth == "16"] <- "F"
df_status$status[df_status$tooth == "26"] <- "M"

df_status_norm <- normalize_dmft_format(df_status)

# Patient 2: binary format
df_binary <- tibble(
  patient_id = 2,
  tooth = teeth,
  D = 0, M = 0, F = 0
)

df_binary$D[df_binary$tooth == "21"] <- 1
df_binary$F[df_binary$tooth == "36"] <- 1
df_binary$M[df_binary$tooth == "47"] <- 1

df_binary_norm <- normalize_dmft_format(df_binary)

# Combine normalized datasets
df_all <- bind_rows(df_status_norm, df_binary_norm)

# Compute DMFT
compute_dmft(df_all)
#> # A tibble: 2 × 2
#>   patient_id  dmft
#>        <dbl> <int>
#> 1          1     3
#> 2          2     3
```

7.1.2. Temporary teeth detected: patient omitted

``` r
teeth <- c(as.character(11:17), as.character(21:27),
           as.character(31:37), as.character(41:47))

df2 <- tibble(
  patient_id = "TEMP",
  tooth      = c(teeth, "51"),  # 51 is a primary tooth
  D = 0, M = 0, F = 0
)

compute_dmft(df2)
#> Warning: Some patients were omitted due to invalid DMFT data:
#> - Patient TEMP: Primary teeth detected; DMFT applies only to permanent dentition.
#> # A tibble: 0 × 2
#> # ℹ 2 variables: patient_id <chr>, dmft <int>
```

7.1.3. Invalid FDI tooth notation: patient omitted

``` r
teeth_bad <- c(as.character(11:17), "XX", as.character(21:27),
               as.character(31:37), as.character(41:47))

df3 <- tibble(
  patient_id = "BAD1",
  tooth      = teeth_bad,
  D = 0, M = 0, F = 0
)

compute_dmft(df3)
#> Warning: Some patients were omitted due to invalid DMFT data:
#> - Patient BAD1: Invalid permanent FDI codes: XX
#> # A tibble: 0 × 2
#> # ℹ 2 variables: patient_id <chr>, dmft <int>
```

7.1.4. Invalid FDI permanent tooth numbers: patient omitted

``` r
teeth_badnum <- c(as.character(11:17), "99", as.character(21:27),
                  as.character(31:37), as.character(41:47))

df4 <- tibble(
  patient_id = "BAD2",
  tooth      = teeth_badnum,
  D = 0, M = 0, F = 0
)

compute_dmft(df4)
#> Warning: Some patients were omitted due to invalid DMFT data:
#> - Patient BAD2: Invalid permanent FDI codes: 99
#> # A tibble: 0 × 2
#> # ℹ 2 variables: patient_id <chr>, dmft <int>
```

7.1.5. Invalid D/M/F values (must be 0 or 1)

``` r
teeth <- c(as.character(11:17), as.character(21:27),
           as.character(31:37), as.character(41:47))

df5 <- tibble(
  patient_id = "BADVAL",
  tooth      = teeth,
  D = c(2, rep(0, length(teeth)-1)),  # invalid
  M = 0,
  F = 0
)

compute_dmft(df5)
#> Warning: Some patients were omitted due to invalid DMFT data:
#> - Patient BADVAL: D, M, and F values must be 0 or 1.
#> # A tibble: 0 × 2
#> # ℹ 2 variables: patient_id <chr>, dmft <int>
```

7.1.6. Conflicting D/M/F values (more than one = 1)

``` r
teeth <- c(as.character(11:17), as.character(21:27),
           as.character(31:37), as.character(41:47))

df6 <- tibble(
  patient_id = "CONFLICT",
  tooth      = teeth,
  D = c(1, rep(0, length(teeth)-1)),
  M = c(1, rep(0, length(teeth)-1)),  # conflict on tooth 11
  F = 0
)

compute_dmft(df6)
#> Warning: Some patients were omitted due to invalid DMFT data:
#> - Patient CONFLICT: D, M, and F must be mutually exclusive per tooth.
#> # A tibble: 0 × 2
#> # ℹ 2 variables: patient_id <chr>, dmft <int>
```

7.1.7. Mixed valid and invalid patients (processing continues)

``` r
teeth <- c(as.character(11:17), as.character(21:27),
           as.character(31:37), as.character(41:47))

# GOOD patient
df_good <- tibble(
  patient_id = "GOOD",
  tooth = teeth,
  D = 0, M = 0, F = 0
)

df_good$D[df_good$tooth == "11"] <- 1
df_good$F[df_good$tooth == "36"] <- 1

# BAD patient: includes temporary tooth
df_bad <- tibble(
  patient_id = "BAD",
  tooth = c(teeth, "51"),
  D = 0, M = 0, F = 0
)

df7 <- bind_rows(df_good, df_bad)

compute_dmft(df7)
#> Warning: Some patients were omitted due to invalid DMFT data:
#> - Patient BAD: Primary teeth detected; DMFT applies only to permanent dentition.
#> # A tibble: 1 × 2
#>   patient_id  dmft
#>   <chr>      <int>
#> 1 GOOD           2
```

#### 7.2. Compute d‑e‑f index for primary teeth (FDI notation only)

Includes `normalize_def_format()` and `compute_def()` functions.

7.2.1. Valid primary teeth in FDI notation

``` r

# Full primary dentition in FDI notation
teeth_primary <- c(as.character(51:55), as.character(61:65),
                   as.character(71:75), as.character(81:85))

# Patient 1: status format
df_status <- tibble(
  patient_id = "P01",
  tooth      = teeth_primary,
  status     = "S"
)

df_status$status[df_status$tooth == "51"] <- "D"
df_status$status[df_status$tooth == "52"] <- "E"
df_status$status[df_status$tooth == "75"] <- "F"

df_status_norm <- normalize_def_format(df_status)

# Patient 2: binary format
df_binary <- tibble(
  patient_id = "P02",
  tooth      = teeth_primary,
  D = 0, E = 0, F = 0
)

df_binary$D[df_binary$tooth == "61"] <- 1
df_binary$E[df_binary$tooth == "62"] <- 1
df_binary$F[df_binary$tooth == "85"] <- 1

df_binary_norm <- normalize_def_format(df_binary)

# Combine normalized datasets
df_all <- bind_rows(df_status_norm, df_binary_norm)

# Compute d-e-f index
compute_def(df_all)
#> # A tibble: 2 × 2
#>   patient_id   def
#>   <chr>      <int>
#> 1 P01            3
#> 2 P02            3
```

7.2.2. Patients omitted due to permanent teeth (any notation)

``` r
teeth_primary <- c(as.character(51:55), as.character(61:65),
                   as.character(71:75), as.character(81:85))

# Replace one primary tooth by a permanent tooth (FDI 11)
teeth_mixed <- teeth_primary
teeth_mixed[teeth_mixed == "52"] <- "11"

df2 <- tibble(
  patient_id = "MIXED_PERM",
  tooth      = teeth_mixed,
  D = 1, E = 0, F = 0
)

compute_def(df2)
#> Warning: Some patients were omitted due to invalid DEF data:
#> - Patient MIXED_PERM: Permanent teeth detected. DEF is for primary teeth only.
#> # A tibble: 0 × 2
#> # ℹ 2 variables: patient_id <chr>, def <int>
```

7.2.3. Primary teeth in Universal notation: patient omitted

``` r
# Universal primary teeth A–T 
teeth_universal <- LETTERS[1:20]

df3 <- tibble(
  patient_id = "U1",
  tooth      = teeth_universal,
  D = c(1, rep(0, 19)),
  E = c(0, 1, rep(0, 18)),
  F = c(0, 0, 1, rep(0, 17))
)

compute_def(df3)
#> Warning: Some patients were omitted due to invalid DEF data:
#> - Patient U1: Non-FDI primary notation detected. Use FDI.
#> # A tibble: 0 × 2
#> # ℹ 2 variables: patient_id <chr>, def <int>
```

7.2.4. Primary teeth in Alphanumeric notation: patient omitted

``` r
# Example set of primary alphanumeric codes
teeth_alpha <- c("URA","URB","URC","URD","URE",
                 "ULA","ULB","ULC","ULD","ULE",
                 "LRA","LRB","LRC","LRD","LRE",
                 "LLA","LLB","LLC","LLD","LLE")

df4 <- tibble(
  patient_id = "ALPHA",
  tooth      = teeth_alpha,
  D = c(1, rep(0, 19)),
  E = c(0, 1, rep(0, 18)),
  F = c(0, 0, 1, rep(0, 17))
)

compute_def(df4)
#> Warning: Some patients were omitted due to invalid DEF data:
#> - Patient ALPHA: Non-FDI primary notation detected. Use FDI.
#> # A tibble: 0 × 2
#> # ℹ 2 variables: patient_id <chr>, def <int>
```

7.2.5. Invalid FDI primary numbers: patient omitted

``` r
teeth_primary <- c(as.character(51:55), as.character(61:65),
                   as.character(71:75), as.character(81:85))

# Introduce invalid FDI primary codes
teeth_bad <- teeth_primary
teeth_bad[1:3] <- c("59","66","99")

df5 <- tibble(
  patient_id = "BADFDI",
  tooth      = teeth_bad,
  D = 1, E = 0, F = 0
)

compute_def(df5)
#> Warning: Some patients were omitted due to invalid DEF data:
#> - Patient BADFDI: Invalid FDI primary teeth: 59, 66, 99
#> # A tibble: 0 × 2
#> # ℹ 2 variables: patient_id <chr>, def <int>
```

7.2.6. Invalid D/E/F values (must be 0 or 1)

``` r
teeth_primary <- c(as.character(51:55), as.character(61:65),
                   as.character(71:75), as.character(81:85))

df6 <- tibble(
  patient_id = "BADVAL",
  tooth      = teeth_primary,
  D = c(2, rep(0, length(teeth_primary) - 1)),  # invalid
  E = 0,
  F = 0
)

compute_def(df6)
#> Warning: Some patients were omitted due to invalid DEF data:
#> - Patient BADVAL: D, E, and F values must be 0 or 1.
#> # A tibble: 0 × 2
#> # ℹ 2 variables: patient_id <chr>, def <int>
```

7.2.7. Conflicting D/E/F values (more than one = 1)

``` r
teeth_primary <- c(as.character(51:55), as.character(61:65),
                   as.character(71:75), as.character(81:85))

df7 <- tibble(
  patient_id = "CONFLICT",
  tooth      = teeth_primary,
  D = c(1, rep(0, length(teeth_primary) - 1)),
  E = c(1, rep(0, length(teeth_primary) - 1)),  # conflict on first tooth
  F = 0
)

compute_def(df7)
#> Warning: Some patients were omitted due to invalid DEF data:
#> - Patient CONFLICT: D/E/F are mutually exclusive per tooth.
#> # A tibble: 0 × 2
#> # ℹ 2 variables: patient_id <chr>, def <int>
```

7.2.8. Mixed valid and invalid patients (processing continues)

``` r
teeth_primary <- c(as.character(51:55), as.character(61:65),
                   as.character(71:75), as.character(81:85))

# GOOD: full valid primary dentition
df_good <- tibble(
  patient_id = "GOOD",
  tooth      = teeth_primary,
  D = 0, E = 0, F = 0
)

df_good$D[df_good$tooth == "51"] <- 1
df_good$F[df_good$tooth == "75"] <- 1

# BAD: same positions but one permanent tooth introduced
teeth_bad <- teeth_primary
teeth_bad[teeth_bad == "52"] <- "11"

df_bad <- tibble(
  patient_id = "BAD",
  tooth      = teeth_bad,
  D = 1, E = 0, F = 0
)

df8 <- bind_rows(df_good, df_bad)

compute_def(df8)
#> Warning: Some patients were omitted due to invalid DEF data:
#> - Patient BAD: Permanent teeth detected. DEF is for primary teeth only.
#> # A tibble: 1 × 2
#>   patient_id   def
#>   <chr>      <int>
#> 1 GOOD           2
```

7.2.9. Missing primary tooth record: patient omitted

``` r
teeth_primary <- c(as.character(51:55), as.character(61:65),
                   as.character(71:75), as.character(81:85))

# Remove one tooth → incomplete primary dentition
teeth_incomplete <- teeth_primary[teeth_primary != "54"]

df_missing <- tibble(
  patient_id = "MISS1",
  tooth      = teeth_incomplete,
  D = 0,
  E = 0,
  F = 0
)

compute_def(df_missing)
#> Warning: Some patients were omitted due to invalid DEF data:
#> - Patient MISS1: Incomplete primary dentition; missing teeth: 54
#> # A tibble: 0 × 2
#> # ℹ 2 variables: patient_id <chr>, def <int>
```

### 8. Compute Orthodontic Index

### 8.1. Score ICON components from clinical measurements

8.1.1. Process valid patients

``` r
df1 <- tibble::tibble(
  patient_id = c("P01","P02"),
  time = c("pre","post"),
  aesthetic_component = c(5, 8),
  upper_crowding_mm = c(3, NA),
  upper_spacing_mm = c(NA, 4),
  crossbite = c(FALSE, TRUE),
  incisor_openbite_mm = c(0, 2),
  incisor_overbite_category = c(1, 0),
  buccal_ap_left = c(0, 1),
  buccal_ap_right = c(0, 1),
  impacted_teeth = c(FALSE, FALSE)
)

score_icon_components(df1)
#> $scores
#> # A tibble: 2 × 7
#>   patient_id time  aesthetic_component upper_arch_crowding_score crossbite_score
#>   <chr>      <chr>               <dbl>                     <int>           <int>
#> 1 P01        pre                     5                         1               0
#> 2 P02        post                    8                         1               1
#> # ℹ 2 more variables: vertical_score <int>, buccal_ap_score <int>
#> 
#> $errors
#> # A tibble: 0 × 3
#> # ℹ 3 variables: row <int>, patient_id <chr>, error <chr>
```

8.1.2. Collect errors without stopping (`.on_error = "collect"`)

``` r
df2 <- tibble::tibble(
  patient_id = c("A","B","C"),
  time = c("pre","wrong","post"),
  aesthetic_component = c(5, 12, 4),   # 12 is invalid
  upper_crowding_mm = c(1, 3, NA),
  upper_spacing_mm = c(NA, NA, NA),    # C has neither crowding nor spacing
  crossbite = c("yes", "no", NA),      # NA is invalid
  incisor_openbite_mm = c(0, 1, 0),
  incisor_overbite_category = c(1, 1, 1),
  buccal_ap_left = c(0, 0, 0),
  buccal_ap_right = c(0, 0, 0)
)

out <- score_icon_components(df2, .on_error = "collect", .warn = TRUE)
#> Warning: Column 'crossbite' coerced to logical.

out$scores
#> # A tibble: 1 × 7
#>   patient_id time  aesthetic_component upper_arch_crowding_score crossbite_score
#>   <chr>      <chr>               <dbl>                     <int>           <int>
#> 1 A          pre                     5                         0               1
#> # ℹ 2 more variables: vertical_score <int>, buccal_ap_score <int>
out$errors
#> # A tibble: 2 × 3
#>     row patient_id error                                     
#>   <int> <chr>      <chr>                                     
#> 1     2 B          aesthetic_component must be integer [1,10]
#> 2     3 C          Need crowding or spacing value
```

8.1.3. Stop immediately when an error is found (`.on_error = "stop"`)

``` r
df3 <- tibble::tibble(
  patient_id = "BAD",
  time = "maybe",
  aesthetic_component = 3,
  upper_crowding_mm = 1,
  upper_spacing_mm = NA,
  crossbite = TRUE,
  incisor_openbite_mm = 0,
  incisor_overbite_category = 1,
  buccal_ap_left = 0,
  buccal_ap_right = 0
)

score_icon_components(df3, .on_error = "stop")
#> # A tibble: 1 × 7
#>   patient_id time  aesthetic_component upper_arch_crowding_score crossbite_score
#>   <chr>      <chr>               <dbl>                     <int>           <int>
#> 1 BAD        maybe                   3                         0               1
#> # ℹ 2 more variables: vertical_score <int>, buccal_ap_score <int>
```

8.1.4. Impacted teeth (forces crowding score = 5)

``` r
df4 <- tibble::tibble(
  patient_id = "X1",
  time = "pre",
  aesthetic_component = 7,
  upper_crowding_mm = 2,
  upper_spacing_mm = 0,
  crossbite = FALSE,
  incisor_openbite_mm = 0,
  incisor_overbite_category = 1,
  buccal_ap_left = 1,
  buccal_ap_right = 1,
  impacted_teeth = TRUE
)

print(score_icon_components(df4)$scores, width = Inf)
#> # A tibble: 1 × 7
#>   patient_id time  aesthetic_component upper_arch_crowding_score crossbite_score
#>   <chr>      <chr>               <dbl>                     <int>           <int>
#> 1 X1         pre                     7                         5               0
#>   vertical_score buccal_ap_score
#>            <int>           <int>
#> 1              1               2
```

8.1.5. Soft coercion of TRUE/FALSE with `.warn = TRUE`

``` r
df5 <- tibble::tibble(
  patient_id = "Z9",
  time = "post",
  aesthetic_component = 4,
  upper_crowding_mm = 0,
  upper_spacing_mm = 3,
  crossbite = "yes",          # coerced to TRUE
  incisor_openbite_mm = 1,
  incisor_overbite_category = 0,
  buccal_ap_left = 0,
  buccal_ap_right = 1,
  impacted_teeth = "no"       # coerced to FALSE
)

score_icon_components(df5, .warn = TRUE)
#> Warning: Column 'crossbite' coerced to logical.
#> Warning: Column 'impacted_teeth' coerced to logical.
#> $scores
#> # A tibble: 1 × 7
#>   patient_id time  aesthetic_component upper_arch_crowding_score crossbite_score
#>   <chr>      <chr>               <dbl>                     <int>           <int>
#> 1 Z9         post                    4                         1               1
#> # ℹ 2 more variables: vertical_score <int>, buccal_ap_score <int>
#> 
#> $errors
#> # A tibble: 0 × 3
#> # ℹ 3 variables: row <int>, patient_id <chr>, error <chr>
```

8.1.6. Vertical scoring (open bite vs. overbite)

``` r
df6 <- tibble::tibble(
  patient_id = c("V1","V2","V3"),
  time = "pre",
  aesthetic_component = 5,
  upper_crowding_mm = 0,
  upper_spacing_mm = 0,
  crossbite = FALSE,
  incisor_openbite_mm = c(0, 3, NA),      # open bite: 0 → score 0, 3 mm → score 3
  incisor_overbite_category = c(2, NA, 3), # overbite: 2 → score 2, 3 → score 3
  buccal_ap_left = 0,
  buccal_ap_right = 0
)

score_icon_components(df6)
#> $scores
#> # A tibble: 3 × 7
#>   patient_id time  aesthetic_component upper_arch_crowding_score crossbite_score
#>   <chr>      <chr>               <dbl>                     <int>           <int>
#> 1 V1         pre                     5                         0               0
#> 2 V2         pre                     5                         0               0
#> 3 V3         pre                     5                         0               0
#> # ℹ 2 more variables: vertical_score <int>, buccal_ap_score <int>
#> 
#> $errors
#> # A tibble: 0 × 3
#> # ℹ 3 variables: row <int>, patient_id <chr>, error <chr>
```

8.1.7. Buccal AP scoring (sum of left + right)

``` r
df7 <- tibble::tibble(
  patient_id = c("B1","B2","B3"),
  time = "post",
  aesthetic_component = 6,
  upper_crowding_mm = 0,
  upper_spacing_mm = 0,
  crossbite = FALSE,
  incisor_openbite_mm = 0,
  incisor_overbite_category = 1,
  buccal_ap_left = c(0,1,2),
  buccal_ap_right = c(0,1,2)
)

score_icon_components(df7)
#> $scores
#> # A tibble: 3 × 7
#>   patient_id time  aesthetic_component upper_arch_crowding_score crossbite_score
#>   <chr>      <chr>               <dbl>                     <int>           <int>
#> 1 B1         post                    6                         0               0
#> 2 B2         post                    6                         0               0
#> 3 B3         post                    6                         0               0
#> # ℹ 2 more variables: vertical_score <int>, buccal_ap_score <int>
#> 
#> $errors
#> # A tibble: 0 × 3
#> # ℹ 3 variables: row <int>, patient_id <chr>, error <chr>
```

8.1.8. Crowding/spacing validation (negative, too large, or both
missing)

``` r
df8 <- tibble::tibble(
  patient_id = c("Cneg","Cbig","Cnone"),
  time = "pre",
  aesthetic_component = 5,
  upper_crowding_mm = c(-1, 25, NA),   # -1 invalid, 25 exceeds default max 20
  upper_spacing_mm = c(0, 0, NA),      
  crossbite = FALSE,
  incisor_openbite_mm = 0,
  incisor_overbite_category = 1,
  buccal_ap_left = 0,
  buccal_ap_right = 0
)

score_icon_components(df8, .on_error = "collect")
#> $scores
#> # A tibble: 2 × 7
#>   patient_id time  aesthetic_component upper_arch_crowding_score crossbite_score
#>   <chr>      <chr>               <dbl>                     <int>           <int>
#> 1 Cneg       pre                     5                         0               0
#> 2 Cbig       pre                     5                         5               0
#> # ℹ 2 more variables: vertical_score <int>, buccal_ap_score <int>
#> 
#> $errors
#> # A tibble: 1 × 3
#>     row patient_id error                         
#>   <int> <chr>      <chr>                         
#> 1     3 Cnone      Need crowding or spacing value
```

### 8.2. Compute overall ICON scores

8.2.1. Basic pre/post computation

``` r
df1 <- tibble::tibble(
  patient_id = c("P01","P01"),
  time = c("pre","post"),
  aesthetic_component = c(5, 2),
  upper_crowding_mm = c(10, 0),
  upper_spacing_mm = c(0, 0),
  crossbite = c(FALSE, FALSE),
  incisor_openbite_mm = c(0, 0),
  incisor_overbite_category = c(2, 1),
  buccal_ap_left = c(1, 0),
  buccal_ap_right = c(1, 0),
  impacted_teeth = c(FALSE, FALSE)
)

compute_icon(df1)
#> $scores
#> # A tibble: 1 × 8
#>   patient_id icon_pre icon_post icon_improvement treatment_need complexity_grade
#>   <chr>         <dbl>     <dbl>            <dbl> <lgl>          <fct>           
#> 1 P01              64        18               -8 TRUE           Difficult       
#> # ℹ 2 more variables: outcome_acceptable <lgl>, improvement_grade <fct>
#> 
#> $errors
#> # A tibble: 0 × 3
#> # ℹ 3 variables: row <int>, patient_id <chr>, error <chr>
```

8.2.2. Missing posttreatment score

``` r
df2 <- tibble::tibble(
  patient_id = "X1",
  time = "pre",
  aesthetic_component = 6,
  upper_crowding_mm = 4,
  upper_spacing_mm = 0,
  crossbite = FALSE,
  incisor_openbite_mm = 0,
  incisor_overbite_category = 2,
  buccal_ap_left = 1,
  buccal_ap_right = 1
)

compute_icon(df2)
#> $scores
#> # A tibble: 1 × 8
#>   patient_id icon_pre icon_post icon_improvement treatment_need complexity_grade
#>   <chr>         <dbl>     <dbl>            <dbl> <lgl>          <fct>           
#> 1 X1               61        NA               NA TRUE           Moderate        
#> # ℹ 2 more variables: outcome_acceptable <lgl>, improvement_grade <fct>
#> 
#> $errors
#> # A tibble: 0 × 3
#> # ℹ 3 variables: row <int>, patient_id <chr>, error <chr>
```

ICON rules: - Improvement cannot be assessed without a post score. -
Outcome acceptability cannot be assessed without a post score.

8.2.3. Missing pretreatment score

``` r
df3 <- tibble::tibble(
  patient_id = "Y1",
  time = "post",
  aesthetic_component = 3,
  upper_crowding_mm = 0,
  upper_spacing_mm = 2,
  crossbite = FALSE,
  incisor_openbite_mm = 0,
  incisor_overbite_category = 1,
  buccal_ap_left = 0,
  buccal_ap_right = 0
)

compute_icon(df3)
#> $scores
#> # A tibble: 1 × 8
#>   patient_id icon_post icon_pre icon_improvement treatment_need complexity_grade
#>   <chr>          <dbl>    <dbl>            <dbl> <lgl>          <fct>           
#> 1 Y1                30       NA               NA NA             <NA>            
#> # ℹ 2 more variables: outcome_acceptable <lgl>, improvement_grade <fct>
#> 
#> $errors
#> # A tibble: 0 × 3
#> # ℹ 3 variables: row <int>, patient_id <chr>, error <chr>
```

ICON rules:

- Treatment need cannot be assessed without a pretreatment score.
- Improvement cannot be computed without both pre and post.

8.2.4. Duplicate rows per patient/time

``` r
df4 <- tibble::tibble(
  patient_id = c("D1","D1"),
  time = c("pre","pre"),
  aesthetic_component = c(5, 6),
  upper_crowding_mm = c(3, 3),
  upper_spacing_mm = c(0, 0),
  crossbite = c(FALSE, FALSE),
  incisor_openbite_mm = c(0, 0),
  incisor_overbite_category = c(1, 1),
  buccal_ap_left = c(0, 0),
  buccal_ap_right = c(0, 0)
)

compute_icon(df4, .on_error = "collect", .warn = TRUE)
#> Warning in compute_icon(df4, .on_error = "collect", .warn = TRUE): Duplicate
#> entries found for the same time point (pre/post) for patients: D1
#> $scores
#> # A tibble: 0 × 8
#> # ℹ 8 variables: patient_id <chr>, icon_pre <dbl>, icon_post <dbl>,
#> #   icon_improvement <dbl>, treatment_need <lgl>, complexity_grade <fct>,
#> #   outcome_acceptable <lgl>, improvement_grade <fct>
#> 
#> $errors
#> # A tibble: 1 × 3
#>     row patient_id error                                                     
#>   <int> <chr>      <chr>                                                     
#> 1    NA D1         Duplicate entries found for the same time point (pre/post)
```

8.2.5. Collecting upstream validation errors

``` r
df5 <- tibble::tibble(
  patient_id = c("A","B"),
  time = c("pre","post"),
  aesthetic_component = c(5, 12),   # 12 invalid
  upper_crowding_mm = c(3, 2),
  upper_spacing_mm = c(0, 0),
  crossbite = c(FALSE, TRUE),
  incisor_openbite_mm = c(0, 0),
  incisor_overbite_category = c(1, 1),
  buccal_ap_left = c(0, 0),
  buccal_ap_right = c(0, 0)
)

compute_icon(df5, .on_error = "collect")
#> $scores
#> # A tibble: 1 × 8
#>   patient_id icon_pre icon_post icon_improvement treatment_need complexity_grade
#>   <chr>         <dbl>     <dbl>            <dbl> <lgl>          <fct>           
#> 1 A                44        NA               NA TRUE           Mild            
#> # ℹ 2 more variables: outcome_acceptable <lgl>, improvement_grade <fct>
#> 
#> $errors
#> # A tibble: 1 × 3
#>     row patient_id error                                     
#>   <int> <chr>      <chr>                                     
#> 1     2 B          aesthetic_component must be integer [1,10]
```

Only valid patients are included in the final ICON output.

8.2.6. Full pre/post example with all classifications

``` r
df6 <- tibble::tibble(
  patient_id = c("Z1","Z1"),
  time = c("pre","post"),
  aesthetic_component = c(8, 4),
  upper_crowding_mm = c(12, 3),
  upper_spacing_mm = c(0, 0),
  crossbite = c(TRUE, FALSE),
  incisor_openbite_mm = c(0, 0),
  incisor_overbite_category = c(3, 1),
  buccal_ap_left = c(2, 1),
  buccal_ap_right = c(2, 1)
)

compute_icon(df6)
#> $scores
#> # A tibble: 1 × 8
#>   patient_id icon_pre icon_post icon_improvement treatment_need complexity_grade
#>   <chr>         <dbl>     <dbl>            <dbl> <lgl>          <fct>           
#> 1 Z1              100        43              -72 TRUE           Very difficult  
#> # ℹ 2 more variables: outcome_acceptable <lgl>, improvement_grade <fct>
#> 
#> $errors
#> # A tibble: 0 × 3
#> # ℹ 3 variables: row <int>, patient_id <chr>, error <chr>
```

### 9. Descriptive Statistics

- **`analyze_descriptives()`**

``` r


# Permanent teeth required for DMFT
teeth_perm <- c(as.character(11:17), as.character(21:27),
                as.character(31:37), as.character(41:47))


# Patient 1: status format
df_status <- tibble(
  patient_id = "P01",
  tooth      = teeth_perm,
  status     = "S"
)

df_status$status[df_status$tooth == "11"] <- "D"
df_status$status[df_status$tooth == "16"] <- "D"
df_status$status[df_status$tooth == "26"] <- "M"

df_status_norm <- normalize_dmft_format(df_status)


# Patient 2: binary format
df_bin2 <- tibble(
  patient_id = "P02",
  tooth      = teeth_perm,
  D = 0, M = 0, F = 0
)

df_bin2$D[df_bin2$tooth == "21"] <- 1
df_bin2$F[df_bin2$tooth == "36"] <- 1

df_bin2_norm <- normalize_dmft_format(df_bin2)

# Patient 3: binary format
df_bin3 <- tibble(
  patient_id = "P03",
  tooth      = teeth_perm,
  D = 0, M = 0, F = 0
)

df_bin3$D[df_bin3$tooth == "14"] <- 1
df_bin3$D[df_bin3$tooth == "15"] <- 1
df_bin3$M[df_bin3$tooth == "47"] <- 1

df_bin3_norm <- normalize_dmft_format(df_bin3)

# Combine all normalized datasets
df_all <- bind_rows(df_status_norm, df_bin2_norm, df_bin3_norm)

# Compute DMFT
dmft_results <- compute_dmft(df_all)
dmft_results
#> # A tibble: 3 × 2
#>   patient_id  dmft
#>   <chr>      <int>
#> 1 P01            3
#> 2 P02            2
#> 3 P03            3

analyze_descriptives(dmft_results$dmft)
#> # A tibble: 1 × 10
#>       n  mean median    sd   min   max   p25   p75 normality_p outliers
#>   <int> <dbl>  <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>       <dbl> <chr>   
#> 1     3  2.67      3 0.577     2     3   2.5     3           0 <NA>
```

``` r
df_icon <- tibble::tibble(
  patient_id = c("Z1","Z1","Z2","Z2","Z3","Z3"),
  time       = c("pre","post","pre","post","pre","post"),

  aesthetic_component       = c(8,4,  6,3,  5,4),
  upper_crowding_mm         = c(12,3,  4,1,  2,1),
  upper_spacing_mm          = c(0,0,  0,0,  0,0),
  crossbite                 = c(TRUE,FALSE,  FALSE,FALSE,  TRUE,TRUE),
  incisor_openbite_mm       = c(0,0,  0,0,  1,0),
  incisor_overbite_category = c(3,1,  2,1,  3,2),
  buccal_ap_left            = c(2,1,  1,0,  2,1),
  buccal_ap_right           = c(2,1,  1,0,  2,1)
)

icon_res <- compute_icon(df_icon)$scores
icon_res
#> # A tibble: 3 × 8
#>   patient_id icon_pre icon_post icon_improvement treatment_need complexity_grade
#>   <chr>         <dbl>     <dbl>            <dbl> <lgl>          <fct>           
#> 1 Z1              100        43              -72 TRUE           Very difficult  
#> 2 Z2               61        25              -39 TRUE           Moderate        
#> 3 Z3               69        47             -119 TRUE           Difficult       
#> # ℹ 2 more variables: outcome_acceptable <lgl>, improvement_grade <fct>

# ICON pretreatment scores
analyze_descriptives(icon_res$icon_pre)
#> # A tibble: 1 × 10
#>       n  mean median    sd   min   max   p25   p75 normality_p outliers
#>   <int> <dbl>  <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>       <dbl> <chr>   
#> 1     3  76.7     69  20.6    61   100    65  84.5       0.373 <NA>

# ICON posttreatment scores
analyze_descriptives(icon_res$icon_post)
#> # A tibble: 1 × 10
#>       n  mean median    sd   min   max   p25   p75 normality_p outliers
#>   <int> <dbl>  <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>       <dbl> <chr>   
#> 1     3  38.3     43  11.7    25    47    34    45       0.328 <NA>

# ICON improvement (I = pre - 4*post)
analyze_descriptives(icon_res$icon_improvement)
#> # A tibble: 1 × 10
#>       n  mean median    sd   min   max   p25   p75 normality_p outliers
#>   <int> <dbl>  <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>       <dbl> <chr>   
#> 1     3 -76.7    -72  40.2  -119   -39 -95.5 -55.5       0.808 <NA>
```

- **`analyze_prevalence()`**

``` r
# Extract D counts per patient
D_counts <- df_all %>%
  group_by(patient_id) %>%
  summarise(D = sum(D)) %>%
  pull(D)

# Convert to binary
D_binary <- D_counts > 0

# Analyze prevalence
analyze_prevalence(D_binary)
#> # A tibble: 1 × 5
#>       n n_positive prevalence ci_low ci_high
#>   <int>      <int>      <dbl>  <dbl>   <dbl>
#> 1     3          3          1  0.439       1
```

## Authors

- **Cristina de la Rosa-Gay** (Author, Maintainer)
- **Daniel Fernández** (Contributor)

## Citation

If you use `oralR` in your research, please cite it as follows:

> de-la-Rosa-Gay, C. & Fernández, D. (2026). oralR: Tools for Dental
> Data Analysis in R. R package version 0.1.0.
> <https://github.com/delarosagay/oralR>

You can also check the citation format directly in R using:

``` r
citation("oralR")
```

## Documentation

The introduction to the package can be found in
[oralR-introduction.pdf](oralR-introduction.pdf).

*Please download the file to use the interactive table of contents.*
