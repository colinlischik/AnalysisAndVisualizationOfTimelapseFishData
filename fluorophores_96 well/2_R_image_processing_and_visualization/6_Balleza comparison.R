# comparing the results to the results of other publications
library(ggplot2)
library(data.table)
library(ggrepel)

#------------------change these variables------------------------------

## set the working directory
setwd("C:\\Users\\Colin_Lischik\\R\\")
## which fluorophores should be plotted?
plottingvector = c("eGFP", "eGFPwCR13", "eGFPwCR13A206K", "mGFPmut2", "Venus", "mVenNB", "YFP", "Clover", "mCherry", "mRFP1*", "mScarlet", "tagRFP")
## how are the channels called?
firstchannel = "CO2" #should be the green channel
secondchannel = "CO4" #should be the red channel

#------------------do not change anything from here on-----------------

## loading data if not already loaded
if(!exists("data", inherits = FALSE)){
  data = read.table("measurements_dropped_linked_normalized.csv", sep=",", header = TRUE)
  data = as.data.frame(data)
  data$green = as.character(data$green)
  data$red = as.character(data$red)
  data$experiment = as.character(data$experiment)
  data$well = as.character(data$well)
}

## selecting matching data for both experiments
greendata = data[(data$experiment == "green" | (data$experiment == "Ctr" & data$green == "empty"
) | data$experiment == "both") & data$maskchannel == secondchannel,]
reddata = data[(data$experiment == "red" | (data$experiment == "Ctr" & data$red == "empty"
) | data$experiment == "both") & data$maskchannel == firstchannel,]
greendata$well = as.character(greendata$well)
reddata$well = as.character(reddata$well)

#### normalizing first two plates
## aggregate to get control normalizer values
datagreenctr = greendata[greendata$experiment == "Ctr" & (startsWith(greendata$well, "plate1") | startsWith(greendata$well, "plate2")),]
datagreenctr_mean = aggregate(datagreenctr[,c("Mean", "Median", "hpf")], by = list(datagreenctr$hpf), FUN = mean, na.rm = TRUE)
dataredctr = reddata[reddata$experiment == "Ctr"& (startsWith(reddata$well, "plate1") | startsWith(reddata$well, "plate2")),]
dataredctr_mean = aggregate(dataredctr[,c("Mean", "Median", "hpf")], by = list(dataredctr$hpf), FUN = mean, na.rm = TRUE)
## normalize with aggregated controls
datagreennorm_mean = merge(greendata[startsWith(greendata$well, "plate1") | startsWith(greendata$well, "plate2"),], datagreenctr_mean, by = "hpf")
datagreennorm_mean$Mean = datagreennorm_mean$Mean.x / datagreennorm_mean$Mean.y
datagreennorm_mean$Median = datagreennorm_mean$Median.x / datagreennorm_mean$Median.y

datarednorm_mean = merge(reddata[startsWith(reddata$well, "plate1") | startsWith(reddata$well, "plate2"),], dataredctr_mean, by = "hpf")
datarednorm_mean$Mean = datarednorm_mean$Mean.x / datarednorm_mean$Mean.y
datarednorm_mean$Median = datarednorm_mean$Median.x / datarednorm_mean$Median.y

#### normalizing third plate
## aggregate to get control normalizer values
datagreenctr = greendata[greendata$experiment == "Ctr" & startsWith(greendata$well, "plate3"),]
datagreenctr_mean = aggregate(datagreenctr[,c("Mean", "Median", "hpf")], by = list(datagreenctr$hpf), FUN = mean, na.rm = TRUE)
dataredctr = reddata[reddata$experiment == "Ctr"& startsWith(reddata$well, "plate3"),]
dataredctr_mean = aggregate(dataredctr[,c("Mean", "Median", "hpf")], by = list(dataredctr$hpf), FUN = mean, na.rm = TRUE)
## normalize with aggregated controls
datagreennorm_mean2 = merge(greendata[startsWith(greendata$well, "plate3"),], datagreenctr_mean, by = "hpf")
datagreennorm_mean2$Mean = datagreennorm_mean2$Mean.x / datagreennorm_mean2$Mean.y
datagreennorm_mean2$Median = datagreennorm_mean2$Median.x / datagreennorm_mean2$Median.y

datarednorm_mean2 = merge(reddata[startsWith(reddata$well, "plate3"),], dataredctr_mean, by = "hpf")
datarednorm_mean2$Mean = datarednorm_mean2$Mean.x / datarednorm_mean2$Mean.y
datarednorm_mean2$Median = datarednorm_mean2$Median.x / datarednorm_mean2$Median.y

datagreennorm_mean = rbind(datagreennorm_mean, datagreennorm_mean2)
datarednorm_mean = rbind(datarednorm_mean, datarednorm_mean2)

## delete empty controls
datagreennorm_mean_noempty = datagreennorm_mean[datagreennorm_mean$green != "empty",]
datarednorm_mean_noempty = datarednorm_mean[datarednorm_mean$red != "empty",]

### This region is hardcoded, since the values from the previous publication are fixed
green = 1:4
yellow = 5:8
red = 9:12
comparison = data.frame(FP = plottingvector, Mean = numeric(12))
for (i in 1:8){
  comparison$Mean[i] = as.double(mean(datagreennorm_mean_noempty$Mean[datagreennorm_mean_noempty$green == plottingvector[i] & datagreennorm_mean_noempty$hpf > 23 & datagreennorm_mean_noempty$hpf < 30]))
}
for (i in 9:length(plottingvector)){
  comparison$Mean[i] = mean(datarednorm_mean_noempty$Mean[datarednorm_mean_noempty$red == plottingvector[i] & datarednorm_mean_noempty$hpf > 23 & datarednorm_mean_noempty$hpf < 30])
}
comparison$Mean_relative_green = comparison$Mean / comparison$Mean[comparison$FP == "eGFP"]
comparison$Mean_relative_yellow = comparison$Mean / comparison$Mean[comparison$FP == "Venus"] * 1.2
comparison$Mean_relative_red = comparison$Mean / comparison$Mean[comparison$FP == "mRFP1*"]
comparison$Mean_relevant[comparison$FP %in% plottingvector[green]] = comparison$Mean_relative_green[comparison$FP %in% plottingvector[green]]
comparison$color[comparison$FP %in% plottingvector[green]] = "green"
comparison$Mean_relevant[comparison$FP %in% plottingvector[yellow]] = comparison$Mean_relative_yellow[comparison$FP %in% plottingvector[yellow]]
comparison$color[comparison$FP %in% plottingvector[yellow]] = "yellow"
comparison$Mean_relevant[comparison$FP %in% plottingvector[red]] = comparison$Mean_relative_red[comparison$FP %in% plottingvector[red]]
comparison$color[comparison$FP %in% plottingvector[red]] = "red"
meansBalleza = data.frame(FP = plottingvector,
                          Balleza_relative = c(1, 1, 0.91, 1.27, 1.2, 1.75, 1.15, 0.78, 0.31, 1, 1.31, 0.08))
comparison = merge(comparison, meansBalleza, by = "FP")

p = ggplot(comparison, aes(x = Balleza_relative, y = Mean_relevant, group = FP, color = color, label = FP)) +
  geom_point() +
  theme_bw() + 
  ggtitle(expression(paste("Comparison ", italic("O. latipes"), " vs. ", italic("E. coli in vivo"), " fluorescence"))) +
  xlab(expression(paste("Balleza (", italic("E. coli"), ")"))) + 
  ylab(expression(paste("this work (", italic("O. latipes"), ")"))) + 
  geom_text_repel(aes(label = FP), size = 3.5) +
  theme(legend.position="none") + 
  ylim(0,2.5) +
  geom_abline() +
  scale_color_manual(values = c("green", "red", "orange"))

ggsave("comparison.pdf", p, width = 10, height = 6, scale = 0.6)
p
