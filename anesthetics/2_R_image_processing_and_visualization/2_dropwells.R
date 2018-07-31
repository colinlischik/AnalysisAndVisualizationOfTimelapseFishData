## drop wells, which are empty or contain dead embryos
library(data.table)

#------------------change these variables------------------------------

## set the working directory
setwd("C:\\Users\\Colin_Lischik\\R\\")
## what are the plate identifiers?
plates = c("plate 1", "plate 2")
## what are the files for dropping? has to be the same length as plates
files_for_dropping = c("dropwells_plate1.csv", "dropwells_plate2.csv")
## which separators have been used for the files for dropping? has to be the same length as plates
files_for_dropping_separators = c(";", ";")

#------------------do not change anything from here on-----------------
## reading data
data = read.table("measurements.csv", sep=",", header = TRUE)
data = as.data.frame(data)
data$well = as.character(data$well)
data$plate = as.character(data$plate)

## iterate over data to drop all negative wells
datadrop = NULL
for (i in length(files_for_dropping)){
  ## reading wells to drop
  dropwells = fread(files_for_dropping[i], sep = files_for_dropping_separators[i])
  ## merge data with dropwells to cross match, if rows need to be dropped. For drop ID is dropped
  datadrop_temp = merge(data[data$plate == plates[i],], dropwells[,c("well", "positive")], by = "well")
  datadrop = rbind(datadrop, datadrop_temp)
  }

datadrop$positive = as.integer(datadrop$positive)

## quality control, if all rows have a correspondence in positive
qcdatadrop = datadrop$well[is.na(datadrop$positive)]
if(length(qcdatadrop) != 0) { stop("Wells with no correspondence in column positive detected")}

## drop wells
datadropped = datadrop[datadrop$positive == 1,]

## export finished data
write.csv(datadropped, file = "measurements_dropped.csv")