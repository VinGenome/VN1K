setwd("D:/Coding/Work_GX/KVG/gwas_clinical")

library(tidyverse)
library(ggplot2)
library(ggrepel)
library(qqman)


alt_gwas = read.csv("assoc_linear/ALT.assoc.linear.add.header.tsv", sep="\t")
alt_gwas %>%
  filter(-log10(P)>1) -> alt_gwas_filter

manhattan(alt_gwas_filter, chr="CHR", bp="BP", snp="SNP", p="P", 
          suggestiveline = FALSE,
          genomewideline = -log10(4e-08),
          col = c("blue4","orange3"),
          annotatePval = 0.01,
          main ="ALT trait")
ggsave("ALT.pdf")


# don <- alt_gwas_filter %>% 
#   # Compute chromosome size
#   group_by(CHR) %>% 
#   summarise(chr_len=max(BP)) %>% 
  
#   # Calculate cumulative position of each chromosome
#   mutate(tot=cumsum(chr_len)-chr_len) %>%
#   select(-chr_len) %>%
  
#   # Add this info to the initial dataset
#   left_join(alt_gwas_filter, ., by=c("CHR"="CHR")) %>%
  
#   # Add a cumulative position of each SNP
#   arrange(CHR, BP) %>%
#   mutate( BPcum=BP+tot) %>%

#   # Add highlight and annotation information
#   # mutate( is_highlight=ifelse(SNP %in% snpsOfInterest, "yes", "no")) %>%
#   mutate( is_annotate=ifelse(-log10(P)>6, "yes", "no")) 

# # Prepare X axis
# axisdf <- don %>% group_by(CHR) %>% summarize(center=( max(BPcum) + min(BPcum) ) / 2 )

# # Make the plot
# ggplot(don, aes(x=BPcum, y=-log10(P))) +
    
#     # Show all points
#     geom_point( aes(color=as.factor(CHR)), alpha=0.8, size=1.3) +
#     scale_color_manual(values = rep(c("grey", "skyblue"), 22 )) +
    
#     # custom X axis:
#     scale_x_continuous( label = axisdf$CHR, breaks= axisdf$center ) +
#     scale_y_continuous(expand = c(0, 0) ) +     # remove space between plot area and x axis

#     # Add highlighted points
#     # geom_point(data=subset(don, is_highlight=="yes"), color="orange", size=2) +
  
#     # Add label using ggrepel to avoid overlapping
#     geom_label_repel( data=subset(don, is_annotate=="yes"), aes(label=SNP), size=2) +

#     # Custom the theme:
#     theme_bw() +
#     theme( 
#       legend.position="none",
#       panel.border = element_blank(),
#       panel.grid.major.x = element_blank(),
#       panel.grid.minor.x = element_blank()
#     )
