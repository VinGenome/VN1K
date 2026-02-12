plot_accuracy <- function(x, output) {
  # x is an array of string of data frame name: x <- ls(pattern="r2")
  # get name of panel
  names <- gsub(pattern="r2_", replacement="", x)
  # rename column and create list
  list.df <- list()
  for (i in 1:length(x)) {
    df0 <- get(x[i])
    colnames(df0)[2] <- names[i]
    list.df[[i]] <- df0
  }
  Reduce(function(x,y){merge(x,y, by="MAF_group", all=TRUE)}, list.df) %>%
    pivot_longer(-MAF_group, names_to="ref_panel", values_to="aggregate_r2") %>%
    mutate_at("MAF_group", as.factor) -> df
  # create custom axis tick
  tibble(Group=levels(df$MAF_group)) %>%
    separate(Group, into=c("min","max"), sep=",", remove=FALSE) %>%
    mutate_at(c("min","max"), parse_number) %>%
    mutate_at(c("min","max"), function(x){return(x*100)}) %>%
    mutate_at(c("min","max"), function(x){paste0(x,"%")}) -> arr
  apply(arr, 1, function(x) {
    paste0(x["min"],"-",x["max"])
  }
  ) -> arr_p
  # plot
  p1 <- ggplot(df, aes(x=MAF_group, y=aggregate_r2, group=ref_panel)) +
    geom_line(aes(color=ref_panel)) +
    # geom_point(aes(shape=ref_panel, color=ref_panel)) +
    scale_y_continuous() +
    scale_x_discrete(breaks=levels(df$MAF_group), labels=arr_p) +
    theme_classic() +
    theme(axis.text.x = element_text(angle=-15),
          axis.text.y = element_text(angle=90, hjust=0.5),
          # legend.position=c(1, 0.1), 
          legend.position = 'none',
          legend.justification=c(1, 0),
          legend.key.size=unit(0.15, "in"),
          plot.title=element_blank()
          #axis.title.x = element_blank()
          ) +
    labs(y="Aggregate R2\n(Pearson correlation)", x="MAF Groups") +
    scale_colour_discrete(name="Reference Panel")
    # guides(shape= FALSE)
  # output
  ggsave(filename=output, plot=p1,units="in", width=6, height=4, dpi=300)
  return(p1)
}

