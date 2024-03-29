try(source("R/01_functions.R"))
try(source("R/00_datasets.R"))

loadlibraries()

clusterNames <- clusterColumns

markersOrCells <- markersOrCellsClassification
figureNames <-
  c(#"DifferentialStatesStatisticscsv"#,
    "DifferentialAbundanceStatisticscsv"
    )

markersOrCells <- markersOrCells[3]
clusterNames <- clusterNames[3]

directoryNames <- c(#"BCells"#,
                    #"Monocytes"#,
                    #"Senescence"#,
                    "TCells"
                    )

# clusterName <- clusterNames[1]
# markersOrCell <- markersOrCells[1]
# figureName <- figureNames[1]

for (clusterName in clusterNames) {
  for (markersOrCell in markersOrCells) {
    for (figureName in figureNames) {
      message(clusterName)
      message(markersOrCell)
      message(figureName)

      combinedDf <-
        fread(
          paste0(
            "data/pValueAdjustmentsResults/",
            clusterName,
            markersOrCell,
            figureName,
            ".csv"
          )
        )
      combinedDf <- as.data.frame(combinedDf)

      colnames(combinedDf) <-
        gsub(" ", "", colnames(combinedDf), fixed = TRUE)
      colnames(combinedDf) <-
        gsub("-", "", colnames(combinedDf), fixed = TRUE)
      colnames(combinedDf) <-
        gsub("(", "", colnames(combinedDf), fixed = TRUE)
      colnames(combinedDf) <-
        gsub(")", "", colnames(combinedDf), fixed = TRUE)
      colnames(combinedDf)

      #combinedDf$CellPopulationName <- gsub(" CD11b\\+", " CD11b+\n", combinedDf$CellPopulationName)
      # combinedDf$CellPopulationName <- gsub("\\(", "\n\\(", combinedDf$CellPopulationName)

      combinedDf[combinedDf$JaccardSimilarityCoefficient < 0.65, "jaccard"] <-
        "Low"
      combinedDf[combinedDf$JaccardSimilarityCoefficient > 0.65, "jaccard"] <-
        "Moderate"
      combinedDf[combinedDf$JaccardSimilarityCoefficient > 0.75, "jaccard"] <-
        "High"
      combinedDf[combinedDf$JaccardSimilarityCoefficient > 0.85, "jaccard"] <-
        "Very High"

      combinedDf[combinedDf$jaccard == "Low", "shape"] <- 18
      combinedDf[combinedDf$jaccard == "Moderate", "shape"] <- 16
      combinedDf[combinedDf$jaccard == "High", "shape"] <- 15
      combinedDf[combinedDf$jaccard == "Very High", "shape"] <- 17

      combinedDf$Panel <- factor(combinedDf$Panel)
      combinedDf <-
        combinedDf[order(combinedDf$JaccardSimilarityCoefficient), ]
      combinedDf$jaccard <-
        factor(combinedDf$jaccard,
               levels = c("Very High", "High", "Moderate", "Low"))
      combinedDf <-
        combinedDf[order(combinedDf$CellPopulationName), ]
      combinedDf <- combinedDf[order(gsub("[0123456789]", "", gsub("gpr", "", combinedDf$Panel, fixed = TRUE))), ]

      combinedDf$CellPopulationName <-
        factor(combinedDf$CellPopulationName,
               levels =  unique(combinedDf$CellPopulationName))
      # marker <- unique(combinedDf$Marker)[1]

      for (marker in unique(combinedDf$Marker)) {
        try({
        message(marker)
        combinedDf2 <- combinedDf[combinedDf$Marker == marker,]

        combinedDf2 <- combinedDf[combinedDf$Panel %in% paste0(tolower(marker), directoryNames),]

        # combinedDf2 <-
        #   combinedDf2[combinedDf2$CellPopulationName %in% combinedDf2[combinedDf2$FDRAdjustedPValue <
        #                                                              0.05, "CellPopulationName"],]
        # combinedDf2 <-
        #   combinedDf2[combinedDf2$ID %in% combinedDf2[combinedDf2$FDRAdjustedPValue <
        #                                              0.05, "ID"],]
        combinedDf2 <-
          combinedDf2[combinedDf2$Comparison %in% combinedDf2[combinedDf2$FDRAdjustedPValue <
                                                             0.05, "Comparison"],]

        fig <-
          ggplot(
            combinedDf2,
            aes(
              x = as.factor(CellPopulationName),
              y = MinusLogFDRAdjustedPValue,
              color = LogFoldChange,
              shape = jaccard
            )
          ) +
          geom_point(alpha = 0.75, size = 5) +
          scale_shape_manual(values = c("Very High" = 17, "High" = 15, "Moderate" = 16, "Low" = 18)) +
          facet_wrap(~ Comparison) +
          guides(color = guide_colourbar(title = "log2(Fold Change)", order = 1)) +
          theme(axis.text.x = element_text(
            angle = 90,
            vjust = 0.5,
            hjust = 1,
            size = 8
          )) +
          xlab("Cell Populations") +
          ylab("-log10(Adjusted P-Value)") +
          ylim(0, NA) + guides(shape = guide_legend(title = "Stability")) +
          geom_hline(yintercept = 0 - log10(0.05),
                     linetype = "dashed") +
          scale_colour_viridis_c()

        print(fig)
        })
      }
      rm(combinedDf)
      message("")
    }
  }
}
