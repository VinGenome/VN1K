setwd("/home/namnn12/project/1KVG_imputation/")

library(ggplot2)
library(stringr)
library(tidyverse)
library(ggpubr)

### load data info
pop_data <- read.csv("igsr_population_info.txt", sep = "\t")
pop_data <- pop_data[c("Population.name", "Population.description", "Superpopulation.name")]
colnames(pop_data) <- c("population", "country", "region")
pop_data$region <- gsub(' \\(HGDP\\)','',pop_data$region)
pop_data$country <- gsub(' \\(HGDP\\)', '', pop_data$country)
pop_data$country <- str_split_fixed(pop_data$country, " in ", 2)[,2]

## error ratio data
data <- read.csv("dict_acc/output_population_rmKHV.csv")
colnames(data) <- c("idx","population",
                    "KGP_HC", "m_KGP_HC_vn916", "m_SG10K_vn916",
                    "SG10K", "vn916", "KGP_HC_rmKHV", "m_KGP_HC_vn916_rmKHV")

data$log_m_kgp <- log2((1-data$m_KGP_HC_vn916_rmKHV )/ (1-data$KGP_HC_rmKHV))
data$log_m_sg10k <- log2((1-data$m_SG10K_vn916) / (1-data$KGP_HC_rmKHV))
data$log_sg10k <- log2((1-data$SG10K) / (1- data$KGP_HC_rmKHV))
data$log_vn916 <- log2((1-data$vn916) / (1- data$KGP_HC_rmKHV))


melt_data <- reshape::melt(data[c("population",
                                  "log_m_kgp",
                                  "log_m_sg10k",
                                  "log_sg10k", 
                                  "log_vn916")], id=c("population"))

merge_data <- merge(melt_data, pop_data, by="population")

### plot2
pop_order <- merge_data %>%
  arrange(desc(region), country, population) %>%
  select("population") %>% unique() %>% unlist()
merge_data$population <- factor(merge_data$population, levels=pop_order) # manual sorting levels for plot
merge_data <- arrange(merge_data, desc(region), country, population) # value sorting for colour order
merge_data$row_color <- c(rep("white",4), rep("gray85",4)) %>% rep(., 13) %>% c(. , rep("white",4)) # insert colour pattern

p2 <- ggplot(merge_data, aes(x=value, y=population, fill=variable)) +
  geom_hline(aes(yintercept = population, colour=row_color), size=6) +
  geom_bar(position="dodge", stat='identity') +
  scale_fill_manual(breaks = c("log_sg10k", "log_vn916", "log_m_kgp", "log_m_sg10k"), 
                    values=c( "#A3A500","#00BF7D","#00B0F6","#E76BF3"),
                    labels=c("log2(SG10K/1kGP_HC)",
                             "log2(VN915/1kGP_HC)",
                             "log2(VN915_1kGP_HC/1kGP_HC)",
                             "log2(VN915_SG10K/1kGP_HC)"),
                    name = "Benchmarks") +
  scale_colour_identity() +
  labs(x="log2(Imputation Error rate 
       compare to 1kGP high coverage)", x="") +
  theme_classic() +
  theme(axis.text.y = element_blank(), axis.title.y = element_blank(),
        legend.position=c(1,1), legend.justification=c(1,0), legend.direction="horizontal",
        plot.margin=margin(50,0,0,0)) +
  guides(fill=guide_legend(nrow=2, byrow=TRUE))
p2
### plot1 
dfplot1 <- merge_data %>%
  arrange(desc(region), country, population) %>%
  select("population", "region", "country") %>% unique()
dfplot1$row_color <- c(rep("white",1), rep("gray85",1)) %>% rep(., 13) %>% c(. , rep("white",1))

p1 <- ggplot(data=dfplot1, aes(y=population)) +
  geom_hline(aes(yintercept=population, colour=row_color), size=6) +
  geom_text(aes(x="Region", label=region), size=2, hjust=0.5) +
  geom_text(aes(x="Country", label=country), size=2, hjust=1) +
  geom_text(aes(x="Ethnicity", label=population), size=2, hjust=1) +
  scale_colour_identity() +
  scale_x_discrete(limits=c("Region", "Country", "Ethnicity")) +
  theme_classic() +
  theme(plot.margin=margin(50,-40,25,0), axis.line.y=element_blank(),
        axis.text.y = element_blank(), axis.ticks.y = element_blank(),
        axis.title.y = element_blank(), axis.title.x = element_blank(),
        axis.ticks.x=element_blank(), axis.text.x= element_text(hjust=1))

### merge 2 plot
p12 <- ggarrange(p1, p2, ncol=2, labels="a", widths=c(2,2))
p12
ggsave(filename="images/error_rate_plot.pdf", plot=p12,
       device="pdf", units="in", width=10, height=6)
p3
p4
p34 <- ggarrange(p3,p4,ncol=1,nrow=2, labels=c("b","c"))
p34 <- annotate_figure(p34, bottom=text_grob("Minor allele frequency groups"))
p_main <- ggarrange(p12, p34, ncol=2, nrow=1, widths = c(3,2))
p_main
ggsave(filename="images/imputation.pdf", plot=p_main,
       device="pdf", units="in", width=10, height=6)

# figure 2
p12 <- ggarrange(p1, p2, ncol=2, widths=c(2,2))
fig1 <- ggarrange(
  p12, NULL, fst_plot, 
  nrow = 1, widths = c(3.5,0.1,1.5),
  labels=c("a", "", "b")
  )
fig1
ggsave(filename="images/p_imputation_sup.pdf", plot=fig1,
       device="pdf", units="in", width=10, height=6)
# figure 1
fig2 <- ggarrange(p3, p4, NULL, hla_plot, nrow=1, 
                  widths = c(1,1,0.1, 0.9),
                  labels=c("a","b","c"),
                  align = "h",
                  # common.legend = TRUE,
                  legend="bottom",
          legend.grob = get_legend(p4,  position="bottom"))
fig2
ggsave(filename="images/p_imputation.pdf", plot=fig2,
       device="pdf", units="in", width=10, height=3.5)

fig_all <- ggarrange(fig2, NULL, fig1, ncol=1,
                     heights = c(3,0.2,7))
fig_all
ggsave(filename="images/imputation_figure.pdf", plot=fig_all,
       device="pdf", units="in", width=10, height=9)

### note: load image to add to a plot
# library(png)
# library(grid)
# img <- readPNG("/home/namnn12/project/1KVG_imputation/images/HLA_impute.png")
# g <- rasterGrob(img, interpolate=TRUE)