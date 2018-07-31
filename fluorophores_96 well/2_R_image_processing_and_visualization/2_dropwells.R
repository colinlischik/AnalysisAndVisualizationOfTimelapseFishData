## drop wells, which are empty or contain dead embryos
library(data.table)

#------------------change these variables------------------------------

## set the working directory
setwd("C:\\Users\\Colin_Lischik\\R\\")
## how is the file with positive wells called?
wellfile = "dropwells.csv"

#------------------do not change anything from here on-----------------

## reading wells to drop
dropwells = fread(wellfile, sep = ",")

## reading data
data = read.table("measurements.csv", sep=",", header = TRUE)
data = as.data.frame(data)
data$well = as.character(data$well)

## merge data with dropwells to cross match, if rows need to be dropped. For drop ID is dropped
datadrop = merge(data, dropwells[,c("well", "positive")], by = "well")
datadrop$positive = as.integer(datadrop$positive)

## quality control, if all rows have a correspondence in positive
qcdatadrop = datadrop$well[is.na(datadrop$positive)]
if(length(qcdatadrop) != 0) { stop("Wells with no correspondence in column positive detected")}

## drop wells
datadropped = datadrop[datadrop$positive == 1,]

## export finished data
write.csv(datadropped, file = "measurements_dropped.csv")