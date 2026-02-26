
library(data.table)
library(dplyr)
library(UpSetR)

sampleID <- 'HG02080'

count_function <- function(sampleID){
  
  df_raw <- fread(paste0(
    '/home/giangvm1/bit_bucket/pangenom/pipeline/old_code/genome_graph_mc_pipeline/scripts/old_upsets/',
    sampleID,
    '_merged.final_header.txt'))
  
  colnames(df_raw) <- toupper(colnames(df_raw))
  
  df <- df_raw
  df[,7:ncol(df)][df[,7:ncol(df)] == './.']  <- 0
  df[,7:ncol(df)][df[,7:ncol(df)] != 0]  <- 1
  
  df$SV <- paste(df$CHROM,df$POS,df$SVTYPE,df$SVLEN,sep = ':')
  
  
  selected_column <- colnames(df)[grepl('HG',colnames(df))]
  
  df <- df %>% select(SV,all_of(selected_column))
  df[,2:ncol(df)] <- lapply(df[,2:ncol(df)],as.numeric)
  
  # selected_column <- selected_column[grepl('LR',selected_column)]
  
  colnames(df) <- gsub(paste0(sampleID,'_'),
                       '',
                       colnames(df))
  selected_column <- gsub(paste0(sampleID,'_'),
                          '',
                          selected_column)
  
  merge_result <- function(df,novel_col,genotyping_col){
    df_2 <- df %>% select(SV,contains(novel_col),contains(genotyping_col))
    colnames(df_2) <- c('SV','col1','col2')
    df_2$col2 <- ifelse(df_2$col1 ==1,1,df_2$col2)
    df_2 <- df_2 %>% select(SV,col2)
    df[[genotyping_col]] <- df_2$col2
    return(df)
  }
  
  
  df <- merge_result(df,
                           novel_col = 'NOVEL_CALLING_BACKBONE_LR',
                           genotyping_col = 'VG_CALL_BACKBONE_LR')
  df <- merge_result(df,
                              novel_col = 'NOVEL_CALLING_BACKBONE_SR',
                              genotyping_col = 'VG_CALL_BACKBONE_SR')
  
  
  df <- merge_result(df,
                           novel_col = 'NOVEL_CALLING_BASELINE_LR',
                           genotyping_col = 'VG_CALL_BASELINE_LR')
  df <- merge_result(df,
                              novel_col = 'NOVEL_CALLING_BASELINE_SR',
                              genotyping_col = 'VG_CALL_BASELINE_SR')
  
  df <- merge_result(df,
                            novel_col = 'NOVEL_CALLING_PANGENOME_LR',
                            genotyping_col = 'VG_CALL_LR')
  df <- merge_result(df,
                               novel_col = 'NOVEL_CALLING_PANGENOME_SR',
                               genotyping_col = 'VG_CALL_SR')
  
  list_pattern <- c('VG_CALL_BACKBONE_LR','VG_CALL_BACKBONE_SR',
                    'VG_CALL_BASELINE_SR','VG_CALL_BASELINE_LR',
                    'VG_CALL_LR','VG_CALL_SR')
  list_pattern <- c('VG_CALL_LR','VG_CALL_SR','MANTA_LINEAR_SR',
                    'CUTESV_PBMM2_LR')

  df_plot <- df %>% select(SV,all_of(list_pattern))
  name_mapping <- c('VG_CALL_LR'=paste0(sampleID,'_LR_GRAPH'),
                    'VG_CALL_SR'=paste0(sampleID,'_SR_GRAPH'),
                    'MANTA_LINEAR_SR'=paste0(sampleID,'_SR_HG38'),

                    'CUTESV_PBMM2_LR'=paste0(sampleID,'_LR_HG38'))
  df_plot <- df_plot %>%
    rename(!!!setNames(names(name_mapping), name_mapping))
  
  df_del <- df_plot[grepl('DEL',df_plot$SV),]
  df_ins <- df_plot[grepl('INS',df_plot$SV),]
  # return(list(df_del,df_ins))
  
  col_upset <- colnames(df_del)[colnames(df_del) !='SV']
  library(UpSetR)
  del <- upset(data=df_del,
        sets = col_upset,
        order.by = 'freq',mainbar.y.label = 'Number of shared DEL',
        )

  ins <- upset(data=df_ins,
        sets = col_upset,
        order.by = 'freq',mainbar.y.label = 'Number of shared INS')
  return(list(del,ins))
}

hg02080 <- count_function(sampleID = 'HG02080')
hg02059 <- count_function(sampleID = 'HG02059')

library(ggplot2)
library(gridExtra)

pdf('/home/giangvm1/bit_bucket/pangenom/pipeline/old_code/genome_graph_mc_pipeline/scripts/old_upsets/HG02080_HG02059.pdf',
    width = 5,height = 5)
hg02080[[2]]
hg02059[[2]]

hg02080[[1]]
hg02059[[1]]
dev.off()
g <- arrangeGrob(pA, pB, pC, pD, ncol = 2, nrow = 2)


del <- hg02080[[1]]
ins <- hg02080[[2]]
