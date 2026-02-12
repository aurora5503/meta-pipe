library(meta)
library(metafor)

# ---------------------------------------------------------------------------
# Publication bias assessment with funnel plots on log scale + Egger's test
#
# Why log scale? For ratio measures (HR, RR, OR), the funnel plot's confidence
# region is only symmetric on the log scale. On the natural scale, the shading
# is skewed, making visual assessment of asymmetry misleading.
#
# backtransf = FALSE  -> x-axis shows log(HR), log(RR), or log(OR)
# studlab = TRUE      -> label points with study names
# ---------------------------------------------------------------------------

# --- Continuous outcomes (SMD, MD) ---
if (exists("cont_model")) {
  cont_bias <- metabias(cont_model, method.bias = "linreg")

  # Funnel plot (continuous outcomes are already on linear scale, no log needed)
  png("figures/funnel_continuous_bias.png",
      width = 7, height = 6, units = "in", res = 300)
  funnel(cont_model,
         studlab = TRUE, cex.studlab = 0.8,
         xlab = cont_model$sm,
         col = "navy", pch = 16)
  title(sub = sprintf("Egger's test: t = %.2f, p = %.3f",
                       cont_bias$statistic, cont_bias$p.value),
        cex.sub = 0.9, col.sub = "gray40")
  dev.off()

  # Contour-enhanced funnel
  png("figures/funnel_continuous_contour.png",
      width = 7, height = 6, units = "in", res = 300)
  funnel(cont_model,
         contour.levels = c(0.90, 0.95, 0.99),
         col.contour = c("gray90", "gray75", "gray60"),
         studlab = TRUE, cex.studlab = 0.8,
         xlab = cont_model$sm,
         col = "navy", pch = 16)
  legend("topright",
         c("p > 0.10", "0.05 < p < 0.10", "0.01 < p < 0.05", "p < 0.01"),
         fill = c("white", "gray90", "gray75", "gray60"),
         bty = "n", cex = 0.7)
  dev.off()
}

# --- Binary / ratio outcomes (RR, OR, HR) ---
if (exists("bin_model")) {
  # Peters' test preferred for binary outcomes (lower false-positive rate)
  bin_bias <- metabias(bin_model, method.bias = "linreg")

  # Funnel plot on LOG scale -> symmetric confidence region
  png("figures/funnel_binary_bias.png",
      width = 7, height = 6, units = "in", res = 300)
  funnel(bin_model, backtransf = FALSE,
         studlab = TRUE, cex.studlab = 0.8,
         xlab = paste0("Log ", bin_model$sm),
         col = "navy", pch = 16)
  title(sub = sprintf("Egger's test: t = %.2f, p = %.3f",
                       bin_bias$statistic, bin_bias$p.value),
        cex.sub = 0.9, col.sub = "gray40")
  dev.off()

  # Contour-enhanced funnel on log scale
  png("figures/funnel_binary_contour.png",
      width = 7, height = 6, units = "in", res = 300)
  funnel(bin_model, backtransf = FALSE,
         contour.levels = c(0.90, 0.95, 0.99),
         col.contour = c("gray90", "gray75", "gray60"),
         studlab = TRUE, cex.studlab = 0.8,
         xlab = paste0("Log ", bin_model$sm),
         col = "navy", pch = 16)
  legend("topright",
         c("p > 0.10", "0.05 < p < 0.10", "0.01 < p < 0.05", "p < 0.01"),
         fill = c("white", "gray90", "gray75", "gray60"),
         bty = "n", cex = 0.7)
  dev.off()
}

# --- metafor models ---
if (exists("cont_rma")) {
  cont_regtest <- regtest(cont_rma, model = "rma")
}
