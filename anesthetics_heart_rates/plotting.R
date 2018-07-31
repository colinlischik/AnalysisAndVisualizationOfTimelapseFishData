# plotting the heart rate of different experiments. This script has no parts, which should be changed or not, since it is very short

## change the working directory and load the needed libraries
setwd("C:\\Users\\Colin_Lischik\\R\\")
library(ggplot2)
library(ggpval)
library(xlsx)
library(ggpubr)

## opening the xlsx file
my_data <- read.xlsx("D_BPM_table.xlsx", sheetName="Sheet1")
## renaming the conditions to show n's
levels(my_data$condition) = c("Bungarotoxin\nmRNA\n(n = 11)", "Etomidate\n(n = 8)", "mock\ninjection\n(n = 4)", "Tricaine\n(n = 9)", "wildtype control\n(n = 6)")
## manual color scale
colorscale = c("#762a83", "#af8dc3", "#e7d4e8", "#d9f0d3", "#7fbf7b", "#1b7837")
## which data should be compared to which?
my_comparisons = list(c(levels(my_data$condition)[1], levels(my_data$condition)[3]), c(levels(my_data$condition)[5], levels(my_data$condition)[3]), c(levels(my_data$condition)[2], levels(my_data$condition)[5]), c(levels(my_data$condition)[4], levels(my_data$condition)[5]))

## plotting
plot = ggboxplot(my_data,
                   x = "condition",
                   xlab = "condition",
                   y = "BPM",
                   #ylim = c(0,3.5),
                   ylab = "Heart rate [beats per minute]",
                   color = "condition",
                   title = "Heart rate distribution after exposure to anesthetics",
                   palette = c(colorscale[1], colorscale[3:6]),
                   legend = "none",
                   ggtheme = theme_bw()) + 
  stat_compare_means(label = "p.signif", method = "t.test",
                     comparisons = my_comparisons)

## setting the directory for saving the plot and saving it
setwd("C:\\Users\\Colin_Lischik\\R\\")
ggsave("B_BPM final.pdf", plot, width = 10, height = 4.5, scale = 0.6)