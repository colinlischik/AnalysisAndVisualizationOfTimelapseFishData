# this file is merging all the results into a combined csv file
library(data.table)

#------------------change these variables------------------------------

## set the working directory
setwd("C:\\Users\\Colin_Lischik\\R\\")
## what are the dataset folders?
datasets = c("D:\\bungarotoxin temp\\measurements\\plate 1", "D:\\bungarotoxin temp\\measurements\\plate 2")
## what is the timestep of the plates in minutes
timesteps = c(20, 33)

#------------------do not change anything from here on-----------------
## data preparation, this will load all the data and will save it as one csv for the measurements
current_folder = getwd()

resultstable= NULL
for (i in datasets){
  setwd(i)
  ### find all files contained
  filelist = list.files(i, recursive = TRUE)
  plate = substr(i, nchar(dirname(i) + 2), nchar(i))
  ### loop over all files of the plate
  result_input = NULL
  for (j in 1:length(filelist)){
    result_input = read.table(filelist[j], header = TRUE)
    ## drop last line
    result_input = result_input[1:(length(result_input[,1])-1),]
    #### define well
    welltemp = substr(filelist[j], nchar(dirname(filelist[j])), nchar(filelist[j]) - 4)
    
    
    print(c(welltemp, "measurements"))
    result_input = cbind(well = welltemp, min = (result_input$Slice - 1) * timestep1, result_input, plate = plate)
    resultstable = rbind(resultstable, result_input)
  }
}

#### saving results
setwd(current_folder)
write.csv(resultstable, file = "measurements.csv")