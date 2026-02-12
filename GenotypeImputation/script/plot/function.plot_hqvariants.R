plot_hqvariants <- function(x, output) {
  # x is a vector of df names: x <- ls(pattern="rsq_")
  names <- gsub(pattern="rsq_", replacement="", x)
  ####
  # create result df
  tibble("MAF_group"=levels(MAF_1KGP3$MAF_group)) %>%
    cbind(as_tibble(matrix(0, ncol=length(x), nrow=nlevels(MAF_1KGP3$MAF_group)))) -> count_SNP
  colnames(count_SNP)[-1] <- names
  # loop command
  for (i in names) {
    for (j in 1:nlevels(MAF_1KGP3$MAF_group)) {
      get(paste0("rsq_",i)) %>%
        filter(Rsq >= 0.8 & Genotyped == "Imputed") -> tbl1
      MAF_1KGP3 %>%
        filter(MAF_group == levels(MAF_1KGP3$MAF_group)[j]) %>%
        as_tibble() -> maf1
      tbl1 %>%
        filter(tbl1$SNP %in% maf1$ID) %>% nrow() -> count_SNP[j,i]
    }
  }
  # create plotting df
  count_SNP %>%
    pivot_longer(-MAF_group, names_to="ref_panel", values_to="No_variants") %>%
    mutate_at("MAF_group", as.factor) -> df2
  # create custom axis tick
  tibble(Group=levels(df2$MAF_group)) %>%
    separate(Group, into=c("min","max"), sep=",", remove=FALSE) %>%
    mutate_at(c("min","max"), parse_number) %>%
    mutate_at(c("min","max"), function(x){return(x*100)}) %>%
    mutate_at(c("min","max"), function(x){paste0(x,"%")}) -> arr
  apply(arr, 1, function(x) {
    paste0(x["min"],"-",x["max"])
  }
  ) -> arr_p
  # new bar plot for high quality SNP with custom axis
  p2 <- ggplot(df2, aes(x=MAF_group, y=No_variants, fill=ref_panel)) +
    geom_bar(stat="identity", position="dodge") +
    theme(axis.text.x = element_text(angle=45)) +
    scale_x_discrete(breaks=levels(df2$MAF_group), labels=arr_p) +
    labs(y="Number of variants with\nRsq>0.8 (x1000)", x="MAF Groups") +
    theme_classic() +
    theme(axis.text.x = element_text(angle=-15),
          axis.text.y=element_text(angle=90, hjust=0.5),
          # legend.position=c(0.1, 1), 
          # legend.justification=c(0,1),
          # legend.key.size=unit(0.15, "in"),
          plot.title=element_blank()
          # axis.title.x = element_blank()
          ) +
    guides(fill=guide_legend(title="Reference Panel"))
  # output
  ggsave(filename=output, plot=p2, units="in", width=6, height=4, dpi=300)
  return(p2)
}

