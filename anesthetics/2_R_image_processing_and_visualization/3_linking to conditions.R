## reading data and linking to injected fluorophores and chorionation stage
library(data.table)

#------------------change these variables------------------------------

## set the working directory
setwd("C:\\Users\\Colin_Lischik\\R\\")
## what are the plate identifiers?
plates = c("plate 1", "plate 2")
## what are the files for dropping? has to be the same length as plates
files_for_conditions = c("loading_plate1.csv", "loading_plate2.csv")
## which separators have been used for the files for dropping? has to be the same length as plates
files_for_conditions_separators = c(";", ";")

#------------------do not change anything from here on-----------------

## loading measurements and fluorophore injection plan
data = read.table("measurements_dropped.csv", sep=",", header = TRUE)
data = as.data.frame(data)

## iterate over plates and add conditions
### initializing vector
datacond = NULL

for (i in length(plates)) {
  ## loading condition
  condition = fread(files_for_conditions[i], sep=files_for_conditions_separators[i])
  ## merging conditions to  data
  datacond_temp = merge(data[data$plate == plates[i],], condition, by = "well")
  ## binding data
  datacond = rbind(datacond, datacond_temp)
}

## quality control, if all rows have a correspondence in experiment
qcdatacond = datacond$well[is.na(datacond$condition)]
if(length(qcdatacond) != 0) { stop("Wells with no correspondence in column experiment detected")}

#write.csv(datacond, file = "measurements_dropped_linked.csv")