suppressPackageStartupMessages(library(tidyverse))
dir.create("results", showWarnings = FALSE)
d <- map_dfr(c("train", "dev"), \(s) read_csv(paste0("data/raw/", s, ".csv"),
  col_types = cols(.default = col_character())) |> mutate(source_split = s))
stopifnot(nrow(d) == 200, !anyDuplicated(d$id),
          all(!is.na(d$tst_2024)), all(!is.na(d$tst_2025)))
norm <- \(x) str_squish(str_to_lower(x))
audit <- tibble(n = nrow(d), unique_ids = n_distinct(d$id),
  exact_repeats = sum(d$tst_2024 == d$tst_2025),
  normalized_repeats = sum(norm(d$tst_2024) == norm(d$tst_2025)),
  duplicated_baseline = sum(duplicated(norm(d$tst_2024))),
  duplicated_followup = sum(duplicated(norm(d$tst_2025))))
write_csv(audit, "results/data_audit.csv")
d |> select(id, ends_with("_2024"), -tst_2024) |>
  pivot_longer(-id) |> group_by(name) |>
  summarise(n = n(), missing = sum(is.na(value)), distinct = n_distinct(value, na.rm=TRUE)) |>
  write_csv("results/demographic_completeness.csv")
d |> select(id, age_2024, sex_2024, ethnicity_simplified_2024) |>
  mutate(age_2024 = as.numeric(age_2024)) |>
  summarise(n=n(), age_mean=mean(age_2024), age_sd=sd(age_2024),
    age_min=min(age_2024), age_max=max(age_2024), female=sum(sex_2024=="Female"),
    male=sum(sex_2024=="Male")) |> write_csv("results/sample_summary.csv")
d |> count(ethnicity_simplified_2024) |> write_csv("results/ethnicity.csv")
files <- c("data/raw/train.csv", "data/raw/dev.csv", "data/raw/DATA_LICENSE.md",
           "sources/future-selves-data-statement.md", "sources/future-selves-README.md")
manifest <- tibble(file=files, sha256=map_chr(files, \(f) digest::digest(file=f, algo="sha256")),
       source_commit="9b6a766712583fec8d3182957260b1123fbfa146",
       retrieved="2026-09-25")
if(file.exists("sources/download_manifest.csv")) {
  previous <- read_csv("sources/download_manifest.csv",show_col_types=FALSE)
  stopifnot(identical(manifest$sha256,previous$sha256),identical(manifest$file,previous$file))
} else write_csv(manifest,"sources/download_manifest.csv")
print(audit)
