library(meta)
library(metafor)

if (exists("cont_model")) {
  cont_bias <- metabias(cont_model, method.bias = "linreg")
}

if (exists("bin_model")) {
  bin_bias <- metabias(bin_model, method.bias = "linreg")
}

if (exists("cont_rma")) {
  cont_regtest <- regtest(cont_rma, model = "rma")
}
