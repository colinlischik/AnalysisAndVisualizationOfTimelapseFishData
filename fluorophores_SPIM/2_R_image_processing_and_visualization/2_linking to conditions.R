# reading data and linking to injected fluorophores
## loading needed library
library(data.table)

#------------------change these variables------------------------------

## set the working directory
workingdirectory = "C:\\Users\\Colin_Lischik\\R\\"
## how is the conditions file named?
conditionsfile = "conditions.csv"
## which separator has been used in the conditionsfile
conditionsfileseparator = ";"

#------------------do not change anything from here on-----------------
## setting the workingdirectory
setwd(workingdirectory)

## loading measurements and fluorophore injection plan
data = as.data.frame(read.table("measurements.csv", sep=",", header = TRUE))

fluorophores = fread(conditionsfile, sep = conditionsfileseparator)

### merging fluorophore list with data
datafp = merge(data, fluorophores)

## quality control, if all rows have a correspondence in experiment
qcdatafp = datafp$well[is.na(datafp$green)]
if(length(qcdatafp) != 0) { stop("Wells with no correspondence in column green detected")}

write.csv(datafp, file = "measurements_linked.csv")