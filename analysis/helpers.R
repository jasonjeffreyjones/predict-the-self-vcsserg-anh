suppressPackageStartupMessages(library(tidyverse))
options(dplyr.summarise.inform = FALSE)
set.seed(20260925)
stop_words <- str_split(paste(
  "a an the i me my mine myself we us our ours ourselves you your yours yourself yourselves",
  "he him his himself she her hers herself it its itself they them their theirs themselves",
  "am is are was were be been being have has had having do does did doing",
  "and or but if because as until while of at by for with about against between into through",
  "during before after above below to from up down in out on off over under again further",
  "then once here there when where why how all any both each few more most other some such",
  "only own same so than too very can will just should now s t m re ve ll d would could",
  "this that these those who whom whose which what also really much many lot lots"), "\\s+")[[1]]
tokens <- function(x, content=TRUE) {
  z <- str_extract_all(str_to_lower(x), "[\\p{L}]+")
  map(z, \(v) if(content) v[nchar(v)>1 & !v %in% stop_words] else v)
}
set_score <- function(a,b) {
  a <- unique(a); b <- unique(b); k <- length(intersect(a,b))
  c(dice=if(length(a)+length(b)) 2*k/(length(a)+length(b)) else 1,
    jaccard=if(length(union(a,b))) k/length(union(a,b)) else 1,
    precision=if(length(a)) k/length(a) else 0,
    recall=if(length(b)) k/length(b) else 0)
}
incidence <- function(toks,vocab) {
  z <- matrix(0, length(toks), length(vocab), dimnames=list(NULL,vocab))
  for(i in seq_along(toks)) z[i, vocab %in% toks[[i]]] <- 1
  z
}
df_counts <- \(toks) sort(table(unlist(map(toks,unique))), decreasing=TRUE)
cosine <- function(a,b) {
  a <- a / pmax(sqrt(rowSums(a*a)), 1e-15)
  b <- b / pmax(sqrt(rowSums(b*b)), 1e-15)
  a %*% t(b)
}
boot_mean <- function(x, B=4000) {
  m <- replicate(B,mean(sample(x,length(x),replace=TRUE)))
  tibble(estimate=mean(x), lower=unname(quantile(m,.025)), upper=unname(quantile(m,.975)), n=length(x))
}
read_pairs <- function() {
  map_dfr(c("train","dev"), \(s) read_csv(paste0("data/raw/",s,".csv"),
    col_types=cols(.default=col_character())) |> mutate(source_split=s)) |>
    arrange(id) |> mutate(fold=sample(rep(1:5,length.out=n())))
}
