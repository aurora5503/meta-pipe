library(meta)
library(ggplot2)

if (exists("cont_model")) {
  png("figures/forest_continuous.png", width = 2400, height = 1800, res = 300)
  forest(cont_model)
  dev.off()

  png("figures/funnel_continuous.png", width = 2000, height = 1800, res = 300)
  funnel(cont_model)
  dev.off()
}

if (exists("bin_model")) {
  png("figures/forest_binary.png", width = 2400, height = 1800, res = 300)
  forest(bin_model)
  dev.off()

  png("figures/funnel_binary.png", width = 2000, height = 1800, res = 300)
  funnel(bin_model)
  dev.off()
}
