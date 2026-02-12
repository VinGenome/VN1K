convert_gt_matrix <- function(x) {
  # x is a data frame
  mat <- as.matrix(x)
  mat[mat == "0|0" | mat=="0/0"] <- "0"
  mat[mat == "0|1" | mat == "1|0" | mat == "0/1" | mat == "1/0"] <- "1"
  mat[mat == "1|1" | mat == "1/1"] <- "2"
  mat <- as_tibble(mat) %>%
    mutate(across(!1, as.numeric))
}
