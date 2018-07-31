# this file is loading all the results from light-sheet microscopy and is re-saving them into a combined csv file
## loading needed library
library(data.table)

#------------------change these variables------------------------------

## set the working directory
workingdirectory = "C:\\Users\\Colin_Lischik\\R\\"
## where is the data?
dataset_folder = "D:\\SPIM measurements\\"

#------------------do not change anything from here on-----------------
setwd(workingdirectory)

## data preparation, this will load all the data and will save it as one csv for the measurements
current_folder = getwd()
## loading first dataset
### find all files contained
setwd(dataset_folder)
filelist = list.files(dataset_folder, recursive = TRUE)

### loop over all files from 0-2 dpf
result_input = NULL
resultstable = NULL
for (i in 1:length(filelist)){
#  for (i in 1:2){
  result_input = read.table(filelist[i], sep = ",", header = TRUE)
  #### quotient and timestamp
  quotient = substr(filelist[i], nchar(dirname(dirname(filelist[i]))) + 2, nchar(dirname(filelist[i])))
  timestamp = substr(filelist[i], nchar(dirname(dirname(dirname(filelist[i])))), nchar(dirname(dirname(filelist[i]))))
  numeratorchannel = substr(filelist[i], nchar(dirname(dirname(filelist[i]))) + 18, nchar(dirname(dirname(filelist[i]))) + 18)
  divisorchannel = substr(filelist[i], nchar(dirname(filelist[i])), nchar(dirname(filelist[i])))
  print(c(timestamp, quotient))
  result_input = cbind(timestamp, quotient, numeratorchannel, divisorchannel, result_input)
  resultstable = rbind(resultstable, result_input)
}

#### saving results
setwd(current_folder)
write.csv(resultstable, file = "measurements.csv")