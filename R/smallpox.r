# 6.2 learning cafe discussion
# Pictograph vs bar chart

library(ggplot2)

names <- c("Influenza A", "Malaria", "Smallpox", "Pertussis", "SARS")
rates <- c(0.1, 0.3, 1.0, 3.7, 11.0)
labels <- paste0(names, ' - ', rates, "%")

diseases <- data.frame(
    names = factor(names, levels=names),
    rates = rates,
    labels = factor(labels, levels=labels)
)

pdf("diseases_case_fatility_rate.pdf")

gg_disease <- ggplot(data=diseases) +
    geom_col(aes(x=labels, y=rates), fill='red3') +
    labs(x='', y='', title='Case fatality rate by disease') +
    coord_flip() +
    theme_minimal() +
    scale_y_discrete(expand = expand_scale(mult=c(0, .050))) +
    theme(panel.grid = element_blank(),
          axis.text.x = element_blank()
          # axis.text.y = element_text(margin = margin(l = 1))
    )

print(gg_disease)

dev.off()
