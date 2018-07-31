# plotting the startle responses for different experiments. This script has no parts, which should be changed or not, since it is very short
## changing the working directory and importing libraries
setwd("C:\\Users\\Colin_Lischik\\R\\")
library(ggplot2)
library(ggpval)
library(ggpubr)

## read the data
my_data = read.delim2("Stab_experiment_trans_time_noE.csv", header = TRUE, sep = ";", stringsAsFactors = FALSE)
my_data$Row = as.factor(my_data$Row)
## change the condition names
levels(my_data$Row) = c("Bungarotoxin mRNA", "alpha-Bungarotoxin plasmid", "mock injected", "Wild-type control")
legendlabel = c(expression(paste(italic(alpha), italic("-Bungarotoxin"), " mRNA")), "Mock injected", "Wild-type control")

## changing the dpf labels
labels = list(dpf = c("st. 31 (6 dpf)", "st. 36 (8 dpf)", "st. 39 (12 dpf)", "st. 40 (13 dpf)"))
## manually changing the color scale
colorscale = c("#762a83", "#af8dc3", "#e7d4e8", "#d9f0d3", "#7fbf7b", "#1b7837")

## plotting
plot <- ggboxplot(my_data[my_data$Row != "alpha-Bungarotoxin plasmid",],
                   x = "Row",
                   xlab = FALSE,
                   y = "value",
                   ylab = "# startle responses",
                   group = "Row",
                   color = "Row",
                   facet.by = c("", "dpf"),
                   panel.labs = labels,
                   ylim = c(0,12.5),
                   title = "Startle responses of 10 iteration",
                   ggtheme = theme_bw())
plot = plot + scale_y_continuous(breaks = seq(0,10.1), minor_breaks = NULL)
plot = plot + scale_color_manual(labels = legendlabel, values = c(colorscale[1], colorscale[4], colorscale[6]))
plot = plot + rremove("x.ticks")
plot = plot + rremove("legend")
plot = plot + rremove("x.text")
plot = plot + stat_compare_means(label = "p.signif", method = "t.test",
                            comparisons = list(c("Bungarotoxin mRNA", "mock injected"), c("Bungarotoxin mRNA", "Wild-type control"))
                            )

## changing the working directory to the saving directory and saving the plot
setwd("C:\\Users\\Colin_Lischik\\R\\")
ggsave("C_startle response.pdf", plot, width = 10, height = 6.5, scale = 0.45)
