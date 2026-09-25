source("analysis/helpers.R")
d <- read_pairs(); folds <- read_csv("results/folds.csv",show_col_types=FALSE)
stopifnot(identical(d$id,folds$id),identical(d$fold,as.integer(folds$fold)))
manifest <- read_csv("sources/download_manifest.csv",show_col_types=FALSE)
stopifnot(all(map_chr(manifest$file,\(f) digest::digest(file=f,algo="sha256"))==manifest$sha256))
# Git blob hashes verify the downloaded bytes against GitHub's version listing.
blob <- function(path) {
  n <- file.info(path)$size
  digest::digest(c(charToRaw(paste0("blob ",n)),as.raw(0),readBin(path,"raw",n=n)),
                 algo="sha1",serialize=FALSE)
}
stopifnot(blob("data/raw/train.csv")=="1f3f2ae5fa3cc129c0fad7a61381103161350fdf",
          blob("data/raw/dev.csv")=="96ffc6979897ce955521b2b8424b662819e07508")
lex <- read_csv("results/lexical_individual.csv",show_col_types=FALSE)
# Independently construct set intersections with base R, not set_score().
a <- tokens(d$tst_2024); b <- tokens(d$tst_2025)
reference <- vapply(seq_len(nrow(d)),function(i) {
  x <- unique(a[[i]]); y <- unique(b[[i]])
  2*sum(x %in% y)/(length(x)+length(y))
},numeric(1))
stopifnot(max(abs(reference-lex$dice))<1e-12)
text <- read_csv("results/text_forecasts.csv",show_col_types=FALSE)
stopifnot(nrow(text)==600,all(table(text$id)==3),
  all(text$fold[text$method!="repeat"] != d$fold[match(text$donor_id[text$method!="repeat"],d$id)]))
pred <- read_csv("results/word_predictions.csv.gz",show_col_types=FALSE)
stopifnot(!anyDuplicated(pred[c("id","word","model")]),all(table(pred$model)==table(pred$model)[1]),
  all(pred$observed %in% 0:1),all(pred$baseline %in% 0:1),
  all(is.finite(pred$probability)),all(pred$probability>=0 & pred$probability<=1))
for(f in 1:5) {
  tr <- which(d$fold!=f); te <- which(d$fold==f)
  z <- pred |> filter(fold==f,model=="transition")
  v <- sort(unique(z$word)); xt <- incidence(a[tr],v); y <- incidence(b[tr],v)
  stopifnot(all(colSums(y)>=10))
  pr <- (colSums(y)+.5)/(length(tr)+1)
  for(i in te) {
    zi <- z |> filter(id==d$id[i]) |> arrange(word)
    xi <- v %in% a[[i]]
    ref <- ifelse(xi,(colSums(y*xt)+5*pr)/(colSums(xt)+5),
                        (colSums(y*(1-xt))+5*pr)/(colSums(1-xt)+5))
    stopifnot(max(abs(ref-zi$probability))<1e-12,
              all(zi$observed==as.numeric(v %in% b[[i]])))
  }
}
scores <- read_csv("results/word_scores_individual.csv",show_col_types=FALSE)
ref <- pred |> group_by(id,model) |> summarise(recomputed=mean((observed-probability)^2)) |>
  left_join(scores,by=c("id","model"))
stopifnot(max(abs(ref$recomputed-ref$brier))<1e-12)
write_lines(c("PASS: original-file SHA-256 and Git blob hashes",
 "PASS: fold correspondence and donor exclusion",
 "PASS: independent Dice recomputation for all 200 pairs",
 "PASS: unique predictions, valid probabilities, training-only target vocabulary",
 "PASS: all transition probabilities and observed labels independently recomputed",
 "PASS: every participant-model Brier score recomputed"),"results/verification.txt")
cat(read_lines("results/verification.txt"),sep="\n")
