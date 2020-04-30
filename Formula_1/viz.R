#Load Lib
library(tidyverse)
library(stringr)
library(readr) 
library(countrycode)
library(ggplot2)
library(ggthemes)
library(ggmap)
library(maps)
library(viridis)
library(RColorBrewer)
library(fields)
library(rworldmap)
library(lubridate)
library(reshape2)
library(eeptools)
library(sf)
library(delabj)
library(ggtext)
library(ggbump)

#Data Cleaning
race_result$Team[race_result$Team == "Red Bull Racing Honda"] <- "Red Bull"
race_result$Team[race_result$Team == "Scuderia Toro Rosso Honda"] <- "Toro Rosso"
race_result$Team[race_result$Team == "Racing Point BWT Mercedes"] <- "Racing Point"
race_result$Team[race_result$Team == "Alfa Romeo Racing Ferrari"] <- "Alfa Romeo"

#Bar chart
country_win_result_plot %>%
  ggplot(aes(x = reorder(country, count), y = count, fill = Team)) +
  #geom_hline(yintercept = c(-0.0006, 0.2, 0.4, 0.6), linetype = 1, 
             #color = c("black", "grey70", "grey70", "grey70"), size = 0.5) +
  geom_bar(stat = "identity", position = position_dodge()) +
  #geom_text(aes(label = count), hjust =  1.2, vjust = 0.6, position = position_dodge(0.9), size = 3, 
            #color = "white", family="ITC Officina Sans LT Book") +
  theme_delabj_dark() +
  scale_y_continuous(position = "right") +
  scale_x_discrete(expand=c(0.03, 0)) +
  #scale_fill_manual(name = "", values = c("Red Bull" = "royalblue4","Mercedes" = "#00887d",
   #                             "Ferrari" = "#90353b")) +
  scale_fill_delabj(name = "") +
   labs(y=" ", 
       x = " ",
       title = "<b, style = 'color:#83B692'>Matches won</b> per team in different country",
       subtitle = "Aggregated data from 2009 - 2019",
       caption = " ")  +
  theme(legend.position = c(-0.0005, 1),
        legend.direction = "horizontal",
        legend.key.size = unit(0.1, "cm"),
        legend.text = element_text(size = 15),
        #panel.grid = element_blank(),
        panel.grid.major.x = element_blank(),
        text = element_text(size = 9.5, family="ITC Officina Sans LT Book"),
        axis.text.x = element_text(angle = 90, size = 13),
        axis.text.y = element_text(size = 12),
        plot.title = element_markdown(hjust = 0, vjust = 1, size = 18, 
                                  family="ITC Officina Sans LT Bold"),
        plot.subtitle = element_text(hjust = 0, vjust=2.5, size = 13),
        plot.caption = element_text(size = 9)) 
        



#Bump graph
   ggplot(team_year_win, aes(x = year, y = count, color = Team, group = Team)) + 
 geom_bump(aes(smooth = 15), size = 1.5) +
  theme_delabj_dark() +
  scale_color_viridis_d(name = "") +
  scale_y_continuous(position = "right",
                     breaks = c(4,8,12,16,20)) +
  geom_point(data = team_year_win %>% filter(year %in% c(2009, 2019)),
             #aes(x = Pos ),
             size = 5) +
   geom_text(data = team_year_win %>% filter(year == 2017),
            aes(label = Team),
            color = "gray70",
            nudge_x = .31,
            hjust = 0,
            vjust = -2.4,
            size = 3,
            fontface = 2) +
  #geom_dl(aes(label = Team), method = list(dl.trans(x = x - 1), "last.qp", cex = 0.6, 
                                         # family="ITC Officina Sans LT Bold", vjust = -1)) +
  theme(text = element_text(family="ITC Officina Sans LT Book"),
        legend.position = "none",
       # legend.position = c(0.18, 0.98),
        #legend.direction = "horizontal",
        legend.key.size = unit(0.2, "cm"),
        panel.grid = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.y = element_blank(),
        legend.text = element_text(family = "ITC Officina Sans LT Book"),
        plot.title = element_markdown(hjust = 0, vjust = 1, size = 18, 
                                  family="ITC Officina Sans LT Bold"),
        plot.subtitle = element_text(hjust = 0, vjust=2,size = 12, family="ITC Officina Sans LT Book"),
        plot.caption.position = "plot",
        plot.caption = element_text( size = 11)) +
    labs(y=" ", 
        x = "", 
       title = "Number of <b, style = 'color:#83B692'>matches won</b> yearly per team",
       subtitle = "From 2009 - 2019",
      caption = "") 
        
