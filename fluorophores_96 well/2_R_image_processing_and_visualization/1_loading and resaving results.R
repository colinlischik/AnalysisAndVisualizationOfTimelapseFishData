# this file is merging all the results into a combined csv file
library(data.table)

#------------------change these variables------------------------------

## set the working directory
setwd("C:\\Users\\Colin_Lischik\\R\\")
## where is the data?
dataset_folder = "D:\\test folder\\"
## are there plate subsets?
plates = c("plate_codon1", "plate_codon2", "plate_codon3")
## what is the timestep of the plates in minutes
timesteps = c(20, 20, 43)
## how many zslices are present per well and timepoint?
zslices = 12

#------------------do not change anything from here on-----------------

## parameters to be set
timestep1 = 20 #timestep in minutes
timestep2 = 43 #timestep in minutes
plates1 = c("plate1_red", "plate2_green") #subset of plates, which will be added to the first timestep
plates2 = c("plate3_Balleza") #subset of plates, which will be added to the second timestep

## get the current working directory
current_folder = getwd()
## change into the data directory and find all contained files
setwd(dataset_folder)
filelist = list.files(dataset_folder, recursive = TRUE)

### loop over all files
result_input = NULL
resultstable = NULL
for (i in 1:length(filelist)){
  result_input = read.table(filelist[i], sep = ",", header = TRUE)
  ### define loop, quotient and well based on the filepath
  looptemp = substr(filelist[i], nchar(dirname(filelist[i])) + 4, nchar(filelist[i]) - 4)
  quotienttemp = substr(filelist[i], nchar(dirname(dirname(filelist[i]))) + 2, nchar(dirname(filelist[i])))
  if(nchar(quotienttemp) > 11){
    next
  }
  welltemp = substr(filelist[i], nchar(dirname(dirname(dirname(filelist[i])))), nchar(dirname(dirname(filelist[i]))))
  ### set the hours post fertilization depending on the plate
  hpf = ((as.double(looptemp) - 1)*timesteps[startsWith(welltemp, plates)])/60
  ### define the numeratorchannel, divisorchannel and mask from the filepath
  numeratorchannel = substr(filelist[i], nchar(dirname(dirname(filelist[i]))) + 2, nchar(dirname(dirname(filelist[i]))) + 4)
  divisorchannel = substr(filelist[i], nchar(dirname(dirname(filelist[i]))) + 17, nchar(dirname(dirname(filelist[i]))) + 19)
  mask = substr(filelist[i], nchar(dirname(dirname(filelist[i]))) + 6, nchar(dirname(dirname(filelist[i]))) + 8)
  ### bind the results and bind to the resultstable
  print(c(welltemp, quotienttemp, looptemp, "measurements"))
  result_input = cbind(well = welltemp, quotient = quotienttemp, loop = as.integer(looptemp), hpf = hpf, result_input)
  resultstable = rbind(resultstable, result_input)
}

### saving results
setwd(current_folder)
write.csv(resultstable, file = "measurements.csv")