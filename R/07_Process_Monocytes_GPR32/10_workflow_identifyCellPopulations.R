try(source("R/01_functions.R"))
try(source("R/00_datasets.R"))

loadlibraries()

#clusterName <- clusterColumns[1]

directoryName <- "gpr32Monocytes"
columnNames <- gpr32MonocytesClusteringColumnNames

cutoff <- gpr32MonocytesCutoff

markersOrCells <- c("CellPopulations", "Markers")

df <-
  fread(file=paste0(
    "data/",
    directoryName,
    "/clusteringOutput/clusteringOutputs.csv"
  ))
df <- as.data.frame(df)

for (markersOrCell in markersOrCells) {
  for (clusterColumn in clusterColumns) {
    calculateClusterMarkers(df, directoryName, clusterColumn, columnNames, cutoff, markersOrCell)
  }
}
