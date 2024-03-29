try(source("R/01_functions.R"))
try(source("R/00_datasets.R"))

loadlibraries()

directoryName <- "gpr18Senescence"

df <- fread(file=paste0("./data/", directoryName, '/clusteringOutput/clusteringOutputs.csv'))
df <- as.data.frame(df)

df[, "meta_clusters_flowsom"] <- df[, "meta_clusters_flowsom19"]

write.csv(df, paste0("./data/", directoryName, '/clusteringOutput/clusteringOutputs.csv'), row.names = FALSE)
