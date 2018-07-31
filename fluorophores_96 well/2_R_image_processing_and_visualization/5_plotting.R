# plotting the experimental data created with the 4 previous scripts
library(ggplot2)
library(ggrepel)
library(data.table)
library(zoo)

#------------------change these variables------------------------------

## set the working directory
workingdirectory = "C:\\Users\\Colin_Lischik\\R\\"
## how do the plates start? Plates with the same controls can also be concatenated
## for concatenation the first plate needs to have the control
plates = list(c("plate1", "plate2"), c("plate3"))
## which timesteps were used for the plates? [minutes] until now only two different ones are supported
timesteps = c(20, 43)
## on which fluorophore should the channels be normalized?
greennorm_fp = "eGFP"
rednorm_fp = "mCherry"
## which hpf should be plotted?
minhpf = 1
maxhpf = 40
## how are the channels called?
firstchannel = "CO2" #should be the green channel
secondchannel = "CO4" #should be the red channel
## should something not be plotted?
noplotgreen = c("Achilles", "Kaede unconv.")
noplotred = c("Kaede conv.")
## modifications to the plots:
### green
#### title
greentitle = "Green fluorescent proteins"
#### xlabel
greenxlabel = "time post fertilization [h]"
#### ylabel
greenylabel = "fluorescence intensity\nnormalized to control [A.U.]"
#### colors (needs to be at least the number of fluorescent proteins)
greencolors = c("#c7e9c0", "#a1d99b", "#74c476", "#31a354", "#006d2c", "#a1d99b", "#74c476", "#31a354", "#006d2c")
#### linetypes (needs to be at least the number of fluorescent proteins)
greenlinetypes = c("solid", "solid", "solid", "solid", "solid", "dashed", "dashed", "dashed", "dashed")
#### name of the saved file
greenname = "green.pdf"
#### width of the saved file
greenwidth = 10
#### height of the saved file
greenheight = 4.5
#### scale of the saved file
greenscale = 0.6

#ggsave("green.pdf", pgreen, width = 10, height = 4.5, scale = 0.6)
#ggsave("red.pdf", pred, width = 10, height = 4.5, scale = 0.6)
### red
#### title
redtitle = "Red fluorescent proteins"
#### xlabel
redxlabel = "time post fertilization [h]"
#### ylabel
redylabel = "fluorescence intensity\nnormalized to control [A.U.]"
#### colors (needs to be at least the number of fluorescent proteins)
redcolors = c("#fcae91", "#fb6a4a", "#cb181d", "#fcae91", "#fb6a4a", "#cb181d", "#000000")
#### linetypes (needs to be at least the number of fluorescent proteins)
redlinetypes = c("solid", "solid", "solid", "dashed", "dashed", "dashed", "solid")
#### name of the saved file
redname = "red.pdf"
#### width of the saved file
redwidth = 10
#### height of the saved file
redheight = 4.5
#### scale of the saved file
redscale = 0.6

### where should the graph be saved? if to the same folder set this variable to: "workingdirectory"
savingdirectory = workingdirectory
#------------------do not change anything from here on-----------------

setwd(workingdirectory)

## loading data if not already loaded
if(!exists("data", inherits = FALSE)){
  #data = fread("measurements_dropped_linked.csv", sep = ",", drop = c("V1", "X"))
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

## normalizing per plate combination
### initializing vectors
datagreennorm_mean = NULL
datarednorm_mean = NULL
## aggregate to get control normalizer values
for (i in plates) {
  tempiterator = 0
  for (j in i){
    if (tempiterator == 0){
      ## aggregate to get control normalizer values
      datagreenctr = greendata[greendata$experiment == "Ctr" & (startsWith(greendata$well, j)),]
      dataredctr = reddata[reddata$experiment == "Ctr" & (startsWith(reddata$well, j)),]
      datagreenctr_mean = aggregate(datagreenctr[,c("Mean", "Median", "hpf")], by = list(datagreenctr$hpf), FUN = mean, na.rm = TRUE)
      dataredctr_mean = aggregate(dataredctr[,c("Mean", "Median", "hpf")], by = list(dataredctr$hpf), FUN = mean, na.rm = TRUE)  
    }

    ## normalize with aggregated controls
    datagreennorm_mean_temp = merge(greendata[startsWith(greendata$well, j),], datagreenctr_mean, by = "hpf")
    datagreennorm_mean_temp$Mean = datagreennorm_mean_temp$Mean.x / datagreennorm_mean_temp$Mean.y
    datagreennorm_mean_temp$Median = datagreennorm_mean_temp$Median.x / datagreennorm_mean_temp$Median.y
    
    datarednorm_mean_temp = merge(reddata[startsWith(reddata$well, j),], dataredctr_mean, by = "hpf")
    datarednorm_mean_temp$Mean = datarednorm_mean_temp$Mean.x / datarednorm_mean_temp$Mean.y
    datarednorm_mean_temp$Median = datarednorm_mean_temp$Median.x / datarednorm_mean_temp$Median.y
    
    ## add to common table
    datagreennorm_mean = rbind(datagreennorm_mean, datagreennorm_mean_temp)
    datarednorm_mean = rbind(datarednorm_mean, datarednorm_mean_temp)
    
    tempiterator = tempiterator + 1
  }
}

## delete empty controls
datagreennorm_mean_noempty = datagreennorm_mean[datagreennorm_mean$green != "empty",]
datarednorm_mean_noempty = datarednorm_mean[datarednorm_mean$red != "empty",]

## levels for plotting n
redlevels = levels(as.factor(datarednorm_mean_noempty$red))
greenlevels = levels(as.factor(datagreennorm_mean_noempty$green))
redlevels_table = table(datarednorm_mean_noempty$red[datarednorm_mean_noempty$hpf == 0 & datarednorm_mean_noempty$zslice == 1])
redlevels_n = NULL
for (i in 1:length(redlevels)) {
  redlevels_n[i] = paste(names(redlevels_table)[i], " (n = ", redlevels_table[i], ")", sep = "")
}
greenlevels_n = NULL
greenlevels_table = table(datagreennorm_mean_noempty$green[datagreennorm_mean_noempty$hpf == 0 & datagreennorm_mean_noempty$zslice == 1])
for (i in 1:length(greenlevels)) {
  greenlevels_n[i] = paste(names(greenlevels_table)[i], " (n = ", greenlevels_table[i], ")", sep = "")
}

## only include data until the max hpf to be plotted
datagreennorm_mean_noempty = datagreennorm_mean_noempty[datagreennorm_mean_noempty$hpf > minhpf & datagreennorm_mean_noempty$hpf < maxhpf,]
datarednorm_mean_noempty = datarednorm_mean_noempty[datarednorm_mean_noempty$hpf > minhpf & datarednorm_mean_noempty$hpf < maxhpf,]

## delete all fluorescent proteins, which should not be plotted
datagreennorm_mean_noempty = datagreennorm_mean_noempty[!datagreennorm_mean_noempty$green %in% noplotgreen,]
datarednorm_mean_noempty = datarednorm_mean_noempty[!datarednorm_mean_noempty$green %in% noplotred,]

## normalize paper plot data to fuse red graphs and green graphs
### green
greenplates = NULL
### list of all timepoints
full_hpf_list = lapply(timesteps/60, function(x) seq(0, maxhpf, x))
full_hpf_list = unlist(full_hpf_list)
missingvector = data.frame(hpf = full_hpf_list, Mean = rep(NA, length(full_hpf_list)), Median = rep(NA, length(full_hpf_list)))
### which columns should be kept for plotting?
columnvector = c("hpf", "Mean", "green", "experiment")
for (i in plates) {
  ### initializing
  greenplates_temp = NULL
  for (j in i) {
    ## load all plates, which belong to the same control
    greenplates_temp = rbind(greenplates_temp, datagreennorm_mean_noempty[(startsWith(datagreennorm_mean_noempty$well, j)),])
  }
  if(i[1] == plates[[1]][1]){
    ## create the control vector for normalization
    greenplatectraggregate = greenplates_temp[greenplates_temp$green == "eGFP", c("hpf", "Mean", "Median")]
    greenplatectraggregate = rbind(greenplatectraggregate, missingvector)
    greenplatectraggregate = aggregate(greenplatectraggregate, by = list(greenplatectraggregate$hpf), mean, na.rm = TRUE)
    greenplatectraggregate$Mean_Ctr = na.approx(greenplatectraggregate$Mean, na.rm = FALSE)
    greenplatectraggregate$Median_Ctr = na.approx(greenplatectraggregate$Median, na.rm = FALSE)
    greenplatectraggregate = greenplatectraggregate[,c("hpf", "Mean_Ctr", "Median_Ctr")]
    greenplateaggregate = greenplatectraggregate
    
  } else {
    ## create the vector for normalization
    greenplateaggregate = greenplates_temp[greenplates_temp$green == "eGFP", c("hpf", "Mean", "Median")]
    greenplateaggregate = rbind(greenplateaggregate, missingvector)
    greenplateaggregate = aggregate(greenplateaggregate, by = list(greenplateaggregate$hpf), mean, na.rm = TRUE)
    greenplateaggregate$Mean_Ctr = na.approx(greenplateaggregate$Mean, na.rm = FALSE)
    greenplateaggregate$Median_Ctr = na.approx(greenplateaggregate$Median, na.rm = FALSE)
    greenplateaggregate = greenplateaggregate[,c("hpf", "Mean_Ctr", "Median_Ctr")]
  }
  
  ## normalize the control mean
  greenplateaggregate$Mean_Ctr = greenplateaggregate$Mean_Ctr / greenplatectraggregate$Mean_Ctr
  greenplateaggregate$Median_Ctr = greenplateaggregate$Median_Ctr / greenplatectraggregate$Median_Ctr

  ## normalize the plate to the control and fuse it to the list of plates
  greenplates_temp = merge(greenplates_temp, greenplateaggregate)
  greenplates_temp$Mean = greenplates_temp$Mean / greenplates_temp$Mean_Ctr
  greenplates = rbind(greenplates[,columnvector], greenplates_temp[,columnvector])
}

## normalize paper plot data to fuse red graphs and green graphs
### red
redplates = NULL
### which columns should be kept for plotting?
columnvector = c("hpf", "Mean", "red", "experiment")
for (i in plates) {
  ### initializing
  redplates_temp = NULL
  for (j in i) {
    ## load all plates, which belong to the same control
    redplates_temp = rbind(redplates_temp, datarednorm_mean_noempty[(startsWith(datarednorm_mean_noempty$well, j)),])
  }
  if(i[1] == plates[[1]][1]){
    ## create the control vector for normalization
    redplatectraggregate = redplates_temp[redplates_temp$red == "mCherry", c("hpf", "Mean", "Median")]
    redplatectraggregate = rbind(redplatectraggregate, missingvector)
    redplatectraggregate = aggregate(redplatectraggregate, by = list(redplatectraggregate$hpf), mean, na.rm = TRUE)
    redplatectraggregate$Mean_Ctr = na.approx(redplatectraggregate$Mean, na.rm = FALSE)
    redplatectraggregate$Median_Ctr = na.approx(redplatectraggregate$Median, na.rm = FALSE)
    redplatectraggregate = redplatectraggregate[,c("hpf", "Mean_Ctr", "Median_Ctr")]
    redplateaggregate = redplatectraggregate
    
  } else {
    ## create the vector for normalization
    redplateaggregate = redplates_temp[redplates_temp$red == "mCherry", c("hpf", "Mean", "Median")]
    redplateaggregate = rbind(redplateaggregate, missingvector)
    redplateaggregate = aggregate(redplateaggregate, by = list(redplateaggregate$hpf), mean, na.rm = TRUE)
    redplateaggregate$Mean_Ctr = na.approx(redplateaggregate$Mean, na.rm = FALSE)
    redplateaggregate$Median_Ctr = na.approx(redplateaggregate$Median, na.rm = FALSE)
    redplateaggregate = redplateaggregate[,c("hpf", "Mean_Ctr", "Median_Ctr")]
  }
  
  ## normalize the control mean
  redplateaggregate$Mean_Ctr = redplateaggregate$Mean_Ctr / redplatectraggregate$Mean_Ctr
  redplateaggregate$Median_Ctr = redplateaggregate$Median_Ctr / redplatectraggregate$Median_Ctr
  
  ## normalize the plate to the control and fuse it to the list of plates
  redplates_temp = merge(redplates_temp, redplateaggregate)
  redplates_temp$Mean = redplates_temp$Mean / redplates_temp$Mean_Ctr
  redplates = rbind(redplates[,columnvector], redplates_temp[,columnvector])
}

## plotting green fluorescent proteins

pgreen = ggplot(greenplates, aes(x = hpf, y = Mean, group = green, colour = green, linetype = green)) +
  geom_smooth() +
  theme_bw() + 
  theme(legend.title=element_blank()) +
  ggtitle(greentitle) +
  xlab(greenxlabel) + 
  ylab(greenylabel) + 
  scale_colour_manual(values = greencolors, labels = greenlevels_n) + 
  scale_linetype_manual(values = greenlinetypes, labels = greenlevels_n)

pgreen

pred = ggplot(redplates, aes(x = hpf, y = Mean, group = red, color = red, linetype = red)) +
  geom_smooth() +
  theme_bw() + 
  theme(legend.title=element_blank()) +
  ggtitle(redtitle) +
  xlab(redxlabel) + 
  ylab(redylabel) + 
  scale_colour_manual(values = redcolors, labels = redlevels_n) + 
  scale_linetype_manual(values = redlinetypes, labels = redlevels_n)

pred

## save created plots
setwd(savingdirectory)
ggsave(greenname, pgreen, width = greenwidth, height = greenheight, scale = greenscale)
ggsave(redname, pred, width = redwidth, height = redheight, scale = redscale)
