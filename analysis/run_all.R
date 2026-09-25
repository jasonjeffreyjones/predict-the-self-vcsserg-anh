Sys.setenv(TZ="UTC")
scripts <- c("01_audit.R","02_lexical.R","03_forecast_words.R","04_sensitivity.R","05_verify.R","06_partition_checks.R")
for(s in scripts) {
  message("Running ",s)
  status <- system2(file.path(R.home("bin"),"Rscript"),file.path("analysis",s))
  if(status!=0) stop("Failed: ",s)
}
p <- installed.packages()
readr::write_csv(tibble::tibble(package=p[,"Package"],version=p[,"Version"]),
                "results/installed_R_packages.csv")
