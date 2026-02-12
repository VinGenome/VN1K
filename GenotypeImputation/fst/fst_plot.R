setwd("/home/namnn12/project/plot_code/1KVG_imputation/fst/")
library(ggplot2)

data <- read.table('all_fst.csv', header = TRUE,  sep = '\t',  stringsAsFactors = FALSE)
pop_data <- read.csv("../igsr_population_info.txt", sep = "\t")
pop_data <- pop_data[c("Population.name", "Population.description", "Superpopulation.name")]
colnames(pop_data) <- c("setname", "country", "region")
pop_data$region <- gsub(' \\(HGDP\\)','',pop_data$region)
pop_data$country <- gsub(' \\(HGDP\\)', '', pop_data$country)
pop_data$country <- stringr::str_split_fixed(pop_data$country, " in ", 2)[,2]
data_with_pop <- merge(data, pop_data, by = "setname")

pop_order <- data_with_pop %>% arrange(desc(mean)) %>% select("setname") %>% unlist()
data_with_pop$setname <- factor(data_with_pop$setname, levels=pop_order)

fst_plot <- ggplot(data=data_with_pop, aes(x=setname, y=mean, fill=country)) +
    geom_bar(stat="identity") +
    xlab("Population") +
    ylab("Fst") +
    coord_flip() +
    theme_classic() +
    theme(legend.position = 'top',
          legend.justification = c(-0.2),
          legend.key.size = unit(0.4,'cm')) +
    guides(fill=guide_legend(title="Country", 
                           nrow=3)) +
  #scale_fill_brewer(palette = "Set1")
  scale_fill_manual(values=c("#E41A1C","#377EB8","#F781BF","#984EA3","#FF7F00"))

fst_plot
ggsave("Fst.pdf", height=8, width=6, unit="in", dpi=300)

# merge figure
fig1 <- ggarrange(
  p12, NULL, fst_plot, 
  nrow = 1, widths = c(3.5,0.1,2),
  labels=c("a", "", "b")
)
fig1
ggsave(filename="images/error_rate_plot3.pdf", plot=fig1,
       device="pdf", units="in", width=10, height=6)

# additional
melt_data <- reshape::melt(data_with_pop, id=c("setname", "country","region"))
ggplot(data=melt_data, aes(x=reorder(setname, -value), y=value, fill=variable)) +
    geom_bar(stat="identity", position=position_dodge()) +
    coord_flip() +
    theme_minimal()
