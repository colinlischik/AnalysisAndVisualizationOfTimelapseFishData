# this script takes the conditions for loading on a plate of an arbitrary size
# and creates a randomized loading scheme and a file for linking the wells back to the condition in the processin part
library(condformat)

#------------------change these variables------------------------------
## set the working directory
setwd("C:/Users/Colin Schaefer/HeiBox/Seafile/Method Paper/code/curated/random loading scheme")
## which conditions are loaded into the plate?
conditions = c("eGFP", "OleGFP", "SceGFP", "eGFPvar", "empty")
## the number of wells for the plate can be entered here:
rows = 8
columns = 12
## name of the experiment, which the random loading table should get
name = "test"

#------------------do not change anything from here on-----------------

### the number of wells needed
wells = rows * columns
### creating a vector for all wells
fullconditions = rep(conditions, length.out = wells)
### taking a random order pick from all conditions
randomwells = sample(fullconditions)
### distributing the vector to a table, matching the plate
matrix = matrix(as.character(randomwells), nrow = rows, ncol = columns)
matrix = as.data.frame(matrix)
rownames(matrix) = LETTERS[1:rows]
colnames(matrix) = 1:columns
matrix = cbind(matrix, rownames = rownames(matrix))

### combining the matrix with all the conditions to trick it into showing the same colors per condition
condmatrix = (data.frame(matrix(conditions, nrow = length(conditions), ncol = columns + 1)))
colnames(condmatrix) = colnames(matrix)
matrix = rbind(condmatrix,matrix)

### color-coding table depending on the number of columns and save it as this version and as .csv
command_condformat = "condmatrix = condformat(matrix)"
for (i in 1:columns) {
  command_condformat = paste(command_condformat, " %>% rule_fill_discrete(", i, ")", sep = "")
}
eval(parse(text=command_condformat))

## add row and column identifiers to the .csv file
randomwellswells = cbind(randomwells, row = LETTERS[1:rows], column = rep(1:columns, each = rows))

## save as .csv
write.csv(randomwellswells, file = paste(name, ".csv", sep = ""))

## save as .xlsx
condformat2excel(condmatrix, filename = name, sheet_name = "Sheet1", overwrite_wb = TRUE,
                 overwrite_sheet = TRUE)