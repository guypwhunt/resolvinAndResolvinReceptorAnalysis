try(source("R/01_functions.R"))
try(source("R/00_datasets.R"))

loadlibraries()

directoryName <- "gpr18BCells"
columnNames <- gpr18BCellsColumnNames

convertToDataFrame(directoryName, columnNames)
