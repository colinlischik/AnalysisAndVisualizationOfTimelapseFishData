## reading data and linking to injected fluorophores and chorionation stage
library(data.table)

#------------------change these variables------------------------------

## set the working directory
setwd("C:\\Users\\Colin_Lischik\\R\\")
## how is the file with conditions called?
fluorophorefile = "Fluorophore injection plan.csv"
## which separator has been used in the file?
fluorophorefilesep = ";"

#------------------do not change anything from here on-----------------
## loading measurements and fluorophore injection plan
data = read.table("measurements_dropped.csv", sep=",", header = TRUE)
data = as.data.frame(data)
fluorophores = fread(fluorophorefile, sep = fluorophorefilesep)

## how many rows and columns are in the plate?
rows = match(max(fluorophores$row), LETTERS)
columns = max(fluorophores$column)

## merge data with injection plan
datafp = merge(data, fluorophores[,c("well", "randomwells")], by = "well")

## quality control, if all rows have a correspondence in experiment
qcdatafp = datafp$well[is.na(datafp$experiment)]
if(length(qcdatafp) != 0) { stop("Wells with no correspondence in column experiment detected")}

## save changed file
write.csv(datafp, file = "measurements_dropped_linked.csv")
