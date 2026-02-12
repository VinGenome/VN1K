#!/usr/bin/env Rscript
#
library(data.table)
library(tidyverse)
library(foreach)
library(doParallel)
library(ggpubr)
library(grid)
library(gridExtra)
library(scales)
#
#### import dosage ####
# PID
INPUT="output/HGDP-vn94.chr20_QC1.vcf.gz"
QUERY="source ~/.bashrc ; bcftools query -l"
CMD=paste(QUERY, INPUT) # colnames
vt0 <- fread(cmd=CMD, header=FALSE, col.names="PID") %>% unlist()
# read all imputed file in a list of data frame
registerDoParallel(8)
#
vt1 <-list.files("output/", pattern="HGDP.*gz") %>% paste0("output/", .)
ldf <- foreach (i=vt1) %dopar% {
  INPUT=i
  QUERY="source ~/.bashrc ; bcftools query -T output/masked.snps.list -f '%CHROM:%POS:%REF:%ALT[\t%GT]\n'"
  CMD=paste(QUERY, INPUT)
  y <- fread(cmd=CMD, header=FALSE, sep="\t",
             col.names=c("ID", vt0))
  return(y)
}
# create intersection of ID from all df
ldf2 <- lapply(ldf, function(x) {
  x[,"ID"] %>% unlist()
})
Reduce(intersect, ldf2) -> vt2

# convert matrix to 0-1-2 genotype, expecting NA value in true genotype matrix
ldf2 <- lapply(ldf, function(x){
  # x is data frame from ldf
  # subset to intersection of variant ID
  # remove ID column
  y <- filter(x, ID %in% vt2) %>%
    select(-1) %>% as.matrix()
  # fill z with condition from y
  y[y=="0/0" | y=="0|0"] <- "0"
  y[y=="0/1" | y=="0|1"] <- "1"
  y[y=="1/0" | y=="1|0"] <- "1"
  y[y=="1/1" | y=="1|1"] <- "2"
  # convert value to numeric
  z <- as_tibble(y) %>%
    mutate_all(as.numeric) %>%
    as.matrix()
  #
  return(z)
})
# rename list element
vt3 <- gsub(".*impute\\.(.+)\\.dose.*", "\\1", x=vt1)
vt3[length(vt3)] <- "true"
names(ldf2) <- vt3
# calculate error rate
true <- ldf2[[6]]
ldf2[[6]] <- NULL

#### split ldf2 into subset of population ####
# read info from excel file
INPUT="/Users/hung/Data/HGDP/hgdp_stanford/HGDPid_populations.xls"
df0 <- readxl::read_excel(INPUT, range = "A1:F1065")
#
data.frame("Id"=vt0[grepl("VN", vt0)], "Sex"=NA,
           "population"="Kinh","Geographic_origin"="Vietnam",
           "Region"="Asia","Pop7Groups"="Est_Asia") %>%
  bind_rows(.,df0) -> df.pops
#
df0 %>%
  select(3:6) %>% distinct() %>%
  filter(Region=="Asia")-> df1
# filter asian population
df1 <- df.pops %>%
  filter(Id %in% vt0) %>% # subset with available sample in vcf
  filter(Region=="Asia") %>% # subset asian 
  select(1,3) %>%
  mutate_at(2, as.factor)


#### parallel main function ####
registerDoParallel(4)
foreach (i=levels(df1$population),
         .combine=rbind,
         .packages="tidyverse") %dopar% {
  # subset column based on population in df1
  print(i)
  # get sample ID from df1
  samples <- df1 %>%
    filter(population==i) %>%
    select(1) %>%
    unlist()
  # return(c(i, length(samples)))
  # subset from ldf2 and true
  mat0 <- true[, samples]
  lmat <- lapply(ldf2, function(x) {
    # x is matrix element of ldf2 list
    x[, samples]
  })
  # compute error rate
  output <- sapply(lmat, function(x) {
    # x is matrix from ldf2
    sum(!x==mat0, na.rm=TRUE)
  })
  #
  return(c(i, output))
} -> df.output
# format df.output for plotting
dfplot <- as_tibble(df.output) %>%
  rename(population="V1") %>%
  mutate(across(!1, as.numeric))
# add size of each population
dfplot <- df1 %>% group_by(population) %>% summarise(size=length(population)) %>%
  left_join(dfplot, . , by="population")
# annotate result with continent and region
dfplot <- df.pops %>% select(3:6) %>%
  rename("country"="Geographic_origin", "continent"="Region", "region"="Pop7Groups") %>%
  distinct() %>%
  left_join(dfplot, ., by="population")


# # mutate the number of error genotype to error rate
# dfplot %>%
#   mutate(`1KGP3`= `1KGP3` / (size*length(variants)) *100) %>%
#   mutate(VN404= VN404 / (size*length(variants)) *100) %>%
#   mutate(merge= merge / (size*length(variants)) *100) %>%
#   mutate(SG10K= SG10K / (size*length(variants)) *100) -> dfplot
# edit region for plotting
dfplot %>%
  mutate_at("region", ~gsub("Est_Asia","East_Asia", .)) %>%
  mutate_at("region", ~gsub("_", " ", .)) -> dfplot
# mutate to get log2 number
dfplot <- dfplot %>%
  mutate(`log2(test920/1KGP3)`= log2(test920/`1KGP3`),
         `log2(merge-1KGP3-test920/1KGP3)` = log2(`merge-1KGP3-test920`/`1KGP3`),
         `log2(merge-reciprocal/1KGP3)` = log2(`merge-reciprocal`/`1KGP3`),
         `log2(SG10K/1KGP3)` = log2(SG10K/`1KGP3`))
# create sorting order
dfplot %>%
  arrange(desc(region), country, population) %>%
  select("population") %>% unlist() -> pop_order
# try horizontal bar plot
colour_pattern <- c(rep("white",4), rep("gray95",4)) %>% rep(., 13) %>% c(. , rep("white",4))
colour_theme <- hue_pal()(5)[2:5]
dfplot %>%
  pivot_longer(cols=starts_with("log2"), names_to="Benchmarks", values_to="value") -> dfplot1
dfplot1$pop <- factor(dfplot1$population, levels=pop_order) # manual sorting levels for plot
dfplot1 <- arrange(dfplot1, desc(region), country, population) # value sorting for colour order
dfplot1$colour <- colour_pattern # insert colour pattern
p2 <- ggplot(data=dfplot1, aes(fill=Benchmarks, x=pop, y=value)) +
  geom_vline(aes(xintercept=pop, colour=colour), size=8) +
  geom_bar(position="dodge", stat="identity") +
  scale_fill_manual(values=c("log2(merge-1KGP3-test920/1KGP3)"=colour_theme[1],
                             "log2(merge-reciprocal/1KGP3)"=colour_theme[2],
                             "log2(SG10K/1KGP3)"=colour_theme[3],
                             "log2(test920/1KGP3)"=colour_theme[4])) +
  labs(y="log2(Imputation Error rate compare to 1KGP)") +
  scale_colour_identity() +
  coord_flip() +
  theme_classic() +
  theme(axis.text.y = element_blank(), axis.title.y = element_blank(),
        legend.position=c(1,1), legend.justification=c(1,0), legend.direction="horizontal",
        plot.margin=margin(50,0,0,0)) +
  guides(fill=guide_legend(nrow=2, byrow=TRUE))

# plot table
dfplot %>%
  select(c("region", "country","population")) %>%
  mutate_at("region", ~gsub("_", " ", .)) %>%
  arrange(desc(region), country, population) %>%
  mutate(colour=c(rep(c("white", "gray95"), 13), "white")) -> dfplot2
dfplot2$population <- factor(dfplot2$population, levels=pop_order) # manual sorting levels
p1 <- ggplot(data=dfplot2, aes(y=population)) +
  geom_hline(aes(yintercept=population, colour=colour), size=8) +
  geom_text(aes(x="Region", label=region), size=2, hjust=0.5) +
  geom_text(aes(x="Country", label=country), size=2, hjust=1) +
  geom_text(aes(x="Ethnicity", label=population), size=2, hjust=1) +
  scale_colour_identity() +
  scale_x_discrete(limits=c("Region", "Country", "Ethnicity")) +
  theme_classic() +
  theme(plot.margin=margin(50,-40,13,0), axis.line.y=element_blank(),
        axis.text.y = element_blank(), axis.ticks.y = element_blank(),
        axis.title.y = element_blank(), axis.title.x = element_blank(),
        axis.ticks.x=element_blank(), axis.text.x= element_text(hjust=1))
p12 <- ggarrange(p1, p2, ncol=2, labels="A", widths=c(2,2))
# save Rdata
OUTPUT="output/branch-hgdp-p12.Rdata"
save(list=ls(pattern="^p\\d+"), file=OUTPUT)
#
OUTPUT="output/plot-table/error-rate-hgdp-v2.png"
ggsave(filename=OUTPUT, plot=p12,
       device="png", units="in", width=6, height=6)
#
rm(list=ls())

# load only 
load("output/branch-hgdp-p12.Rdata")
load("output/branch-hgdp-p34.Rdata")
#
p12 <- ggarrange(p1, p2, ncol=2, labels="A", widths=c(2,2))
# import figure
p34 <- ggarrange(p3,p4,ncol=1,nrow=2, labels=c("B","C"))
p34 <- annotate_figure(p34, bottom=text_grob("Minor allele frequency groups"))

# combine figure
p_main <- ggarrange(p12, p34, ncol=2, nrow=1, widths = c(3,2))
OUTPUT="output/plot-table/main-figure.png"
ggsave(OUTPUT, plot=p_main, width=10, height=6, units="in", dpi=300)

