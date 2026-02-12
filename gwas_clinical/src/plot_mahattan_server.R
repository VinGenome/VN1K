args = commandArgs(trailingOnly=TRUE)
RUNDIR <- args[1]
trait <- args[2]
OUTDIR <- args[3]

setwd(RUNDIR)

library(tidyverse)
library(qqman)
library(ggplot2)


alt_gwas = read.csv(paste0(RUNDIR, "/", "clinical_prune.", trait, ".assoc.linear.tsv"), sep="\t")
alt_gwas %>%
  filter(-log10(P)>1) -> alt_gwas_filter

pdf(paste0(OUTDIR, "/", trait, ".pdf"), width=10, height=7)
manhattan(alt_gwas_filter, chr="CHR", bp="BP", snp="SNP", p="P", 
          suggestiveline = FALSE,
          genomewideline = -log10(4e-08),
          col = c("blue4","orange3"),
          annotatePval = 0.01,
          main = trait)
dev.off()
# ggsave(paste0(OUTDIR, "/", trait, ".pdf"), width=10, height=7, unit="in", dpi=300)