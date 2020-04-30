library(ggpacman)
library(ggforce)
library(gganimate)


data("pacman", package = "ggpacman")
data("maze_points", package = "ggpacman")
data("maze_walls", package = "ggpacman")
data("blinky", package = "ggpacman")
data("pinky", package = "ggpacman")
data("inky", package = "ggpacman")
data("clyde", package = "ggpacman")
ghosts <- list(blinky, pinky, inky, clyde)
pacman_moves <- ggpacman::compute_pacman_coord(pacman)
bonus_points_eaten <- ggpacman::compute_points_eaten(maze_points, pacman_moves)
map_colours <- c(
  "READY!" = "goldenrod1",
  "wall" = "dodgerblue3", "door" = "dodgerblue3",
  "normal" = "goldenrod1", "big" = "goldenrod1", "eaten" = "black",
  "Pac-Man" = "yellow",
  "eye" = "white", "iris" = "black",
  "Blinky" = "red", "Blinky_weak" = "blue", "Blinky_eaten" = "transparent",
  "Pinky" = "pink", "Pinky_weak" = "blue", "Pinky_eaten" = "transparent",
  "Inky" = "cyan", "Inky_weak" = "blue", "Inky_eaten" = "transparent",
  "Clyde" = "orange", "Clyde_weak" = "blue", "Clyde_eaten" = "transparent"
)

#Build Base
base_grid <- ggplot() +
  theme_void() +
  theme(
    legend.position = "none",
   # text = element_text(family = "SF Alien Encounters"),
    plot.caption = element_textbox_simple(halign = 0.5, colour = "white", family = "SF Alien Encounters"),
    plot.caption.position = "plot",
    plot.background = element_rect(fill = "black", colour = "black"),
    panel.background = element_rect(fill = "black", colour = "black")
  ) +
  labs(caption = "Stay home, play game") +
  scale_size_manual(values = c("wall" = 2.5, "door" = 1, "big" = 2.5, "normal" = 0.5, "eaten" = 3)) +
  scale_fill_manual(breaks = names(map_colours), values = map_colours) +
  scale_colour_manual(breaks = names(map_colours), values = map_colours) +
  coord_fixed(xlim = c(0, 20), ylim = c(0, 26)) +
  geom_segment(
    data = maze_walls,
    mapping = aes(x = x, y = y, xend = xend, yend = yend, size = type, colour = type),
    lineend = "round",
    inherit.aes = FALSE
  ) +
  geom_point(
    data = maze_points,
    mapping = aes(x = x, y = y, size = type, colour = type),
    inherit.aes = FALSE
  ) +
  geom_text(
    data = tibble(x = 10, y = 11, label = "READY!", step = 1:20),
    mapping = aes(x = x, y = y, label = label, colour = label, group = step),
    size = 6
  )
base_grid


#Build points
p_points <- list(
  geom_point(
    data = bonus_points_eaten,
    mapping = aes(x = x, y = y, colour = colour, size = colour, group = step),
    inherit.aes = FALSE
  )
)

#Build pacman
p_pacman <- list(
  geom_arc_bar(
    data = pacman_moves,
    mapping = aes(
      x0 = x, y0 = y,
      r0 = 0, r = 0.5,
      start = start, end = end,
      colour = colour, fill = colour,
      group = step
    ),
    inherit.aes = FALSE
  )
)

#Build ghost
map(.x = ghosts, .f = function(data) {
  ghost_moves <- compute_ghost_status(
    ghost = data,
    pacman_moves = pacman_moves,
    bonus_points_eaten = bonus_points_eaten
  )
  list(
    geom_polygon(
      data = unnest(ghost_moves, "body"),
      mapping = aes(
        x = x, y = y,
        fill = colour, colour = colour,
        group = step
      ),
      inherit.aes = FALSE
    ),
    geom_circle(
      data = unnest(ghost_moves, "eyes"),
      mapping = aes(
        x0 = x0, y0 = y0,
        r = r,
        colour = part, fill = part,
        group = step
      ),
      inherit.aes = FALSE
    )
  )
})


#Put everything together
PacMan <- base_grid + p_points + p_pacman + p_ghosts + transition_manual(step) 
