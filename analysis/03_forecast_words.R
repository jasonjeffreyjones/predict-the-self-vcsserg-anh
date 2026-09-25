source("analysis/helpers.R")
d <- read_pairs()
a <- tokens(d$tst_2024); b <- tokens(d$tst_2025)
lambdas <- c(.01,.1,1,10,100)

# Encodings and scaling are fitted on training participants only.
features <- function(tr,te,kind) {
  xx <- list(); zz <- list()
  if(kind %in% c("text","combined")) {
    df <- df_counts(a[tr]); v <- names(df[df>=3])
    xx[["text"]] <- cbind(incidence(a[tr],v),log_words=log1p(lengths(a[tr])))
    zz[["text"]] <- cbind(incidence(a[te],v),log_words=log1p(lengths(a[te])))
  }
  if(kind %in% c("demographics","combined")) {
    cols <- setdiff(names(d)[str_detect(names(d),"_2024$")],"tst_2024")
    x <- z <- list()
    for(col in cols) {
      u <- d[[col]][tr]; w <- d[[col]][te]
      if(col=="age_2024") {
        u <- as.numeric(u); w <- as.numeric(w)
        med <- median(u,na.rm=TRUE); u[is.na(u)] <- med; w[is.na(w)] <- med
        x[[col]] <- matrix(u,ncol=1); z[[col]] <- matrix(w,ncol=1)
      } else {
        u[is.na(u)] <- "<missing>"; w[is.na(w)] <- "<missing>"
        levels <- sort(unique(u))
        x[[col]] <- outer(u,levels,`==`)*1
        z[[col]] <- outer(w,levels,`==`)*1
      }
    }
    xx[["demo"]] <- do.call(cbind,x); zz[["demo"]] <- do.call(cbind,z)
  }
  x <- do.call(cbind,xx); z <- do.call(cbind,zz)
  mu <- colMeans(x); sdv <- apply(x,2,sd); keep <- is.finite(sdv)&sdv>0
  x <- sweep(sweep(x[,keep,drop=FALSE],2,mu[keep],"-"),2,sdv[keep],"/")
  z <- sweep(sweep(z[,keep,drop=FALSE],2,mu[keep],"-"),2,sdv[keep],"/")
  list(x=x,z=z)
}
ridge_path <- function(feat,y,lambda) {
  x <- feat$x; z <- feat$z; n <- nrow(x); mu <- colMeans(y)
  yc <- sweep(y,2,mu,"-")
  e <- eigen(tcrossprod(x),symmetric=TRUE)
  uy <- crossprod(e$vectors,yc); zx <- z %*% t(x) %*% e$vectors
  map(lambda,\(l) {
    p <- sweep(zx %*% sweep(uy,1,pmax(e$values,0)+n*l,"/"),2,mu,"+")
    p[p<0] <- 0; p[p>1] <- 1; p
  })
}
ap <- function(y,p) {
  if(sum(y)==0) return(NA_real_)
  # Threshold-grouped AP: ties are not broken using observed labels.
  z <- tibble(y=y,p=p) |> group_by(p) |> summarise(pos=sum(y),n=n()) |> arrange(desc(p))
  sum(z$pos/sum(y)*cumsum(z$pos)/cumsum(z$n))
}
all_predictions <- list(); tuning <- list(); coverage <- list()
for(f in 1:5) {
  message("Outer fold ",f)
  tr <- which(d$fold!=f); te <- which(d$fold==f)
  df <- df_counts(b[tr]); v <- sort(names(df[df>=10]))
  y <- incidence(b[tr],v); yt <- incidence(b[te],v)
  x <- incidence(a[tr],v); xt <- incidence(a[te],v)
  prev <- (colSums(y)+.5)/(length(tr)+1)
  pop <- matrix(rep(prev,each=length(te)),nrow=length(te))
  p1 <- (colSums(y*x)+5*prev)/(colSums(x)+5)
  p0 <- (colSums(y*(1-x))+5*prev)/(colSums(1-x)+5)
  transition <- sweep(xt,2,p1,"*")+sweep(1-xt,2,p0,"*")
  pp <- list(population=pop,persistence=xt,transition=transition)
  inner <- sample(rep(1:3,length.out=length(tr)))
  for(kind in c("demographics","text","combined")) {
    losses <- map_dfr(1:3,function(k) {
      itr <- tr[inner!=k]; ite <- tr[inner==k]
      idf <- df_counts(b[itr]); iv <- sort(names(idf[idf>=10]))
      iy <- incidence(b[itr],iv); iyv <- incidence(b[ite],iv)
      path <- ridge_path(features(itr,ite,kind),iy,lambdas)
      tibble(lambda=lambdas,loss=map_dbl(path,\(p) mean((p-iyv)^2)))
    }) |> group_by(lambda) |> summarise(loss=mean(loss))
    chosen <- losses$lambda[which.min(losses$loss)]
    tuning[[paste(f,kind)]] <- losses |> mutate(fold=f,model=kind,selected=lambda==chosen)
    pp[[kind]] <- ridge_path(features(tr,te,kind),y,chosen)[[1]]
  }
  all_predictions[[f]] <- imap_dfr(pp,function(p,model) {
    tibble(id=rep(d$id[te],times=length(v)),fold=f,word=rep(v,each=length(te)),
      baseline=as.vector(xt),observed=as.vector(yt),model=model,probability=as.vector(p))
  })
  coverage[[f]] <- tibble(id=d$id[te],fold=f,vocabulary_size=length(v),
    observed_content_words=lengths(map(b[te],unique)),
    covered=map_int(b[te],\(z) length(intersect(z,v))))
}
pred <- bind_rows(all_predictions)
stopifnot(all(pred$probability>=0 & pred$probability<=1),!anyNA(pred$probability))
write_csv(pred,"results/word_predictions.csv.gz")
write_csv(bind_rows(tuning),"results/tuning.csv")
write_csv(bind_rows(coverage),"results/vocabulary_coverage.csv")
ind <- pred |> mutate(sq_error=(probability-observed)^2) |>
  group_by(id,fold,model) |> summarise(brier=mean(sq_error),
    brier_present=mean(sq_error[baseline==1]),brier_absent=mean(sq_error[baseline==0]),
    average_precision=ap(observed,probability),
    ap_absent=ap(observed[baseline==0],probability[baseline==0])) |> ungroup()
write_csv(ind,"results/word_scores_individual.csv")
ind |> pivot_longer(c(brier,brier_present,brier_absent,average_precision,ap_absent)) |>
  group_by(model,name) |> group_modify(\(x,g) boot_mean(x$value[is.finite(x$value)])) |>
  write_csv("results/word_score_summary.csv")
contrasts <- ind |> select(id,model,brier) |> pivot_wider(names_from=model,values_from=brier)
map_dfr(c("persistence","transition","demographics","text","combined"),\(m)
  boot_mean(contrasts$population-contrasts[[m]]) |> mutate(contrast=paste("population minus",m))) |>
  bind_rows(boot_mean(contrasts$text-contrasts$combined) |> mutate(contrast="text minus combined"),
    boot_mean(contrasts$transition-contrasts$combined) |> mutate(contrast="transition minus combined")) |>
  write_csv("results/word_brier_contrasts.csv")
pred |> mutate(bin=cut(probability,seq(0,1,.1),include.lowest=TRUE)) |>
  group_by(model,bin) |> summarise(n=n(),predicted=mean(probability),observed=mean(observed)) |>
  write_csv("results/calibration.csv")
capture.output(sessionInfo(),file="results/sessionInfo.txt")
print(ind |> group_by(model) |> summarise(across(c(brier,average_precision),\(x) mean(x,na.rm=TRUE))))
