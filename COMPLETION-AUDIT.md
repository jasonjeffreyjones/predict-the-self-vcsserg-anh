# Research-product audit — 25 September 2026

This audit uses the original brief and subsequent user directions, not merely
the checks implemented by the analysis scripts.

| Requirement | Inspected evidence and disposition |
|---|---|
| Answer the predictability question empirically | Executed within-person comparisons, whole-response forecasts, and held-out word-probability forecasts on 200 paired descriptions. Article distinguishes observed lexical predictability from latent selfhood and does not claim an upper limit. Complete within the available evidence. |
| Use JJJ Pro Who am I | Exact GitHub train/dev bytes match published Git blob hashes and the saved SHA-256 manifest. Source documentation links these pairs to the specified survey. Private administrative linkage is explicitly publisher-reported. |
| Use and cite the supplied repository, without participating | Version-pinned data citation is rendered in the article; no private-test predictions, submission file, fork, pull request, or external message was produced. |
| Seek other available longitudinal self-authored descriptions; analyze suitable accessible data | Targeted searches and primary-source checks recorded in `sources/literature-and-data-search.md`. Candidates were nonlongitudinal, aggregated, request-only, or lacked an obtainable linked raw-text release. No second accessible suitable dataset was obtained; the article reports the missing replication explicitly. This is not represented as an exhaustive search. |
| Consider the supplied literature and search more broadly | Both supplied bibliographies consulted; primary sources checked for the cited elicitation, forecasting, Ipseome, and longitudinal-description literature. Seven references render correctly. Source notes distinguish full-source checks from abstract-only evidence. |
| Finished research article | `manuscript/article.html` and `.docx` contain abstract, literature framing, sample and source provenance, explicit estimands and methods, executed results, uncertainty, sensitivity analyses, interpretation, limitations, ethics/data-use information, and references. Numerical passages and tables were inspected after rendering. This is an anonymized manuscript, not a journal submission or claim of author approval. |
| Complete reproducible supporting materials | Original CSVs and licenses; R scripts; fixed folds; all evaluated word probabilities and individual scores; tuning, calibration, coverage, transition, and sensitivity outputs; supplementary HTML; environment versions; and reproduction commands are present. Main pipeline ran successfully; the added partition-check script also ran successfully. No network is required for analysis of the archived inputs. |
| Check important claims | Raw counts/duplicates inspected. Independent recalculation of Dice, transition probabilities, labels, and Brier scores passed. Source/fold integrity and donor exclusion passed. Main advantage persisted in 20 alternate partitions, thresholds 5/10/20, and the original 150/50 split. Bootstrap limitations, selection, restricted vocabulary, and lack of semantic validation are disclosed. |
| Verify finished artifacts | Final HTML has two embedded figure assets, three result tables, and seven references. No empty inline intervals or placeholder results. Word archive contains two figures and populated headline estimates. Supplement contains diagnostic tables. Figures inspected; white backgrounds and clipped subtitle corrected. See `results/document_verification.txt`. |
| Prefer R and tidyverse; do not use pandas | All data auditing, analyses, model fitting, uncertainty, visualization, and verification use R. An initial Python standard-library CSV inspection preceded this preference; pandas was not used. |
| Preserve source materials | Original brief, AGENTS instructions, and both supplied bibliographies have no Git diff. Downloaded CSVs are unmodified and hash-checked. Source documentation and its license are preserved. |

## Boundaries of the completed product

There is no externally validated semantic forecast, new cohort replication,
private-label evaluation, or causal estimate of identity change. These are
limitations of the evidence, not results silently inferred from word scores.
Source timing summaries cannot be reconstructed for the public subset.
Small ridge-model differences should not be treated as definitive substantive
findings. Journal choice, authorship, and submission are outside the commissioned
research product and have not been performed.
