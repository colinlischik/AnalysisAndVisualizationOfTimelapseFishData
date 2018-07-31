# This script takes the positive wells and compiles different lists for use in Imagej to visualize positive wells
library(data.table)

#------------------change these variables------------------------------
## how many wells should be used?
noofwellstouse = 66
##set the working directory
setwd("C:\\Users\\Colin_Lischik\\R\\")
## how is the name of the csv file?
filename = "positive.csv"

#------------------do not change anything from here on-----------------
##reading positive wells
dropwells = fread(filename, sep = ",")

##only keep positive wells
dropwells = dropwells$well[dropwells$positive == 1]

##create a string with a list of wells in the form
##(list[i] == "A001.tif") |
##to use in selecting the right wells from a filelist
dropwellsor = NULL
for (i in 1:noofwellstouse) {
  dropwellsor = c(dropwellsor, "(list[i] == \"", dropwells[i], ".tif\" ) | ")  
}
dropwellsor = paste(dropwellsor, collapse = "")

##create a string with a list of wells in the form
##stack_1 = A001-1.tif
##for usage in the montage function
dropwellsmultistack = NULL
for (i in 1:noofwellstouse) {
  dropwellsmultistack = c(dropwellsmultistack, " stack_", i, "=", dropwells[i], "-1.tif")  
}
dropwellsmultistack = paste(dropwellsmultistack, collapse = "")

##create a string with a list of wells in the form
##wellstouse[0] = "A001";
##for creating an array with all the usable wells
dropwellsarray = NULL
for (i in 0:(noofwellstouse-1)) {
  dropwellsarray = c(dropwellsarray, "wellstouse[", i, "] = \"", dropwells[i + 1], "\";\n")  
}
dropwellsarray = paste(dropwellsarray, collapse = "")

##printing the resulting strings for usage in imagej macros
cat(dropwellsor)
dropwellsmultistack
cat(dropwellsarray)