setwd("/home/namnn12/project/1KVG_imputation/")
library(tidyverse)
library(dplyr)
library(ggplot2)

hla_impute_acc <- read.table('HLA_impute_statistic.csv', header = TRUE, sep=",", stringsAsFactors = TRUE)
hla_impute_acc_apmra96 <- filter(hla_impute_acc, array.name=="APMRA96")

plot_data <- reshape::melt(hla_impute_acc_apmra96, id=c("HLA_type","array.name")) %>% 
  filter(variable!="KHV99") %>%
  mutate(variable = factor(variable, levels=c("IGSR_2504","X1KVG","VN_1008_1KGP"))) %>%
  arrange(variable)
  

hla_plot <- ggplot(data=plot_data, aes(x=HLA_type, y=value, fill=variable)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  scale_fill_manual(breaks = c("X1KVG", "IGSR_2504", "VN_1008_1KGP"), 
                    values=c( "#00BF7D","#F8766D","#00B0F6"),
                    labels=c("VN915","1kGP_HC","VN915_1kGP_HC"),
                    name = "Reference Panel") +
  xlab("Gene") + ylab("HLA imputation accuracy") +
  # ylim(0,1.2) +
  theme_classic() +
  theme(
    axis.text.x = element_text(angle=-15),
    # legend.position=c(0.9, 0.9),
    legend.position = 'none',
    # legend.justification=c(1, 0),
    legend.key.size=unit(0.15, "in")
    )
hla_plot

