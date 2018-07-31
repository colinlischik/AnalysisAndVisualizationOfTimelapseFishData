# plotting the experimental data established with the 4 previous scripts
## loading the needed libraries
library(ggpubr)
#library(ggrepel)
#library(data.table)
#library(zoo)
library(ggpval)
# install.packages("devtools")
#devtools::install_github("s6juncheng/ggpval")

#------------------change these variables------------------------------

## set the working directory
workingdirectory = "C:\\Users\\Colin_Lischik\\R\\"
## how many zslices should be deleted on each end of the stack? to avoid having black slices
zslicestodelete = 20
## changing the plot
### title 
plottitle = expression(paste(italic("in vivo"), " SPIM verification of fluorophores"))
### ylabel
plotylab = "fluorescence intensity\nnormalized to control [A.U.]"
### y limits
plotylim = c(0,3.4)
### color palette to be used (has to be the number of tested colors, e.g. red and green = 2)
plotpalette = c("#a1d76a", "#e9a3c9")
### in which order should the fluorophores be plotted?
fplevels = c("Venus", "Clover", "eGFPvarA206K", "eGFP", "tagRFP", "mRFP", "mCherry")
### which fluorophores should be compared?
my_comparisons = list(c("eGFP", "eGFPvarA206K"), c("eGFP", "Clover"), c("eGFP", "Venus"), c("mCherry", "mRFP"), c("mCherry", "tagRFP"))
### where should it be saved?
savingdirectory = workingdirectory
### filename
filename = "E_all SPIM.pdf"
### filewidth
filewidth = 10
### fileheight
fileheight = 4.5
### filescale
filescale = 0.6

#------------------do not change anything from here on-----------------
## setting the working directory
setwd(workingdirectory)

## loading data if not already loaded
if(!exists("data", inherits = FALSE)){
  data = read.table("measurements_linked.csv", sep=",", header = TRUE)
  data = as.data.frame(data)
  data$green = as.character(data$green)
  data$red = as.character(data$red)
  data$experiment = as.character(data$experiment)
}

## selecting matching data for both experiments
greendata = data[(data$experiment == "green" | data$experiment == "both") & data$numeratorchannel == "0",]
greendata$plot = "green"
greendata$fp = greendata$green
reddata = data[(data$experiment == "red" | data$experiment == "both") & data$numeratorchannel == "1",]
reddata$plot = "red"
reddata$fp = reddata$red
alldata = rbind(greendata, reddata)
### delete first slices
alldata = alldata[alldata$X > zslicestodelete,]
### delete last slices
maxpertp = aggregate(. ~ timestamp, alldata[c("timestamp", "X")], max)
colnames(maxpertp) = c("timestamp", "maxX")
alldata = merge(alldata, maxpertp)
alldata$Xcorr = alldata$X - alldata$maxX
alldata = alldata[alldata$Xcorr < -zslicestodelete,]

### remove outliers
alldataold = alldata
alldata = NULL

for (i in 1:7) {
  alldatatemp = alldataold[alldataold$fp == fplevels[i],]
  alldata = rbind(alldata, alldatatemp[!alldatatemp$Mean %in% boxplot.stats(alldatatemp$Mean)$out,])
}

plot = ggboxplot(alldata,
                   x = "fp",
                   y = "Mean",
                   ylim = plotylim,
                   ylab = plotylab,
                   color = "plot",
                   title = plottitle,
                   palette = plotpalette,
                   legend = "none",
                   ggtheme = theme_bw(),
                   order = fplevels) + 
  stat_compare_means(label = "p.signif", method = "t.test",
                     comparisons = my_comparisons)
plot = plot + rremove("xlab")

#setwd(savingdirectory)
#ggsave(filename, plot, width = filewidth, height = fileheight, scale = filescale)
