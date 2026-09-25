source("analysis/helpers.R")
d <- read_pairs(); a <- tokens(d$tst_2024); b <- tokens(d$tst_2025)
score_split <- function(tr,te,threshold) {
  df <- df_counts(b[tr]); v <- names(df[df>=threshold])
  y <- incidence(b[tr],v); x <- incidence(a[tr],v)
  yt <- incidence(b[te],v); xt <- incidence(a[te],v)
  pr <- (colSums(y)+.5)/(length(tr)+1)
  p1 <- (colSums(y*x)+5*pr)/(colSums(x)+5)
  p0 <- (colSums(y*(1-x))+5*pr)/(colSums(1-x)+5)
  p <- sweep(xt,2,p1,"*")+sweep(1-xt,2,p0,"*")
  pop <- matrix(rep(pr,each=length(te)),nrow=length(te))
  tibble(id=d$id[te],population=rowMeans((pop-yt)^2),transition=rowMeans((p-yt)^2),
    vocab=length(v),coverage=map_dbl(b[te],\(z) length(intersect(z,v))/length(unique(z))))
}
# Repartition the whole sample; these are robustness runs, not independent samples.
runs <- map_dfr(1:20,function(s) {
  set.seed(20260925+s)
  fold <- sample(rep(1:5,length.out=nrow(d)))
  z <- map_dfr(1:5,\(f) score_split(which(fold!=f),which(fold==f),10))
  z |> summarise(population=mean(population),transition=mean(transition),
    improvement=population-transition) |> mutate(seed=20260925+s)
})
write_csv(runs,"results/partition_sensitivity.csv")
map_dfr(c(5,10,20),function(th) {
  z <- map_dfr(1:5,\(f) score_split(which(d$fold!=f),which(d$fold==f),th))
  z |> summarise(population=mean(population),transition=mean(transition),
    improvement=population-transition,min_vocab=min(vocab),max_vocab=max(vocab),
    coverage=mean(coverage)) |> mutate(threshold=th)
}) |> write_csv("results/vocabulary_sensitivity.csv")
# Preserve the publisher's train/dev split as an additional fixed-split check.
z <- score_split(which(d$source_split=="train"),which(d$source_split=="dev"),10)
write_csv(z,"results/original_split_scores.csv")
set.seed(20260925)
boot_mean(z$population-z$transition) |> mutate(population=mean(z$population),
  transition=mean(z$transition),n_vocabulary=unique(z$vocab)) |>
  write_csv("results/original_split_summary.csv")
print(runs |> summarise(across(c(population,transition,improvement),list(min=min,max=max))))
