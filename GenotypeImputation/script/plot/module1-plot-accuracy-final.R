setwd("/media/namnn12/c8dd9b23-05cc-4a61-a5b1-b70e0a8654ea/project/plot_code/1KVG_imputation")
#!/usr/bin/env Rscript
#
library(data.table)
library(tidyverse)
library(ggpubr)
#
source("script/plot/function.test_accuracy.R")
source("script/plot/function.plot_accuracy.R")
source("script/plot/function.plot_hqvariants.R")
#
#### import dosage ####
#### test ####
# # list output files
# vt.file <-list.files("output/", pattern="apmra.*gz") %>% paste0("output/", .)
# # read PID
# INPUT=vt.file[1]
# QUERY="source ~/.bashrc ; bcftools query -l"
# vt.pid <- system(paste(QUERY, INPUT), intern=TRUE)
# # read dosage as list of dataframe
# ls.ds <- foreach (i=vt.file) %dopar% {
#   INPUT=i
#   QUERY="source ~/.bashrc ; bcftools query -i 'INFO/IMPUTED=1' -f '%CHROM:%POS:%REF:%ALT[\t%DS]\n'"
#   CMD=paste(QUERY, INPUT)
#   y <- fread(cmd=CMD, header=FALSE, sep="\t",
#              col.names=c("ID", vt.pid))
#   return(y)
# }
# # read genotype of sequencing cnss1014
# INPUT="data/cnss1014.chr20_lite.vcf.gz"
# QUERY="source ~/.bashrc ; bcftools query -S temp/list-kinh94.txt -f '%CHROM:%POS:%REF:%ALT[\t%GT]\n'"
# COMMAND=paste(QUERY, INPUT)
# gt.vn94 <- fread(cmd=COMMAND, sep="\t", header=FALSE,
#                  col.names = c("ID", vt.pid))
# #

#### end test ####


# PID
INPUT="APMRA96.chr20.CCDG_14151_B01_GRM_WGS_2020-08-05_chr20.Total.QC.dose.vcf.gz"
QUERY1="source ~/.bashrc ; bcftools query -l"
COMMAND1=paste(QUERY1, INPUT) # colnames
df1 <- fread(cmd=COMMAND1, header=FALSE, col.names="PID")


# 1kgp
INPUT="APMRA96.chr20.CCDG_14151_B01_GRM_WGS_2020-08-05_chr20.Total.QC.dose.vcf.gz"
QUERY2="source ~/.bashrc ; bcftools query -i 'INFO/IMPUTED=1' -f '%CHROM:%POS:%REF:%ALT[\t%DS]\n'"
COMMAND2=paste(QUERY2, INPUT) # dosage
ds.1KGP <- fread(cmd=COMMAND2, sep="\t", header=FALSE,
             col.names = c("ID", df1$PID))
# 1kgp
INPUT="APMRA96.chr20.merge-1KGP3-vn916.chr20_forimpute.dose.vcf.gz"
QUERY2="source ~/.bashrc ; bcftools query -i 'INFO/IMPUTED=1' -f '%CHROM:%POS:%REF:%ALT[\t%DS]\n'"
COMMAND2=paste(QUERY2, INPUT) # dosage
ds.VN915_1KGP <- fread(cmd=COMMAND2, sep="\t", header=FALSE,
             col.names = c("ID", df1$PID))
# vn914
INPUT="APMRA96.chr20.merge-SG10K-vn916.chr20_forimpute.dose.vcf.gz"
QUERY2="source ~/.bashrc ; bcftools query -i 'INFO/IMPUTED=1' -f '%CHROM:%POS:%REF:%ALT[\t%DS]\n'"
COMMAND2=paste(QUERY2, INPUT) # dosage
ds.VN915_SG10K <- fread(cmd=COMMAND2, sep="\t", header=FALSE,
             col.names = c("ID", df1$PID))
# merge
INPUT="APMRA96.chr20.SG10K.chr20.hg38_QC2.QC.dose.vcf.gz"
QUERY2="source ~/.bashrc ; bcftools query -i 'INFO/IMPUTED=1' -f '%CHROM:%POS:%REF:%ALT[\t%DS]\n'"
COMMAND2=paste(QUERY2, INPUT) # dosage
ds.SG10K <- fread(cmd=COMMAND2, sep="\t", header=FALSE,
             col.names = c("ID", df1$PID))
# SG10K
INPUT="APMRA96.chr20.VN_916.HaplotypeData.chr20.QC.dose.vcf.gz"
QUERY2="source ~/.bashrc ; bcftools query -i 'INFO/IMPUTED=1' -f '%CHROM:%POS:%REF:%ALT[\t%DS]\n'"
COMMAND2=paste(QUERY2, INPUT) # dosage
ds.VN915 <- fread(cmd=COMMAND2, sep="\t", header=FALSE,
                  col.names = c("ID", df1$PID))
# true
INPUT="Ref/VN_1011.HaplotypeData.chr20.vcf.gz"
fwrite(df1, file="samples_list.txt", quote=FALSE, col.names=FALSE)
QUERY="source ~/.bashrc ; bcftools query -S samples_list.txt -f '%CHROM:%POS:%REF:%ALT[\t%GT]\n'"
COMMAND=paste(QUERY, INPUT)
gt.vn94 <- fread(cmd=COMMAND, sep="\t", header=FALSE,
                 col.names = c("ID", df1$PID))
# convert matrix
mat <- as.matrix(gt.vn94)
mat[mat == "0|0"] <- 0
mat[mat == "0|1" | mat == "1|0"] <- 1
mat[mat == "1|1"] <- 2
mat <- as_tibble(mat) %>%
  mutate(across(matches("VN"), as.numeric))

#### import MAF from 1KGP3 ####
MAF_1KGP3 <- fread(file="MAF_20.txt", sep="\t", header=TRUE)
MAF_1KGP3 %>%
  # cbind(cut(MAF_1KGP3$MAF,c(1e-4,1e-3,5e-3,1e-2,5e-2,0.2,0.5))) %>%
  cbind(cut(MAF_1KGP3$MAF,c(0,1e-3,1e-2,0.05,0.1,0.5))) %>%
  as_tibble() -> MAF_1KGP3
colnames(MAF_1KGP3)[3] <- "MAF_group"

#### intersected sites between datasets ####
# create identical intersected sites
# 286698
Reduce(intersect,list(ds.VN915_1KGP$ID, ds.VN915_SG10K$ID, ds.SG10K$ID, ds.VN915$ID, ds.1KGP$ID,gt.vn94$ID)) -> m
#Reduce(intersect,list(ds.1kgp$ID, ds.vn920$ID, ds.sg10k$ID, gt.vn94$ID)) -> m
#### test accuracy ####
r2_VN915_1kGP_HC <- test_accuracy(mat, ds.VN915_1KGP, MAF_1KGP3)
r2_VN915_SG10K <- test_accuracy(mat, ds.VN915_SG10K, MAF_1KGP3)
r2_SG10K <- test_accuracy(mat, ds.SG10K, MAF_1KGP3)
r2_1kGP_HC <- test_accuracy(mat, ds.1KGP, MAF_1KGP3)
r2_VN915 <- test_accuracy(mat, ds.VN915, MAF_1KGP3)


### print ###
print(r2_VN915_1kGP_HC)
print(r2_VN915_SG10K)
print(r2_SG10K)
print(r2_1kGP_HC)
print(r2_VN915)

#### plot accuracy ####
p3 <- plot_accuracy(x=ls(pattern="r2_"), output="images/accuracy_5-ref-panel-replot.pdf")
# OUTPUT="output/plot-table/accuracy_5-ref-panel.png"
# ggsave(filename=OUTPUT, plot=p3,units="in", width=6, height=4, dpi=300)
# ggsave(filename="accuracy0.png", plot=p1, units="in", width=6, height=8, dpi=300)



#### import rsq ####
# 1KGP3
rsq_1kGP_HC <- fread(file="APMRA96.chr20.CCDG_14151_B01_GRM_WGS_2020-08-05_chr20.Total.QC.info", sep="\t", header = TRUE) %>%
  select(c(1,7,8)) %>% mutate(across(Genotyped, as.factor))
# test920
rsq_VN915 <- fread(file="APMRA96.chr20.VN_916.HaplotypeData.chr20.QC.info", sep="\t", header = TRUE) %>%
  select(c(1,7,8)) %>% mutate(across(Genotyped, as.factor))
# merge
rsq_VN915_1kGP_HC <- fread(file="APMRA96.chr20.merge-1KGP3-vn916.chr20_forimpute.info", sep="\t", header = TRUE) %>%
  select(c(1,7,8)) %>% mutate(across(Genotyped, as.factor))
# SG10K
rsq_SG10K <- fread(file="APMRA96.chr20.SG10K.chr20.hg38_QC2.QC.info", sep="\t") %>%
  select(c(1,7,8)) %>% mutate(across(Genotyped, as.factor))

rsq_VN915_SG10K <- fread(file="APMRA96.chr20.merge-SG10K-vn916.chr20_forimpute.info", sep="\t") %>%
  select(c(1,7,8)) %>% mutate(across(Genotyped, as.factor))

#### plot high quality imputed variants ####
p4 <- plot_hqvariants(x=ls(pattern="rsq_"), output='images/high-quality-variants_5-ref-panel.pdf')
# OUTPUT="output/plot-table"
# ggsave(filename=OUTPUT, plot=p4, units="in", width=6, height=4, dpi=300)

# #
# save(list=ls(pattern="^p\\d+"), file="branch-hgdp-p34.Rdata")

