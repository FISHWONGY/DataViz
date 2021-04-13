library(tidyverse)
library(rnaturalearth)
library(sf)
library(ggtext)

gdpr_violations <- readr::read_tsv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-04-21/gdpr_violations.tsv') %>% 
  arrange(-price)

# Get countries in dataset
gdpr_countries <- gdpr_violations %>% 
  distinct(name) %>% 
  pull()

# Get sf objects, filter by countries in dataset
countries_sf <- ne_countries(country = c(gdpr_countries, "Czechia"), scale = "large", returnclass = "sf") %>% 
  select(name, geometry) %>% 
  mutate(name = replace(name, name == "Czechia", "Czech Republic"))

# Group fines by country, merge with sf
countries_map <- gdpr_violations %>% 
  group_by(name) %>% 
  mutate(
    price_sum = sum(price),
    price_label = case_when(
      round(price_sum / 1e6) > 0 ~ paste0(round(price_sum / 1e6), "M"),
      round(price_sum / 1e5) > 0 ~ paste0(round(price_sum / 1e6, 1), "M"),
      round(price_sum / 1e3) > 0 ~ paste0(round(price_sum / 1e3), "K"),
      price_sum > 0 ~ paste0(round(price_sum / 1e3, 1), " K"),
      TRUE ~ "0"
    )
    ) %>% 
  left_join(countries_sf) %>% 
  select(name, price_sum, price_label, geometry)
countries_map$price_sum[countries_map$price_sum == "640000"] <- 315310200 

centroids <- read_tsv("https://raw.githubusercontent.com/gkaramanis/tidytuesday/master/2020-week17/data/country-centroids.csv")

# Dataset for red "arrows" (to draw with geom_polygon)
price_arrows <- countries_map %>% 
  select(name, price_sum, price_label) %>% 
  left_join(centroids) %>%
  mutate(
    arrow_x = list(c(longitude - 0.25, longitude, longitude + 0.25, longitude)),
    arrow_y = list(c(latitude - 0.03, latitude, latitude - 0.03, latitude + price_sum/1.5e6))
  ) %>% 
  unnest(c(arrow_x, arrow_y))


countries_map$price_sum[countries_map$price_sum == "640000"] <- 315310200 
price_arrows$price_sum[price_arrows$price_sum == "640000"] <- 315310200 # From agg gdpr_tab to find out new UK fines

price_arrows_uk <- price_arrows %>% filter(name == "United Kingdom")
price_arrows <- price_arrows %>% filter(name != "United Kingdom")
price_arrows_uk$price_label[price_arrows_uk$price_label == "1M"] <- "315M"

price_arrows <- bind_rows(price_arrows, price_arrows_uk)

ggplot() +
  # map
  geom_sf(data = countries_map, aes(geometry = geometry), fill = "#EBE9E1", colour = "grey70", size = 0.25) +
  # country name
  geom_text(data = price_arrows, aes(x = longitude - 0.2, y = latitude - 0.4, label = name), check_overlap = TRUE, family = "IBM Plex Sans", hjust = 0, vjust = 1, size = 3.5) +
  # red price, over 10M
  geom_text(data = subset(price_arrows, price_sum > 10e6), aes(x = longitude - 0.2, y = latitude - 1.1, label = price_label), 
            check_overlap = TRUE, family = "IBM Plex Sans Bold", hjust = 0, vjust = 1, size = 3.5, colour = "#C10534")  +
  # black price, under 10M
  geom_text(data = subset(price_arrows, price_sum < 10e6), aes(x = longitude - 0.2, y = latitude - 1.1, label = price_label), check_overlap = TRUE, family = "IBM Plex Sans Bold", hjust = 0, vjust = 1, size = 3.5, colour = "black")  +
  # red arrows
 geom_polygon(data = price_arrows, aes(x = arrow_x, y = arrow_y, group = name), fill = "#C10534", colour = NA, alpha = 0.8) +
 
  labs(x= "", y = "",
      title = "<span style='color:#C10534'>GDPR Fines (€)</span> in different European countries",
      subtitle = "Prices rounded to nearest million or thousand",
      caption = "Source: Privacy Affairs; www.enforcementtracker.com/\nwww.fishwongy.com") +
  theme_delabj() +
  theme(text = element_text(family="ITC Officina Sans LT Book"),
         axis.title = element_blank(), 
        axis.ticks = element_blank(), 
        axis.line = element_blank(), 
        axis.text = element_blank(), 
        panel.grid = element_blank(), 
        panel.grid.major = element_blank(),
        panel.border = element_blank(),
        plot.title = element_markdown(lineheight = 1.1, hjust = 0.5, size = 18, family = "ITC Officina Sans LT Bold", margin = margin(10, 0, 10, 0)),
        plot.subtitle = element_markdown(lineheight = 1.1, hjust = 0.5, size = 13, family = "ITC Officina Sans LT Book", margin = margin(10, 0, 10, 0)),
        plot.caption = element_text(hjust = 0, size = 13,family="ITC Officina Sans LT Book"),
    plot.margin = margin(20, 20, 20, 20)
  ) +
  coord_sf(xlim = c(-27.5, 37.5), ylim = c(32.5, 82.5), expand = FALSE) +
  ggsave("gdpr_map3.png", dpi = 320, width = 14, height = 12)
