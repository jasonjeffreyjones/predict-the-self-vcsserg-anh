source("analysis/helpers.R")
d <- read_pairs()
write_csv(d |> select(id,source_split,fold), "results/folds.csv")
a <- tokens(d$tst_2024); b <- tokens(d$tst_2025)
aa <- tokens(d$tst_2024,FALSE); bb <- tokens(d$tst_2025,FALSE)
own <- map2_dfr(a,b,\(x,y) as_tibble_row(set_score(x,y)))
all_scores <- outer(seq_len(nrow(d)),seq_len(nrow(d)),
  Vectorize(\(i,j) set_score(a[[i]],b[[j]])[["dice"]]))
other <- (rowSums(all_scores)-diag(all_scores))/(nrow(d)-1)
rank <- map_dbl(seq_len(nrow(d)), \(i) 1+sum(all_scores[i,]>all_scores[i,i])+
                  (sum(all_scores[i,]==all_scores[i,i])-1)/2)
top_credit <- map_dbl(seq_len(nrow(d)), \(i)
  if(all_scores[i,i]==max(all_scores[i,])) 1/sum(all_scores[i,]==max(all_scores[i,])) else 0)
individual <- bind_cols(d |> select(id,source_split,fold), own) |>
  mutate(other_dice=other, paired_advantage=dice-other, rank=rank, top1_credit=top_credit,
    words_baseline=lengths(aa), words_followup=lengths(bb),
    content_baseline=lengths(map(a,unique)), content_followup=lengths(map(b,unique)),
    all_word_dice=map2_dbl(aa,bb,\(x,y) set_score(x,y)[["dice"]]))
write_csv(individual,"results/lexical_individual.csv")
summary <- individual |> select(dice,jaccard,precision,recall,other_dice,paired_advantage,
  top1_credit,all_word_dice) |> pivot_longer(everything()) |>
  group_by(name) |> group_modify(\(x,g) boot_mean(x$value))
write_csv(summary,"results/lexical_summary.csv")
null <- replicate(9999,mean(all_scores[cbind(seq_len(nrow(d)),sample(nrow(d)))]))
write_csv(tibble(observed=mean(diag(all_scores)),null_mean=mean(null),
  permutations=length(null),p=(1+sum(null>=mean(diag(all_scores))))/(1+length(null))),
  "results/permutation.csv")

# Entire-text forecasts: all donor texts and IDF weights come from training people.
pred_scores <- map_dfr(1:5,function(f) {
  tr <- which(d$fold!=f); te <- which(d$fold==f)
  dfs <- df_counts(a[tr]); v <- names(dfs)
  idf <- log((length(tr)+1)/(as.numeric(dfs)+1))+1
  xtr <- sweep(incidence(a[tr],v),2,idf,"*")
  xte <- sweep(incidence(a[te],v),2,idf,"*")
  nn <- tr[max.col(cosine(xte,xtr),ties.method="first")]
  train_sim <- outer(tr,tr,Vectorize(\(i,j) set_score(b[[i]],b[[j]])[["dice"]]))
  diag(train_sim) <- 0
  medoid <- tr[which.max(rowMeans(train_sim))]
  map_dfr(c("repeat","nearest_neighbor","generic_medoid"),function(method) {
    donors <- switch(method,"repeat"=te,nearest_neighbor=nn,generic_medoid=rep(medoid,length(te)))
    pt <- if(method=="repeat") a[te] else b[donors]
    pall <- if(method=="repeat") aa[te] else bb[donors]
    score <- map2_dfr(pt,b[te],\(x,y) as_tibble_row(set_score(x,y)))
    # TF-IDF outcome vocabulary is fixed from training baselines; OOV is separately reported.
    pmat <- sweep(incidence(pt,v),2,idf,"*")
    ymat <- sweep(incidence(b[te],v),2,idf,"*")
    bind_cols(tibble(id=d$id[te],fold=f,method=method,donor_id=d$id[donors]),score) |>
      mutate(all_word_dice=map2_dbl(pall,bb[te],\(x,y) set_score(x,y)[["dice"]]),
             tfidf_cosine=diag(cosine(pmat,ymat)),
             word_count_error=abs(lengths(pall)-lengths(bb[te])))
  })
})
write_csv(pred_scores,"results/text_forecasts.csv")
text_summary <- pred_scores |> select(method,dice,jaccard,all_word_dice,tfidf_cosine,word_count_error) |>
  pivot_longer(-method) |> group_by(method,name) |>
  group_modify(\(x,g) boot_mean(x$value)) |> ungroup()
# Identical repeat scores use the same bootstrap intervals as the descriptive
# analysis, avoiding Monte Carlo rounding differences across tables.
for(metric in c("dice","jaccard","all_word_dice")) {
  ix <- which(text_summary$method=="repeat" & text_summary$name==metric)
  ref <- summary |> filter(.data$name==metric) |> ungroup()
  text_summary[ix,c("estimate","lower","upper","n")] <- ref[,c("estimate","lower","upper","n")]
}
write_csv(text_summary,"results/text_forecast_summary.csv")
pred_scores |> select(id,method,dice) |> pivot_wider(names_from=method,values_from=dice) |>
  summarise(repeat_minus_neighbor=list(boot_mean(.data[["repeat"]]-nearest_neighbor)),
            repeat_minus_generic=list(boot_mean(.data[["repeat"]]-generic_medoid))) |>
  pivot_longer(everything()) |> unnest(value) |> write_csv("results/text_forecast_contrasts.csv")

p <- ggplot(individual,aes(other_dice,dice))+geom_abline(slope=1,intercept=0,color="grey65")+
  geom_point(alpha=.65,color="#246478")+coord_equal(xlim=c(0,1),ylim=c(0,1))+
  labs(x="Mean overlap with other people's later descriptions",y="Overlap with own later description",
       subtitle="Content-word overlap across waves")+theme_minimal(base_size=12)
ggsave("results/continuity.png",p,width=7,height=5,dpi=180,bg="white")
capture.output(sessionInfo(),file="results/sessionInfo.txt")
print(summary)
