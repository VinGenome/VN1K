library(data.table)
library(dplyr)
library(UpSetR)

# Constants
sample_id <- "HG02059"
data_path <- paste0(
      "/home/giangvm1/bit_bucket/pangenom/pipeline/old_code/genome_graph_mc_pipeline/scripts/old_upsets/",
      sample_id, "_merged.final_header.txt"
)
exclude_cols <- c("CHROM", "POS", "SUPP", "SUPP_VEC", "SVTYPE", "SVLEN")
upset_color <- "black"

# Load and prepare data
load_and_prepare_data <- function(path) {
      df <- fread(path, colClasses = rep("character", 19))
      colnames(df) <- toupper(colnames(df))
      df
}

# Filter by SV type
filter_by_svtype <- function(df, svtype) {
      df[grepl(svtype, df$sv), ]
}

# Create upset plot

create_upset <- function(data, columns, color = upset_color) {
      upset(data, sets = columns, sets.bar.color = color, order.by = "freq")
}

# # Merge novel calling columns into VG_CALL
merge_novel_calling <- function(df) {
      df %>%
            mutate(
                  HG02059_VG_CALL_LR = ifelse(HG02059_NOVEL_CALLING_PANGENOME_LR == 1, 1, HG02059_VG_CALL_LR),
                  HG02059_VG_CALL_SR = ifelse(HG02059_NOVEL_CALLING_PANGENOME_SR == 1, 1, HG02059_VG_CALL_SR)
            )
}

# Main analysis
df <- load_and_prepare_data(data_path)
df[,7:19][df[,7:19] == './.'] <- 0
df[,7:19][df[,7:19] != 0] <- 1

df$sv <- paste(df$CHROM,df$POS,df$SVTYPE,sep = '-')
selected_column <- colnames(df)[!(colnames(df) %in%  c(exclude_cols))]
output <- df %>% select(sv,selected_column[selected_column !='sv'])

output[,2:ncol(output)] <- lapply(output[,2:ncol(output)],as.numeric)
output <- merge_novel_calling(output)

# Initial upset plots
output_del <- filter_by_svtype(output, "DEL")
output_ins <- filter_by_svtype(output, "INS")
set_columns <- colnames(output)[grepl("HG", colnames(output))]

create_upset(output_del, set_columns)
create_upset(output_ins, set_columns)



cmp_lr <- output %>% select(sv,contains('LR'))
cmp_lr[,2:ncol(cmp_lr)] <- lapply(cmp_lr[,2:ncol(cmp_lr)],as.numeric)

cmp_lr_del <- filter_by_svtype(cmp_lr, "DEL")
cmp_lr_ins <- filter_by_svtype(cmp_lr, "INS")

set_columns <- colnames(cmp_lr)[colnames(cmp_lr)!='sv']

create_upset(cmp_lr_ins, set_columns)
create_upset(cmp_lr_del, set_columns)

# Refined analysis
test <- merge_novel_calling()

set_columns3 <- c(
      "HG02059_MANTA_LINEAR_SR",
      "HG02059_VG_CALL_LR",
      "HG02059_VG_CALL_SR",
      "HG02059_PBSV_PBMM2_LR"
)

test <- test %>% select(sv, all_of(set_columns3))
test_del <- filter_by_svtype(test, "DEL")
test_ins <- filter_by_svtype(test, "INS")

create_upset(test_del, set_columns3)
create_upset(test_ins, set_columns3)
