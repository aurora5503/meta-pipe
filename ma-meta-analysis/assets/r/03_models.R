library(meta)
library(metafor)

# Expect objects cont_es or bin_es from 02_effect_sizes.R

if (exists("cont_es")) {
  cont_model <- metagen(
    TE = cont_es$yi,
    seTE = sqrt(cont_es$vi),
    studlab = cont_es$slab,
    sm = "SMD",
    method.tau = "REML"
  )
}

if (exists("bin_es")) {
  bin_model <- metagen(
    TE = bin_es$yi,
    seTE = sqrt(bin_es$vi),
    studlab = bin_es$slab,
    sm = "RR",
    method.tau = "REML"
  )
}

# Example metafor model
if (exists("cont_es")) {
  cont_rma <- rma(yi = cont_es$yi, vi = cont_es$vi, method = "REML")
}
