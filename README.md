# Forecasting later self-descriptions

This project answers the commissioned question in `RESEARCH-BRIEF.md` using the
200 publicly labeled two-wave JJJ Pro Who am I pairs. It uses and cites the
Future Selves repository solely as a data source. No prediction-task submission
or private-test evaluation is included.

## Read the research

* `manuscript/article.html`: self-contained article with figures and references.
* `manuscript/article.docx`: editable article for journal preparation.
* `manuscript/supplement.html`: additional descriptive and diagnostic tables.
* `manuscript/article.qmd` and `manuscript/supplement.qmd`: executable sources.
* `sources/literature-and-data-search.md`: checked sources, additional-data
  candidates, and access limitations.

The article is anonymized. Authorship and journal-specific administrative
declarations remain for the submitting researchers; no authorship, ethics
approval, or funding award has been invented.

## Reproduce

Run from this repository's root, using R 4.3.3 and the installed package versions
recorded in `results/sessionInfo.txt` and `results/installed_R_packages.csv`:

```sh
Rscript analysis/run_all.R
quarto render manuscript/article.qmd --to html --execute-dir .
quarto render manuscript/article.qmd --to docx --execute-dir .
quarto render manuscript/supplement.qmd --to html --execute-dir .
Rscript analysis/07_verify_documents.R
```

The analyses require tidyverse and digest. Quarto 1.10.18 and rmarkdown/knitr
render the documents. No Python, pandas, paid API, GPU, model downloads, or
network access is needed to reproduce the saved analyses. A first Quarto run
may need write access to its user cache. Typical execution takes a few minutes.
The analysis writes only derived files in `results/`; it never modifies raw
data. Numerical differences across R/BLAS versions may affect rounding.

Original files are included under their source license. For fresh downloads,
use the paths `data/train.csv` and `data/dev.csv` at:

https://raw.githubusercontent.com/jasonjeffreyjones/predict-future-selves/9b6a766712583fec8d3182957260b1123fbfa146/

The manifest `sources/download_manifest.csv` fixes SHA-256 hashes. Verification
also checks the two CSVs against their Git blob hashes. An altered original
causes analysis to stop. Downloaded data statements and licenses are preserved.

## Analysis map

| Script | Purpose |
|---|---|
| `01_audit.R` | Sample, duplication, missingness, and raw-file integrity |
| `02_lexical.R` | Continuity, permutation null, whole-response forecasts, figure |
| `03_forecast_words.R` | Nested cross-validation of word probabilities |
| `04_sensitivity.R` | Alternative representations, matched comparisons, diagnostics |
| `05_verify.R` | Independent recalculation and leakage/integrity checks |
| `06_partition_checks.R` | Alternative folds, vocabulary thresholds, original split |

`analysis/PROTOCOL.md` distinguishes early decisions from exploratory follow-up
checks. Seeded participant folds are saved in `results/folds.csv`.

## Supporting outputs

`word_predictions.csv.gz` contains each out-of-fold probability, observed
presence, baseline presence, word, fold, model, and public ID. This is a research
prediction archive, not a benchmark submission. `word_scores_individual.csv`
contains one row per participant and model. `text_forecasts.csv` preserves
donor IDs and scores for the whole-response baselines. The other CSVs contain
aggregate results, tuning losses, vocabulary coverage, calibration, and
robustness checks. The article's principal numbers are read directly from
these files during rendering. `results/verification.txt` records executed
checks; it is not a substitute for reading the limitations in the article.

Demographic fields are platform metadata. The later-wave demographic values are
never predictors. Timing summaries describe the full publisher cohort and
cannot be reconstructed for this subset. Word presence and absence are not
equivalent to possession or loss of an identity. The data search did not obtain
a second accessible linked-text dataset; the source log explains each decision.

## Attribution and reuse

Data: Jason Jeffrey Jones, *Predict Future Selves*, commit
`9b6a766712583fec8d3182957260b1123fbfa146` (2026), specifically the public JJJ Pro
Who am I `train.csv` and `dev.csv`. See `data/raw/DATA_LICENSE.md` for the
CC BY-NC-SA 4.0 terms. Derived data remain subject to the source license.
Repository documentation from that source is preserved for provenance under
its stated MIT terms. Original commissioned bibliographies and the brief are
unchanged. Sensitive free text is not reproduced as participant quotations in
the article.
