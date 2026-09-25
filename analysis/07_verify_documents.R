suppressPackageStartupMessages(library(tidyverse))
library(xml2)
html <- read_html("manuscript/article.html")
main <- xml_find_first(html,"//main")
text <- xml_text(main)
stopifnot(!str_detect(text,"\\[, \\]|NaN|TODO|TBD|`r "))
imgs <- xml_find_all(main,".//img")
stopifnot(length(imgs)==2,all(str_starts(xml_attr(imgs,"src"),"data:image")),
          length(xml_find_all(main,".//table"))==3,
          length(xml_find_all(main,".//*[starts-with(@id,'ref-')]"))==7)
lex <- read_csv("results/lexical_summary.csv",show_col_types=FALSE)
ws <- read_csv("results/word_score_summary.csv",show_col_types=FALSE)
stopifnot(all(str_detect(text,fixed(sprintf("%.3f",lex$estimate[lex$name %in% c("dice","other_dice","paired_advantage")])))),
  all(str_detect(text,fixed(sprintf("%.4f",ws$estimate[ws$name=="brier"])))) )
supp <- read_html("manuscript/supplement.html")
stopifnot(length(xml_find_all(supp,"//main//table"))>=10)
entries <- unzip("manuscript/article.docx",list=TRUE)$Name
stopifnot(sum(str_detect(entries,"^word/media/"))==2,"word/document.xml" %in% entries)
tmp <- tempfile("document-check-"); dir.create(tmp)
unzip("manuscript/article.docx",files="word/document.xml",exdir=tmp)
doc <- read_xml(file.path(tmp,"word/document.xml"))
doc_text <- paste(xml_text(xml_find_all(doc,"//*[local-name()='t']")),collapse=" ")
stopifnot(!str_detect(doc_text,"\\[, \\]|NaN|TODO|TBD"),str_detect(doc_text,"0.165"),
          str_detect(doc_text,"0.0837"))
write_lines(c("PASS: article HTML has two embedded figures, three tables, seven references",
 "PASS: principal estimates appear in rendered HTML; no empty inline intervals",
 "PASS: supplementary HTML contains diagnostic tables",
 "PASS: Word document contains two figure assets and populated headline estimates"),
 "results/document_verification.txt")
cat(read_lines("results/document_verification.txt"),sep="\n")
