#!/usr/bin/env Rscript
# =============================================================================
# SV Caller Comparison Analysis
# =============================================================================
# This script analyzes structural variant (SV) calls from multiple callers
# and generates UpSet plots to visualize concordance between tools.
#
# Usage:
#   Rscript analysis.R [sample_id] [data_dir]
#   
# Example:
#   Rscript analysis.R HG02059 /path/to/old_upsets/
#
# =============================================================================

# =============================================================================
# Load Libraries
# =============================================================================
suppressPackageStartupMessages({
  library(data.table)
  library(dplyr)
  library(UpSetR)
  library(ggplot2)
})

# =============================================================================
# Configuration
# =============================================================================
config <- list(
  # Default values (can be overridden via command line)
  sample_id = "HG02059",
  data_dir = "/home/giangvm1/bit_bucket/pangenom/pipeline/old_code/genome_graph_mc_pipeline/scripts/old_upsets/",
  
  # Columns to exclude from analysis
  exclude_cols = c("CHROM", "POS", "SUPP", "SUPP_VEC", "SVTYPE", "SVLEN", "SV"),
  
  # Plot settings
  upset_color = "#2c3e50",
  main_bar_color = "#3498db",
  sets_bar_color = "#2c3e50",
  
  # Output directory
  output_dir = NULL  # Will be set based on data_dir
)

# =============================================================================
# Parse Command Line Arguments
# =============================================================================
parse_args <- function() {
  args <- commandArgs(trailingOnly = TRUE)
  
  if (length(args) >= 1) {
    config$sample_id <<- args[1]
  }
  if (length(args) >= 2) {
    config$data_dir <<- args[2]
  }
  
  # Set output directory
  config$output_dir <<- file.path(config$data_dir, "plots")
  
  message("=== Configuration ===")
  message(sprintf("Sample ID: %s", config$sample_id))
  message(sprintf("Data directory: %s", config$data_dir))
  message(sprintf("Output directory: %s", config$output_dir))
}

# =============================================================================
# Data Loading Functions
# =============================================================================

#' Load and prepare SV data from merged SURVIVOR output
#'
#' @param sample_id Sample identifier
#' @param data_dir Directory containing the merged files
#' @return data.table with cleaned and prepared data
load_sv_data <- function(sample_id, data_dir) {
  file_path <- file.path(data_dir, paste0(sample_id, "_merged.final_header.txt"))
  
  if (!file.exists(file_path)) {
    stop(sprintf("Data file not found: %s", file_path))
  }
  
  message(sprintf("Loading data from: %s", file_path))
  
  # Read data with all columns as character initially
  df <- fread(file_path, colClasses = "character")
  
  # Standardize column names to uppercase
  colnames(df) <- toupper(colnames(df))
  
  return(df)
}

#' Clean genotype data (convert ./. to 0, others to 1)
#'
#' @param df data.table with raw genotype data
#' @param sample_id Sample identifier for column selection
#' @return data.table with binary presence/absence values
clean_genotype_data <- function(df, sample_id) {
  # Identify sample columns (exclude metadata)
  sample_prefix <- toupper(sample_id)
  sample_cols <- grep(sample_prefix, colnames(df), value = TRUE)
  
  message(sprintf("Found %d sample columns", length(sample_cols)))
  
  # Convert genotype to binary
  for (col in sample_cols) {
    df[[col]] <- ifelse(df[[col]] == "./." | df[[col]] == ".", 0, 1)
    df[[col]] <- as.numeric(df[[col]])
  }
  
  # Create unique SV identifier
  df$SV <- paste(df$CHROM, df$POS, df$SVTYPE, sep = "-")
  
  return(df)
}

#' Merge novel calling results into VG_CALL columns
#'
#' @param df data.table with SV data
#' @param sample_id Sample identifier
#' @return data.table with merged novel calling results
merge_novel_calling <- function(df, sample_id) {
  sample_prefix <- toupper(sample_id)
  
  # Define column pairs to merge
  merge_pairs <- list(
    lr = list(
      target = paste0(sample_prefix, "_VG_CALL_LR"),
      source = paste0(sample_prefix, "_NOVEL_CALLING_PANGENOME_LR")
    ),
    sr = list(
      target = paste0(sample_prefix, "_VG_CALL_SR"),
      source = paste0(sample_prefix, "_NOVEL_CALLING_PANGENOME_SR")
    )
  )
  
  for (pair in merge_pairs) {
    if (pair$target %in% colnames(df) && pair$source %in% colnames(df)) {
      df[[pair$target]] <- ifelse(df[[pair$source]] == 1, 1, df[[pair$target]])
      message(sprintf("Merged %s into %s", pair$source, pair$target))
    }
  }
  
  return(df)
}

# =============================================================================
# Filtering Functions
# =============================================================================

#' Filter data by SV type
#'
#' @param df data.table with SV data
#' @param svtype SV type to filter (DEL, INS, DUP, INV, etc.)
#' @return Filtered data.table
filter_by_svtype <- function(df, svtype) {
  filtered <- df[grepl(svtype, df$SV, ignore.case = TRUE), ]
  message(sprintf("Filtered to %d %s variants", nrow(filtered), svtype))
  return(filtered)
}

#' Filter columns by pattern (e.g., LR, SR)
#'
#' @param df data.table with SV data
#' @param pattern Pattern to match in column names
#' @return data.table with 'SV' column and matched columns
filter_columns_by_pattern <- function(df, pattern) {
  cols <- grep(pattern, colnames(df), value = TRUE, ignore.case = TRUE)
  result <- df %>% select(SV, all_of(cols))
  return(result)
}

# =============================================================================
# Plotting Functions
# =============================================================================

#' Create UpSet plot with consistent styling
#'
#' @param data data.table with binary presence/absence data
#' @param sets Character vector of set names
#' @param title Optional plot title
#' @param main_bar_color Color for main bars
#' @param sets_bar_color Color for set size bars
#' @return UpSet plot object
create_upset_plot <- function(data, 
                               sets = NULL, 
                               title = NULL,
                               main_bar_color = config$main_bar_color,
                               sets_bar_color = config$sets_bar_color) {
  
  if (is.null(sets)) {
    sets <- setdiff(colnames(data), config$exclude_cols)
  }
  
  # Filter to only columns that exist
  sets <- intersect(sets, colnames(data))
  
  if (length(sets) < 2) {
    warning("Need at least 2 sets for UpSet plot")
    return(NULL)
  }
  
  # Convert to data.frame (required by UpSetR)
  plot_data <- as.data.frame(data)
  
  # Ensure numeric
  for (col in sets) {
    plot_data[[col]] <- as.numeric(plot_data[[col]])
  }
  
  # Create plot
  upset(
    plot_data,
    sets = sets,
    order.by = "freq",
    decreasing = TRUE,
    mb.ratio = c(0.6, 0.4),
    number.angles = 0,
    text.scale = c(1.3, 1.3, 1, 1, 1.5, 1),
    main.bar.color = main_bar_color,
    sets.bar.color = sets_bar_color,
    point.size = 3.5,
    line.size = 1.5
  )
}

#' Save plot to file
#'
#' @param plot_func Function that creates the plot
#' @param filename Output filename (without extension)
#' @param width Plot width in inches
#' @param height Plot height in inches
save_plot <- function(plot_func, filename, width = 12, height = 8) {
  output_path <- file.path(config$output_dir, paste0(filename, ".pdf"))
  
  # Create output directory if needed
  if (!dir.exists(config$output_dir)) {
    dir.create(config$output_dir, recursive = TRUE)
  }
  
  pdf(output_path, width = width, height = height)
  plot_func()
  dev.off()
  
  message(sprintf("Saved plot to: %s", output_path))
}

# =============================================================================
# Analysis Functions
# =============================================================================

#' Run complete analysis for a sample
#'
#' @param sample_id Sample identifier
#' @param data_dir Directory containing the data files
#' @param save_plots Whether to save plots to files
run_analysis <- function(sample_id, data_dir, save_plots = FALSE) {
  message("\n", paste(rep("=", 60), collapse = ""))
  message(sprintf("Starting analysis for sample: %s", sample_id))
  message(paste(rep("=", 60), collapse = ""), "\n")
  
  # Load and prepare data
  df <- load_sv_data(sample_id, data_dir)
  df <- clean_genotype_data(df, sample_id)
  df <- merge_novel_calling(df, sample_id)
  
  # Get sample-specific columns
  sample_prefix <- toupper(sample_id)
  sample_cols <- grep(sample_prefix, colnames(df), value = TRUE)
  sample_cols <- setdiff(sample_cols, "SV")
  
  message(sprintf("\nSample columns: %s", paste(sample_cols, collapse = ", ")))
  
  # === Analysis 1: All callers, by SV type ===
  message("\n--- All Callers Analysis ---")
  
  output <- df %>% select(SV, all_of(sample_cols))
  
  # DEL analysis
  output_del <- filter_by_svtype(output, "DEL")
  message("Creating UpSet plot: All callers - DEL")
  if (save_plots) {
    save_plot(
      function() create_upset_plot(output_del, sample_cols),
      paste0(sample_id, "_all_callers_DEL")
    )
  } else {
    create_upset_plot(output_del, sample_cols)
  }
  
  # INS analysis
  output_ins <- filter_by_svtype(output, "INS")
  message("Creating UpSet plot: All callers - INS")
  if (save_plots) {
    save_plot(
      function() create_upset_plot(output_ins, sample_cols),
      paste0(sample_id, "_all_callers_INS")
    )
  } else {
    create_upset_plot(output_ins, sample_cols)
  }
  
  # === Analysis 2: Long-read callers only ===
  message("\n--- Long-Read Callers Analysis ---")
  
  lr_data <- filter_columns_by_pattern(output, "LR")
  lr_cols <- setdiff(colnames(lr_data), "SV")
  
  # Ensure numeric
  for (col in lr_cols) {
    lr_data[[col]] <- as.numeric(lr_data[[col]])
  }
  
  lr_del <- filter_by_svtype(lr_data, "DEL")
  lr_ins <- filter_by_svtype(lr_data, "INS")
  
  message("Creating UpSet plot: LR callers - DEL")
  if (save_plots) {
    save_plot(
      function() create_upset_plot(lr_del, lr_cols),
      paste0(sample_id, "_LR_callers_DEL")
    )
  } else {
    create_upset_plot(lr_del, lr_cols)
  }
  
  message("Creating UpSet plot: LR callers - INS")
  if (save_plots) {
    save_plot(
      function() create_upset_plot(lr_ins, lr_cols),
      paste0(sample_id, "_LR_callers_INS")
    )
  } else {
    create_upset_plot(lr_ins, lr_cols)
  }
  
  # === Analysis 3: Key callers comparison ===
  message("\n--- Key Callers Comparison ---")
  
  key_callers <- c(
    paste0(sample_prefix, "_MANTA_LINEAR_SR"),
    paste0(sample_prefix, "_VG_CALL_LR"),
    paste0(sample_prefix, "_VG_CALL_SR"),
    paste0(sample_prefix, "_PBSV_PBMM2_LR")
  )
  
  # Filter to existing columns only
  key_callers <- intersect(key_callers, colnames(output))
  
  if (length(key_callers) >= 2) {
    key_data <- output %>% select(SV, all_of(key_callers))
    
    key_del <- filter_by_svtype(key_data, "DEL")
    key_ins <- filter_by_svtype(key_data, "INS")
    
    message("Creating UpSet plot: Key callers - DEL")
    if (save_plots) {
      save_plot(
        function() create_upset_plot(key_del, key_callers),
        paste0(sample_id, "_key_callers_DEL")
      )
    } else {
      create_upset_plot(key_del, key_callers)
    }
    
    message("Creating UpSet plot: Key callers - INS")
    if (save_plots) {
      save_plot(
        function() create_upset_plot(key_ins, key_callers),
        paste0(sample_id, "_key_callers_INS")
      )
    } else {
      create_upset_plot(key_ins, key_callers)
    }
  } else {
    warning("Not enough key callers found for comparison")
  }
  
  # === Summary Statistics ===
  message("\n", paste(rep("=", 60), collapse = ""))
  message("Summary Statistics")
  message(paste(rep("=", 60), collapse = ""))
  
  total_svs <- nrow(df)
  del_count <- sum(grepl("DEL", df$SVTYPE))
  ins_count <- sum(grepl("INS", df$SVTYPE))
  
  message(sprintf("Total SVs: %d", total_svs))
  message(sprintf("Deletions: %d (%.1f%%)", del_count, 100 * del_count / total_svs))
  message(sprintf("Insertions: %d (%.1f%%)", ins_count, 100 * ins_count / total_svs))
  
  # Per-caller counts
  message("\nPer-caller variant counts:")
  for (col in sample_cols) {
    count <- sum(output[[col]] == 1, na.rm = TRUE)
    message(sprintf("  %s: %d", col, count))
  }
  
  message("\n", paste(rep("=", 60), collapse = ""))
  message("Analysis complete!")
  message(paste(rep("=", 60), collapse = ""))
  
  # Return processed data for further analysis
  invisible(list(
    data = df,
    output = output,
    del = output_del,
    ins = output_ins,
    lr_data = lr_data
  ))
}

# =============================================================================
# Main Execution
# =============================================================================

if (interactive()) {
  # Running in RStudio/interactive mode
  message("Running in interactive mode...")
  
  # Use default configuration
  result <- run_analysis(
    sample_id = config$sample_id,
    data_dir = config$data_dir,
    save_plots = FALSE
  )
  
} else {
  # Running from command line
  parse_args()
  
  result <- run_analysis(
    sample_id = config$sample_id,
    data_dir = config$data_dir,
    save_plots = TRUE
  )
}


col_set <- c('HG02059_MANTA_LINEAR_SR',
             'HG02059_VG_CALL_SR',
             'HG02059_VG_CALL_LR',
             'HG02059_VG_CALL_LR')


