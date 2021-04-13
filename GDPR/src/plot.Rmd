library(ggthemes)
library(bbplot)
library(delabj)
library(ggplot2)
library(tidyverse)
library(patchwork)
table2 <- suppressWarnings(read_csv("GDPR.csv", na = "NULL"))

table2$controller[table2$controller == "Google Inc."] <- "Google (France)"
table2$controller[table2$controller == "Google"] <- "Google (Sweden)"

barc <- table2 %>% 
  filter(price > 3000000) %>%
  
  ggplot(aes(x = price/1000000, y = reorder(controller, price))) +
  #theme_economist() +
  #geom_vline(xintercept = c(0, 1e+07, 2e+07, 3e+07, 4e+07, 5e+0), linetype = 1, color = c("black", "grey70", "grey70", "grey70", "grey70", "grey70"), size = 0.5) +
  geom_bar(stat = "identity", group = 1, fill = "red3") + #red3 #C10534  #721121
  scale_x_continuous(position = "top",
                     limits = c(0,5e+01), expand = c(0, 0)) +
  theme_minimal() +
  
  #theme_delabj() +
  
  labs(x = "", y = "",
       title = "You are fined",
       subtitle = "Top 7 compaines that penalised by GDPR ('000,000)",
       caption = "Source: Privacy Affairs\n www.fishwongy.com") +
   theme(
        text = element_text(size = 9.5, family="ITC Officina Sans LT Book"),
        #panel.grid.major = element_line(color = "white", size = 1), 
        #panel.grid.minor = element_blank(),
        panel.grid.major.y = element_blank(),
        #panel.background = element_blank(),
        axis.line.x.top = element_blank(),
        axis.text.x = element_text(size=10),
        axis.text.y = element_text(size=10),
        #axis.ticks = element_blank(),
        plot.title.position = "plot",
        plot.title = element_text(vjust = 2, size = 18, 
                                  family="ITC Officina Sans LT Bold", color = "#C10534"),
        plot.subtitle = element_text(hjust = 0, vjust = 1.5, size = 12, family="ITC Officina Sans LT Bold"),
        plot.caption = element_text(hjust = -0.2, size = 11)) 

# create data frame of maps::world data
worlddata <- map_data('world') %>% filter(region != "Antarctica") %>% fortify

# modify country names to match food_consumption
worlddata <- worlddata %>% mutate(region = str_replace(region, "UK", "United Kingdom"))


#EU map

# Some EU Contries
some.eu.countries <- c("Austria","Belgium","Bulgaria","Croatia","Cyprus",
                   "Denmark","Estonia","Finland","France",
                   "Germany","Greece","Hungary","Ireland","Italy","Latvia",
                   "Lithuania","Luxembourg","Malta","Netherlands","Poland",
                   "Portugal","Romania","Slovakia","Slovenia","Spain",
                   "Sweden","UK", "Switzerland", "Czech Republic", "Norway")
# Retrievethe map data
eu_maps <- map_data("world", region = some.eu.countries)
eu_maps <- eu_maps %>% filter(lat < 72)

eu_maps$region[eu_maps$region == "UK"] <- "United Kingdom"
#eu_maps$region[eu_maps$region == "Czech Republic"] <- "Czechia"

# Compute the centroid as the mean longitude and lattitude
# Used as label coordinate for country's names
#region.lab.data <- eu_maps %>%
  #group_by(region) %>%
  #summarise(long = mean(long), lat = mean(lat))

region.lab.data <- aggregate(eu_maps$long, list(eu_maps$region), mean)
colnames(region.lab.data) <- c("region", "long")
region.lab.data2 <- aggregate(eu_maps$lat, list(eu_maps$region), mean)
colnames(region.lab.data2) <- c("region", "lat")
region.lab.data <- cbind(region.lab.data, region.lab.data2[2])


#Adjust label position
region.lab.data$long <- round(region.lab.data$long, 6)
region.lab.data$lat <- round(region.lab.data$lat, 5)

#Sweden
region.lab.data$long[region.lab.data$long == "17.576305"] <- 15
region.lab.data$lat[region.lab.data$lat == "61.89591"] <- 60.89591

#Finland
region.lab.data$long[region.lab.data$long == "24.430224"] <- 25.430224
region.lab.data$lat[region.lab.data$lat == "63.95119"] <- 62.95119

#Romania
region.lab.data$lat[region.lab.data$lat == "45.84465"] <- 44.84465

#Germany
region.lab.data$long[region.lab.data$long == "10.401156"] <- 11
region.lab.data$lat[region.lab.data$lat == "51.20461"] <- 52.20461

#Norway
region.lab.data$long <- round(region.lab.data$long, 5)
region.lab.data$long[region.lab.data$long == "15.40526"] <- 9.4
region.lab.data$lat[region.lab.data$lat == "66.19758"] <- 62

#Italy
region.lab.data$long[region.lab.data$long == "11.75285"] <- 12.75285

gdpr <- aggregate(table2$price, list(table2$name), sum)
colnames(gdpr) <- c("region", "price")


gdpr <- 
  eu_maps %>%
  full_join(gdpr, by = "region")


mapc <- ggplot(gdpr) + 
 geom_map(aes(map_id = region, fill = price/1000000), map = eu_maps, #fill = "#D6DBE2",
    color = "grey50", size = 0.25) +
  geom_text(aes(x = long, y = lat, label = region), data = region.lab.data, 
            family="ITC Officina Sans LT Bold", size = 3, hjust = 0.5)+
  
  #scale_fill_viridis_b(option = "magma", direction = -1, name = "Fines ('000,000)", 
   #                  guide = guide_colorbar(direction = "horizontal", 
    #                                        barheight = unit(2, units = "mm"),
       #                                     barwidth = unit(50, units = "mm"),
     #                                       draw.ulim = F, title.position = 'top', 
      #                                      title.hjust = 0.5, label.hjust = 0.5)) +
  scale_fill_distiller(palette = "OrRd", direction = 1, name = "Fines ('000,000)",
                        guide = guide_colorbar(direction = "horizontal", 
                                            barheight = unit(2, units = "mm"),
                                            barwidth = unit(50, units = "mm"),
                                            draw.ulim = F, title.position = 'top', 
                                            title.hjust = 0.5, label.hjust = 0.5)) +

    theme_void()+
  labs(fill = " ",
       title = "<span style='color:#C10534'>GDPR Fines</span> in different European countries",
       subtitle = "",
       caption = "") +
  theme(text = element_text(size = 6.5, family = "ITC Officina Sans LT Book"),
        legend.title = element_text(size=10), 
        legend.text = element_text(size = 8),
        legend.position = "top",
        axis.title = element_blank(), 
        axis.ticks = element_blank(), 
        axis.line = element_blank(), 
        axis.text = element_blank(), 
        panel.grid = element_blank(), 
        panel.border = element_blank(),
        plot.title = element_markdown(lineheight = 1.1, hjust = 0.5, size = 20, family = "ITC Officina Sans LT Bold", margin = margin(10, 0, 10, 0)),
        plot.caption = element_text(hjust = 0, family="ITC Officina Sans LT Book"))



mapc / barc +
  ggsave("gdpr_patch2.png", dpi = 320, width = 10.8, height = 12)






library(rvest)
url <- "https://www.enforcementtracker.com/"
gdpr_html <- read_html(url)
gdpr2 <- html_table(gdpr_html, fill = TRUE)
gdpr_tab <- gdpr2[[1]]

CapStr <- function(y) {
  c <- strsplit(y, " ")[[1]]
  paste(toupper(substring(c, 1,1)), substring(c, 2),
      sep="", collapse=" ")
}

capitalize_str <- function(charcter_string){
  sapply(charcter_string, CapStr)
}

gdpr_tab$Country <- tolower(gdpr_tab$Country)
gdpr_tab$Country <- capitalize_str(gdpr_tab$Country)

colnames(gdpr_tab)[4] <- "price"
colnames(gdpr_tab)[5] <- "controller"
gdpr_tab$price <- as.numeric(gsub(",", "", gdpr_tab$price))
gdpr3 <- gdpr_tab %>% select(1,4)


barc2 <- gdpr_tab %>% 
  filter(price > 3000000) %>%
  mutate(controller = recode(controller, `Marriott International, Inc` = "Marriott Int.",
                        `Google Inc.` = "Google (France)", 
                        `TIM (telecommunications operator)` = "TIM - Telecom Provider",
                        `Telecoms provider (1&1 Telecom GmbH)` = "1&1 Telecom GmbH", 
                        `Google LLC` = "Google (Sweden)")) %>%
  
  ggplot(aes(x = price/1000000, y = reorder(controller, price))) +
  #theme_economist() +
  #geom_vline(xintercept = c(0, 1e+07, 2e+07, 3e+07, 4e+07, 5e+0), linetype = 1, color = c("black", "grey70", "grey70", "grey70", "grey70", "grey70"), size = 0.5) +
  geom_bar(stat = "identity", group = 1, fill = "red3") + #red3 #C10534  #721121
  scale_x_continuous(position = "top",
                     limits = c(0, 2.2e+02), expand = c(0, 0)) +
  #theme_minimal() +
  
  theme_delabj() +
  
  labs(x = "", y = "",
       title = "You are fined",
       subtitle = "Top 9 compaines that penalised by GDPR ('000,000)",
       caption = "Source: www.enforcementtracker.com/\n     www.fishwongy.com") +
   theme(
        text = element_text(size = 9.5, family="ITC Officina Sans LT Book"),
        #panel.grid.major = element_line(color = "white", size = 1), 
        #panel.grid.minor = element_blank(),
        panel.grid.major.y = element_blank(),
        #panel.background = element_blank(),
        axis.line.x.top = element_blank(),
        axis.text.x = element_text(size=10),
        axis.text.y = element_text(size=10),
        #axis.ticks = element_blank(),
        plot.title.position = "plot",
        plot.title = element_text(vjust = 2, size = 18, 
                                  family="ITC Officina Sans LT Bold", color = "#C10534"),
        plot.subtitle = element_text(hjust = 0, vjust = 1.5, size = 12, family="ITC Officina Sans LT Bold"),
        plot.caption = element_text(hjust = -0.24, size = 11)) 


gdpr <- aggregate(table2$price, list(table2$name), sum)
colnames(gdpr) <- c("region", "price")
gdpr$price[gdpr$price == "640000"] <- 315310200 # From agg gdpr_tab to find out new UK fines

gdpr <- 
  eu_maps %>%
  full_join(gdpr, by = "region")


mapc2 <- 
  ggplot(gdpr) + 
 geom_map(aes(map_id = region, fill = price/1000000), map = eu_maps, #fill = "#D6DBE2",
    color = "grey50", size = 0.25) +
  geom_text(aes(x = long, y = lat, label = region), data = region.lab.data, 
            family="ITC Officina Sans LT Bold", size = 3, hjust = 0.5)+
  
  #scale_fill_viridis_b(option = "magma", direction = -1, name = "Fines ('000,000)", 
   #                  guide = guide_colorbar(direction = "horizontal", 
    #                                        barheight = unit(2, units = "mm"),
       #                                     barwidth = unit(50, units = "mm"),
     #                                       draw.ulim = F, title.position = 'top', 
      #                                      title.hjust = 0.5, label.hjust = 0.5)) +
  scale_fill_distiller(palette = "OrRd", direction = 1, name = "Fines ('000,000)",
                        guide = guide_colorbar(direction = "horizontal", 
                                            barheight = unit(2, units = "mm"),
                                            barwidth = unit(50, units = "mm"),
                                            draw.ulim = F, title.position = 'top', 
                                            title.hjust = 0.5, label.hjust = 0.5)) +

  #theme_void()+
  theme_delabj() +
  labs(fill = " ",
       title = "<span style='color:#C10534'>GDPR Fines</span> in different European countries",
       subtitle = "",
       caption = "") +
  theme(text = element_text(size = 6.5, family="ITC Officina Sans LT Book"),
        legend.title = element_text(size=10), 
        legend.text = element_text(size = 8),
        legend.position = "top",
        axis.title = element_blank(), 
        axis.ticks = element_blank(), 
        axis.line = element_blank(), 
        axis.text = element_blank(), 
        panel.grid = element_blank(), 
        panel.grid.major = element_blank(),
        panel.border = element_blank(),
        plot.title = element_markdown(lineheight = 1.1, hjust = 0.5, size = 20, family = "ITC Officina Sans LT Bold", margin = margin(10, 0, 10, 0)),
        plot.caption = element_text(hjust = 0, family="ITC Officina Sans LT Book"))



mapc2 / barc2 +
  ggsave("gdpr_patch2.png", dpi = 320, width = 10.8, height = 12)



colnames(gdpr_tab2)[6] <- "article_violated"

#collapse the column of all the articles violated into one string separated by "|" (which is what seperates multipla articles in the same row in the data)
articles <- paste(gdpr_tab2$article_violated, collapse = ",")

#make a dataframe where each element of the object returned by splitting the above string (articles) by the "|" character.
articles_df <- data.frame(articles = as.list(strsplit(articles, "\\,")[[1]]))

# create clean dataframe with one column that contains every article instance
articles_df <- articles_df %>% 
  mutate(n = c(1:nrow(.))) %>%  
  pivot_longer(-n) %>% 
  select(value) %>% 
  mutate(value = trimws(value, which = "both"))

#count the number of times each article occurs and use this to create a dataframe with a column for each article and n for number of times they appear
articles_df <- articles_df %>% 
  group_by(value) %>% 
  count() %>% 
  arrange(-n) %>%  #arrange descending
  head(n = 10)     #pick top 10



artc <- articles_df %>% 
  
  ggplot(aes(x = n, y = reorder(value, n))) +
  geom_bar(stat = "identity", group = 1, fill = "red3") + #red3 #C10534  #721121
  scale_x_continuous(position = "top",
                     #limits = c(0, 2.2e+02), 
                     expand = c(0, 0)) +
  #theme_minimal() +
  
  theme_delabj() +
  
  labs(x = "", y = "",
       title = "THE Articles",
       subtitle = "Top 10 GDPR violated articles",
       caption = "Source: Privacy Affairs; www.enforcementtracker.com/\n            www.fishwongy.com") +
   theme(
        text = element_text(size = 9.5, family="ITC Officina Sans LT Book"),
        #panel.grid.major = element_line(color = "white", size = 1), 
        #panel.grid.minor = element_blank(),
        panel.grid.major.y = element_blank(),
        #panel.background = element_blank(),
        axis.line.x.top = element_blank(),
        axis.text.x = element_text(size=10),
        axis.text.y = element_text(size=10),
        #axis.ticks = element_blank(),
        plot.title.position = "plot",
        plot.title = element_text(vjust = 2, size = 18, 
                                  family="ITC Officina Sans LT Bold", color = "#C10534"),
        plot.subtitle = element_text(hjust = 0, vjust = 1.5, size = 12, family="ITC Officina Sans LT Bold"),
        plot.caption = element_text(hjust = -0.35, size = 11)) 



gdpr_tab2 <- na.omit(gdpr_tab)
auth <- aggregate(gdpr_tab2$price, list(gdpr_tab2$Authority), sum)
colnames(auth) <- c("auth", "price")



authc <- auth %>% 
  filter(price > 1000000) %>%
  mutate(auth = recode(auth, `Information Commissioner (ICO)` = "ICO",
                        `The Federal Commissioner for Data Protection and Freedom of Information (BfDI)` = "BfDI",
                       `Dutch Supervisory Authority for Data Protection (AP)` = "Autoriteit Persoonsgegevens",
                        `Data Protection Commision of Bulgaria (KZLD)` = "KZLD",
                       `French Data Protection Authority (CNIL)` = "CNIL",
                       `Austrian Data Protection Authority (dsb)` = "Datenschutzbehörde",
                        `Italian Data Protection Authority (Garante)` = "Garante",
                      `Spanish Data Protection Authority (aepd)` = "AEPD",
                        `Data Protection Authority of Berlin` = "DPA Berlin",
                      `Data Protection Authority of Sweden` = "DPA Sweden")) %>%
  
  ggplot(aes(x = price/100000, y = reorder(auth, price))) +
  #theme_economist() +
  #geom_vline(xintercept = c(0, 1e+07, 2e+07, 3e+07, 4e+07, 5e+0), linetype = 1, color = c("black", "grey70", "grey70", "grey70", "grey70", "grey70"), size = 0.5) +
  geom_bar(stat = "identity", group = 1, fill = "red3") + #red3 #C10534  #721121
  scale_x_continuous(position = "top",
                     limits = c(0, 3.3e+03), expand = c(0, 0)) +
  #theme_minimal() +
  
  theme_delabj() +
  
  labs(x = "", y = "",
       title = "THE Authorities",
       subtitle = "Top 10 authorities on GDPR enforcement('000,000)",
       caption = "") +
   theme(
        text = element_text(size = 9.5, family="ITC Officina Sans LT Book"),
        #panel.grid.major = element_line(color = "white", size = 1), 
        #panel.grid.minor = element_blank(),
        panel.grid.major.y = element_blank(),
        #panel.background = element_blank(),
        axis.line.x.top = element_blank(),
        axis.text.x = element_text(size=10),
        axis.text.y = element_text(size=10),
        #axis.ticks = element_blank(),
        plot.title.position = "plot",
        plot.title = element_text(vjust = 2, size = 18, 
                                  family="ITC Officina Sans LT Bold", color = "#C10534"),
        plot.subtitle = element_text(hjust = 0, vjust = 1.5, size = 12, family="ITC Officina Sans LT Bold"),
        plot.caption = element_text(hjust = -0.2, size = 11)) 


authc / artc +
  ggsave("gdpr_patch3.png", dpi = 320, width = 10.8, height = 12)


boxc <- gdpr_tab2 %>% filter(Type != "Unknown") %>%
              filter(Type != "Insufficient fulfilment of data breach obligations") %>%
              filter(Type != "Insufficient cooperation with supervisory authority") %>%
  
              
ggplot(aes(x = Type, y = price)) +
geom_boxplot(varwidth = F, fill = "#83B692") +
  theme_delabj() +
  scale_y_log10(position = "right",
                limits = c(1e+02, 1e+08),
                breaks = c(1e+02, 1e+05, 1e+08), labels = c("100", "10,000", "100,000,000")) +
  theme(text = element_text(size = 25, family="ITC Officina Sans LT Book"),
        axis.text.x = element_text(size = 35, vjust=0.6),
        axis.text.y = element_text(size = 40, vjust=0.6),
        plot.title = element_text(vjust = -2, size = 52, 
                              family="ITC Officina Sans LT Bold", color = "#C10534"),
         plot.subtitle = element_text(hjust = 0, vjust = -2.5, size = 42, family="ITC Officina Sans LT Book"),
        plot.caption = element_text(hjust = -1.05, size = 35)) +
  labs(x = "", y = "",
       title = "Fines' Reasons",
       subtitle = "Amount paid (€) due to different reasons",
       caption = "Source: Privacy Affairs; www.enforcementtracker.com/\n           www.fishwongy.com") +
  coord_flip()
