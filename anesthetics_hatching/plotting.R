# plotting hatching and swimming of Bungarotoxin mRNA injected embryos
library(ggplot2)
library(ggpval)
library(plyr)
library(xlsx)

#------------------change these variables------------------------------

## set the working directory
workingdirectory = "C:\\Users\\Colin_Lischik\\R\\"
## how is the data called? For this script it needs to be xlsx, or the script needs to be changed
file = "bungarotoxin_dilutions.xlsx"
## renaming the conditions for plotting
conditions = c("0 ng/µl", "3 ng/µl", "6 ng/µl", "12 ng/µl", "25 ng/µl")
## labels for days post fertilization
labels <- c("6" = "6 dpf", "8" = "8 dpf", "12" = "12 dpf", "13" = "13 dpf")
## changing plots
### plot_hatch will only plot the hatched embryos in percent
#### title
hatchtitle = expression(paste("Hatched embryos injected with ", italic(alpha),  italic("-Bungarotoxin")))
#### xlabel
hatchxlab = "Developmental Stage"
#### ylabel
hatchylab = "Hatched embryos [% of alive]"
#### savingdirectory
savingdirectory1 = workingdirectory
#### filename
hatchfile = "D_wake up dilutions.pdf"
#### file width
hatchwidth = 10
#### file height
hatchheight = 6.5
#### file scale
hatchscale = 0.45
### plot_hatch_swim will plot hatched and swimming embryos in percent
#### title
hatchswimtitle = expression(paste("Hatched and swimming embryos injected with ", alpha,  italic("-Bungarotoxin")))
#### xlabel
hatchswimxlab = "Developmental Stage"
#### ylabel
hatchswimylab = "Hatched embryos [% of alive]"
#### sizelegend
hatchswimsizelegend = "swimming embryos\n[% of alive]"
#### savingdirectory
savingdirectory2 = workingdirectory
#### filename
hatchswimfile = "C_wake up dilutions.pdf"
#### file width
hatchswimwidth = 10
#### file height
hatchswimheight = 6.5
#### file scale
hatchswimscale = 0.6
#------------------do not change anything from here on-----------------
setwd(workingdirectory)

## loading data
my_data <- read.xlsx(file, sheetName="Sheet1")
my_data$Condition = as.factor(my_data$Condition)
## renaming data if needed
levels(my_data$Condition) = conditions
my_data$hatchedperc = my_data$hatched / (my_data$total - my_data$dead) * 100
my_data$swimmingperc = my_data$swimming / (my_data$total - my_data$dead) * 100
my_data$movementindex = my_data$movement / (my_data$nr..embryos * my_data$time) * 120

## plotting
p_hatch = ggplot(my_data, aes(x = Stage, y = hatchedperc , group = Condition, color = Condition)) +
  geom_point() +
  geom_line() +
  theme_bw() +
  ggtitle(hatchtitle) +
  xlab(hatchxlab) + 
  ylab(hatchylab)

p_hatch_swim = ggplot(my_data, aes(x = Stage, y = hatchedperc , group = Condition, color = Condition)) +
  geom_point(aes(size = swimmingperc)) +
  geom_line() +
  theme_bw() +
  guides(size = guide_legend(title = hatchswimsizelegend)) +
  ggtitle(hatchswimtitle) +
  xlab(hatchswimxlab) + 
  ylab(hatchswimylab)

## saving plots
setwd(savingdirectory1)
ggsave(hatchfile, p_hatch, width = hatchwidth, height = hatchheight, scale = hatchscale)

setwd(savingdirectory2)
ggsave(hatchswimfile, p_hatch_swim, width = hatchswimwidth, height = hatchswimheight, scale = hatchswimscale)