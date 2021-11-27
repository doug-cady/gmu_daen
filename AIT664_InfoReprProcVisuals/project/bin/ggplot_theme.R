
ggplot_clean_theme <- theme_gray() + theme(
  plot.title = element_text(hjust = 0.5, size = 16),
  plot.subtitle = element_text(hjust = 0.5, size = 14, face = 'italic'),
  # plot.caption=element_text(hjust=-.5),

  # strip.text.y = element_blank(),
  strip.background = element_rect(fill = rgb(.9,.95,1), colour = gray(.5), size = .2),

  panel.border = element_rect(fill = FALSE, colour = gray(.70)),
  panel.grid.minor.y = element_blank(),
  panel.grid.minor.x = element_blank(),
  panel.spacing.x = unit(0.10, "cm"),
  panel.spacing.y = unit(0.10, "cm"),

# axis.ticks.y= element_blank()
  axis.ticks = element_blank(),
  axis.text = element_text(size = 12, colour = "black"),
  axis.text.y = element_text(margin = ggplot2::margin(0, 3, 0, 3)),
  axis.text.x = element_text(margin = ggplot2::margin(-1, 0, 3, 0)),

  # Specific to HFI, suicide row-labeled plots
  text = element_text(size = 12),
  strip.text = element_blank()
)


