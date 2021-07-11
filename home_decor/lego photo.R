
library(jpeg)
library(tidyverse)
library(dplyr)


#photo <- jpeg::readJPEG("~/xmen.jpeg")
#writePNG(photo, "xmen.png")



mosaic <- png::readPNG("~/xmen.png") %>% 
  image_to_mosaic(use_bricks = c("4x6", "2x4", "1x2", "1x1"))

mosaic %>% build_mosaic()



mosaic <- png::readPNG("~/xmen.png") %>% 
  image_to_mosaic(contrast = 1.1,
                  use_bricks = c("4x6", "2x4", "1x2", "1x1")) %>% bricks_from_mosaic(highest_el = "dark")

mosaic %>% build_bricks()



ironman <- png::readPNG("~/ironman.png") %>% 
  image_to_mosaic(brightness = 1.1,
                  contrast = 1.1,
    use_bricks = c("4x6", "2x4", "1x2", "1x1")) %>% bricks_from_mosaic(highest_el = "dark")

ironman %>% build_bricks()
