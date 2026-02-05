library(meta)
library(metafor)

# Example: subgroup by study design
# cont_es must include a moderator column named design

if (exists("cont_es") && "design" %in% names(cont_es)) {
  cont_subgroup <- update.meta(cont_model, byvar = cont_es$design, comb.random = TRUE)
}

# Example meta-regression using metafor
# Replace moderator with a numeric variable
if (exists("cont_es") && "moderator" %in% names(cont_es)) {
  cont_reg <- rma(yi = cont_es$yi, vi = cont_es$vi, mods = ~ moderator, method = "REML")
}
