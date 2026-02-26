library(data.table)
library(dplyr)
library()



data_compare <- list.files(path = '/home/giangvm1/bit_bucket/pangenom/pipeline/old_code/genome_graph_mc_pipeline/scripts/old_upsets/processed_vcfs_ad',
                           full.names = T,recursive = T)


data_process <- function(path){
  pattern <- basename(dirname(path))
  sample <- strsplit(x = basename(path),split = '_')[[1]][1]
  # print(sample)
  df <- fread(path,
              col.names = c('chr','pos','ref','alt','dp','ref_cov','alt_cov','gt'),fill = T)
  df <- df[df$gt %in% c('0/1','1/0'),]
  # 
  df$len <- nchar(df$alt) -nchar(df$ref)

  df$ref_cov <- as.numeric(df$ref_cov)
  df$alt_cov <- as.numeric(df$alt_cov)
  df <- df[!is.na(df$alt_cov) & !is.na(df$ref_cov),]
  df$ratio <- df$alt_cov / (df$alt_cov + df$ref_cov)
  df <- df %>% select(len,ratio)
  df$label <- pattern
  df$sample <- sample
  df_new <- df %>%  group_by(len) %>%
    summarise(
      mean_value = mean(ratio, na.rm = TRUE),
      sd_value   = sd(ratio, na.rm = TRUE),
      n          = n()
    )
  df_new$label <- pattern
  df_new$sample <- sample
  df_new
}


data_out  <- lapply(data_compare, function(x){
  data_process(path = x)
})

output <- Reduce(rbind,data_out)
sampleID <- unique(output$sample)
commom_value <- lapply(sampleID, function(x){
  test <- output[output$sample == x,]
  test_len <- test$len[table(test$len) >=2]
  test <- test[test$len %in% test_len,]
})

output_plot <- Reduce(rbind,commom_value)

output <- output_plot[abs(output_plot$len) <=15,]
output <- output[!is.na(output$sd_value) & !is.na(output$mean_value),]





library(ggplot2)
ggplot(output, aes(x=len, y=mean_value, color=label)) + 
  geom_line(aes(linetype=label), linewidth = 0.5) +
  geom_point() + theme_bw() +  facet_wrap(sample~.,ncol = 1)+ ggtitle('GQ>20')


