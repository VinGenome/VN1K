setwd("D:/Coding/Work_GX/KVG/gwas_clinical")

library(tidyverse)
library(ggplot2)
library(ggrepel)
library(qqman)
library(ggpubr)

# alt_gwas = read.csv("assoc_linear/ALT.assoc.linear.add.header.tsv", sep="\t")
# alt_gwas = read.csv("assoc_linear/clinical_prune.all_big.clumped.sample.tsv", sep="\t")
alt_gwas = read.csv("assoc_linear/mahattan.csv")
# alt_gwas %>%
#   filter(-log10(P)>5) -> alt_gwas

snpsOfInterest = c("rs189624401","rs148347134","rs765163972",
  "rs782819493","rs7412","rs542781445")

don <- alt_gwas %>% 
  # Compute chromosome size
  group_by(CHR) %>% 
  summarise(chr_len=max(BP)) %>% 
  
  # Calculate cumulative position of each chromosome
  mutate(tot=cumsum(as.numeric(chr_len))-chr_len) %>%
  select(-chr_len) %>%
  
  # Add this info to the initial dataset
  left_join(alt_gwas, ., by=c("CHR"="CHR")) %>%
  
  # Add a cumulative position of each SNP
  arrange(CHR, BP) %>%
  mutate( BPcum=BP+tot) %>%

  # Add highlight and annotation information
  # mutate(highlight=ifelse(F!=0, "yes", "no"))
  mutate( is_annot=ifelse((SNP %in% snpsOfInterest)&(F!=0), "yes", "no"))
  # mutate( is_annotate=ifelse(-log10(P)>6, "yes", "no")) 

# Prepare X axis
axisdf <- don %>% group_by(CHR) %>% summarize(center=( max(BPcum) + min(BPcum) ) / 2  )

# Make the plot
ggplot(don, aes(x=BPcum, y=-log10(P))) +
    
    # Show all points
    geom_point(data=subset(don, F==0), aes(color=as.factor(CHR)), alpha=0.8, size=1.3) +
    scale_color_manual(values = rep(c("grey", "skyblue"), 22 )) +
    
    # custom X axis:
    scale_x_continuous( label = axisdf$CHR, breaks= axisdf$center ) +
    scale_y_continuous(expand = c(0, 0) ) +     # remove space between plot area and x axis
    ylim(c(0,25)) +

    # Add highlighted points
    geom_point(data=subset(don, F==1), color="orange", size=2) +
    geom_point(data=subset(don, F==2), color="red", size=2) +
    geom_point(data=subset(don, F==3), color="yellow", size=2) +
    geom_point(data=subset(don, F==4), color="green", size=2) +
    geom_point(data=subset(don, F==5), color="pink", size=2) +
    geom_point(data=subset(don, F==6), color="purple", size=2) +
  
    # Add label using ggrepel to avoid overlapping
    geom_label_repel( data=subset(don, is_annot=="yes"), aes(label=SNP), size=2) +

    # Custom the theme:
    xlab("Chromosomes") +
    ylab("-log10(p_value)") +
    theme_bw() +
    theme( 
      legend.position="none",
      panel.border = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_blank()
    ) -> p

####### draw legend
df_legend = read.csv("assoc_linear/mahattan_legend.csv")
p_legend <- ggplot(df_legend, aes(x=x, y=x, color=trait)) +
  geom_point() +
  scale_colour_manual(values=df_legend$color) +
  labs(colour = "Traits") +
  theme_minimal() +
  theme(legend.position = "bottom") +
  guides(colour = guide_legend(nrow = 1))
p_legend

legend <- get_legend(p_legend)

ggarrange(p, legend, ncol=1, heights=c(1,0.1))

ggsave("mahattan_annot.png", width=10, height=6)
ggsave("mahattan_annot.pdf", width=10, height=6)
 