## Everything to do with how results are *presented*: the packages the plotting
## and table scripts need, and the labels and colors they share so that a figure
## and the table beside it cannot disagree about what "naive" means.
##
## Nothing here affects a simulation, which is why the simulation rules do not
## list this file as an input -- changing a color should not cost you the grid.

suppressPackageStartupMessages({
  library(optparse)
  library(ggplot2)
})

method_labels <- c(
  "naive" = "Naive",
  "split" = "Sample splitting"
)

colors <- c("naive" = "#d95f02", "split" = "#1b9e77")
