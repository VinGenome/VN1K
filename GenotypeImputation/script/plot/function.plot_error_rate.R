plot_error_rate <- function(true, impute, maf) {
  # true is df of true genotype; true=true
  # impute is df of imputed genotype; impute=gt.1kgp
  # maf is MAF_group from 1kgp;
  m <- Reduce(intersect, list(true$ID, impute$ID, maf$ID))
  mat1 <- true %>% filter(ID %in% m) 
  mat2 <- impute %>% filter(ID %in% m)
  # check rowname and colname
  if (all(colnames(mat1) == colnames(mat2)) &
      all(mat1$ID == mat2$ID)) {
    print("Proceed!")
  } else {
    stop("index of true gt and imputed gt do not match")
  }
  # count number of discordance
  eq <- mat1[,-1] != mat2[,-1]
  # error rate
  sum(eq) /(nrow(eq) * ncol(eq)) * 100
  # split error rate per MAF
  df0 <- data.frame("MAF_group"=levels(maf$MAF_group), "error_rate"=0)
  for (i in 1:nlevels(maf$MAF_group)) {
    # filter the AF group
    maf %>%
      filter(MAF_group == levels(maf$MAF_group)[i]) %>%
      as_tibble() -> maf1
    # filter mat1 & mat2 based on maf1$ID
    x1 <- mat1 %>%
      filter(ID %in% maf1$ID) %>%
      select(-1)
    x2 <- mat2 %>%
      filter(ID %in% maf1$ID) %>%
      select(-1)
    # count number of discordance
    y <- x1 != x2
    # assign result
    df0[i,2] <- sum(y) / (nrow(y)*ncol(y)) * 100
  }
  return(df0)
}