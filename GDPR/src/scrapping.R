#Scrape the Privacy Affairs website


link<- "https://www.privacyaffairs.com/gdpr-fines/"
page <- read_html(link)
temp <- page %>% html_nodes("script") %>% .[9] %>%
rvest::html_text() 
ends <- str_locate_all(temp, "\\]")
starts <- str_locate_all(temp, "\\[")
table1 <- temp %>% stringi::stri_sub(from = starts[[1]][1,2], to = ends[[1]][1,1]) %>%
str_remove_all("\n") %>%
str_remove_all("\r") %>%
jsonlite::fromJSON()
table2 <- temp %>% stringi::stri_sub(from = starts[[1]][2,2], to = ends[[1]][2,1]) %>%
str_remove_all("\n") %>%
str_remove_all("\r") %>%
jsonlite::fromJSON()


#Adding sources included the ICO as well, the Privacy Affairs is missing the fine for British Airlines & Marriot Inc.
url <- "https://www.enforcementtracker.com/"
gdpr_html <- read_html(url)
gdpr2 <- html_table(gdpr_html, fill = TRUE)
gdpr_tab <- gdpr2[[1]]
