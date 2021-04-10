library(rvest)
library(tidyr)


lh_info <- "https://www.formula1.com/en/drivers/lewis-hamilton.html"
lh_info <- read_html(lh_info)
lh_info <- html_table(lh_info, fill = TRUE)
lh_info <- lh_info[[1]]
lh_info <- spread(lh_info, X1, X2)
lh_info$Name <- "Lewis Hamilton"
lh_info <- lh_info[, c(11, 1:10)]
lh_info$salary <- 57
lh_info
