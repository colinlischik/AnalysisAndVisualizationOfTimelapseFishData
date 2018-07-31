# normalizing the values to the injection control at a certain timepoint
# normalization is performed per well

#------------------change these variables------------------------------

## set the working directory
setwd("C:\\Users\\Colin_Lischik\\R\\")
## which timepoint in hours should be used to normalize? You need to enter a range here, since there might be different timesteps
timenorm = c(10, 10.1)
## how are the channels called?
firstchannel = "CO2" #should be the green channel
secondchannel = "CO4" #should be the red channel

#------------------do not change anything from here on-----------------

## loading data if not already loaded
if(!exists("data", inherits = FALSE)){
  data = read.table("measurements_dropped_linked.csv", sep=",", header = TRUE)
  data = as.data.frame(data)
  data$green = as.character(data$green)
  data$red = as.character(data$red)
  data$experiment = as.character(data$experiment)
  data$quotient = as.character(data$quotient)
  data$well = as.character(data$well)
}

## removing the mask string from the quotient
channels = gsub("mask", "", data$quotient)
## checking the measurement and mask channel
data$measurementchannel = gsub("_.*$", "", channels)
data$maskchannel = gsub(".*_", "", channels)

## aggregate normalizing values
normalizers = aggregate(data, by = list(data$well, data$quotient, data$hpf, data$maskchannel), mean)
normalizerstemp = normalizers
normalizers = normalizerstemp
normalizers = normalizers[normalizers$Group.3 >= timenorm[1] & normalizers$Group.3 <= timenorm[2],]
normalizers = normalizers[normalizers$Group.2 != paste(firstchannel, "_", secondchannel, "mask") & normalizers$Group.2 != paste(secondchannel, "_", firstchannel, "mask"),]
normalizers = normalizers[,c("Group.1", "Mean", "Median", "StdDev", "Group.4")]
colnames(normalizers) = c("well", "normMean", "normMedian", "normStdDev", "maskchannel")

## merge dataframe
data = merge(data, normalizers, by=c("well", "maskchannel"))

## clean data
### sort out normalizing rows
data = data[data$quotient != paste(firstchannel, "_", firstchannel, "mask") & data$quotient != paste(secondchannel, "_", secondchannel, "mask"),]
### normalize 
data$Mean = data$Mean/data$normMean
data$Median = data$Median/data$normMedian
data$StdDev = data$StdDev/data$StdDev
### select desired rows
data = data[,c("well", "maskchannel", "measurementchannel", "hpf", "green", "red", "experiment", "Mean", "Median", "StdDev", "X")]
colnames(data)[which(names(data) == "X")] = "zslice"

## save the resulting file
write.csv(data, file = "measurements_dropped_linked_normalized.csv")
    