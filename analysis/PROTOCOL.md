# Analysis decisions, 25 September 2026

This is an exploratory secondary analysis, not a preregistered study. Decisions
below were recorded after inspecting column names, demographic counts, and the
first three training pairs, but before computing prediction scores.

Use the 200 publicly labeled pairs (train + dev) from commit
9b6a766712583fec8d3182957260b1123fbfa146 of
https://github.com/jasonjeffreyjones/predict-future-selves . Do not participate in
the repository's task or produce submissions. Its 81 unlabeled cases cannot
support outcome evaluation and are excluded. Preserve downloaded originals.

The estimand is predictability of the words in a later elicited self-description
among available returning participants, not predictability of lives or latent
identities. Timing is known only at the full released-cohort level.

Use participant-level five-fold cross-validation, fixed seed 20260925. Learn
vocabularies, prevalence, demographic encodings, and tuning parameters using
only the training participants within each outer fold. Never use follow-up
demographics as inputs. Report paired participant bootstrap confidence intervals
conditional on the fitted folds, explicitly not full retraining uncertainty.

Two complementary analyses:

1. Predict whole text by repeating the earlier text, using a generic training
   follow-up medoid, or retrieving the follow-up of the nearest training baseline
   description. Evaluate unique content-word Dice and Jaccard, alongside an
   all-word sensitivity and TF-IDF cosine. Compare own-person overlap to all
   other-person overlaps and a permutation null; evaluate identification among
   candidate later descriptions separately from prospective text prediction.
2. Forecast presence of common content words using population prevalence,
   smoothed per-word persistence transitions, demographic ridge regression,
   text ridge regression, and combined text + demographic ridge regression.
   Use Brier loss and average precision; distinguish words already present from
   words absent at baseline. Train-fold follow-up document frequency >= 10
   defines the evaluated vocabulary. Rare and unseen target words are outside
   this probabilistic estimand and must be quantified separately.

Use lowercase alphabetic word tokens, remove a fixed English stop list and
single-character tokens. Primary analyses do not conflate words using stemming.
Report sensitivity to function words and exact or near-exact repeats. No
automatic exclusion of suspected AI-generated responses. Describe sample and
missing demographics. Preserve public-source license and document downloads.

Search for other open longitudinal self-authored descriptions; require linked
individual texts at two times and usable access. Aggregate frequency series,
ratings of supplied adjectives, and unlinked cross-sections are not substitutes.

Implementation correction after inspecting the first output: the hand-specified
stop list initially omitted `who whom whose which what`. These grammatical
words were added before final analysis and all outputs regenerated. The project
is exploratory; this correction is not presented as a preregistered choice.
