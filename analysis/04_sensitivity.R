source("analysis/helpers.R")
d <- read_pairs()
a <- tokens(d$tst_2024); b <- tokens(d$tst_2025)
lex <- read_csv("results/lexical_individual.csv",show_col_types=FALSE)
# These checks were chosen after the initial scores, and are exploratory.
summary <- bind_rows(
  boot_mean(lex$paired_advantage[lex$dice<.5]) |> mutate(check="Exclude Dice >= 0.5"),
  boot_mean(lex$paired_advantage[pmin(lex$words_baseline,lex$words_followup)>=20]) |>
    mutate(check="Both responses at least 20 words"))

# Alternative representation retaining function words and inflectional fragments.
grams <- function(x) {
  z <- str_squish(str_replace_all(str_to_lower(x),"[^\\p{L} ]"," "))
  map(z,\(s) if(nchar(s)>=3) unique(substring(s,1:(nchar(s)-2),3:nchar(s))) else s)
}
ga <- grams(d$tst_2024); gb <- grams(d$tst_2025)
gown <- map2_dbl(ga,gb,\(x,y) set_score(x,y)[["dice"]])
gother <- map_dbl(seq_len(nrow(d)),\(i) mean(map_dbl(setdiff(seq_len(nrow(d)),i),
  \(j) set_score(ga[[i]],gb[[j]])[["dice"]])))
summary <- bind_rows(summary,boot_mean(gown-gother) |> mutate(check="Character trigram own-minus-other"))

# Compare with similar-age, same-sex participants; if none within 10 years,
# choose nearest-age same-sex participants (up to 10; deterministic ID ordering).
matched <- map_dfr(seq_len(nrow(d)),function(i) {
  candidates <- which(d$sex_2024==d$sex_2024[i] & seq_len(nrow(d))!=i)
  delta <- abs(as.numeric(d$age_2024[candidates])-as.numeric(d$age_2024[i]))
  near <- candidates[delta<=10]
  if(!length(near)) near <- candidates[order(delta)][seq_len(min(10,length(candidates)))]
  m <- mean(map_dbl(near,\(j) set_score(a[[i]],b[[j]])[["dice"]]))
  tibble(id=d$id[i],matched_dice=m,n_matches=length(near),own_dice=lex$dice[match(d$id[i],lex$id)])
})
write_csv(matched,"results/matched_comparison.csv")
summary <- bind_rows(summary,boot_mean(matched$own_dice-matched$matched_dice) |>
                       mutate(check="Same sex and similar age own-minus-other"))
write_csv(summary,"results/sensitivity.csv")

pred <- read_csv("results/word_predictions.csv.gz",show_col_types=FALSE)
# Paired uncertainty for innovation prediction, separate from retention.
ind <- read_csv("results/word_scores_individual.csv",show_col_types=FALSE)
map_dfr(c("brier_present","brier_absent","ap_absent"),function(metric) {
  z <- ind |> select(id,model,all_of(metric)) |> pivot_wider(names_from=model,values_from=all_of(metric))
  map_dfr(c("transition","demographics","text","combined"),function(model) {
    x <- z$population-z[[model]]
    boot_mean(x[is.finite(x)]) |> mutate(metric=metric,contrast=paste("population minus",model))
  })
}) |> write_csv("results/innovation_contrasts.csv")
pred |> filter(model=="transition") |> group_by(fold) |>
  summarise(n=n_distinct(id),words=n_distinct(word),prevalence=mean(observed),
    retention=mean(observed[baseline==1]),appearance=mean(observed[baseline==0])) |>
  write_csv("results/fold_diagnostics.csv")
pred |> filter(model=="transition") |> group_by(word) |>
  summarise(n=n(),baseline_present=sum(baseline),later_present=sum(observed),
    both=sum(baseline*observed),retention=if_else(baseline_present>0,both/baseline_present,NA_real_),
    appearance=(later_present-both)/(n-baseline_present)) |>
  arrange(desc(baseline_present)) |> write_csv("results/word_transitions.csv")
z <- read_csv("results/word_score_summary.csv",show_col_types=FALSE) |> filter(name=="brier") |>
  mutate(model=factor(model,levels=c("transition","combined","text","demographics","population","persistence")))
p <- ggplot(z,aes(estimate,model))+geom_errorbarh(aes(xmin=lower,xmax=upper),height=.18)+
  geom_point(size=2.5,color="#246478")+theme_minimal(base_size=12)+
  labs(x="Mean Brier loss (lower is better)",y=NULL,
    subtitle="Common content words; participant bootstrap 95% intervals")
ggsave("results/forecast_brier.png",p,width=7,height=4,dpi=180,bg="white")
print(summary)
