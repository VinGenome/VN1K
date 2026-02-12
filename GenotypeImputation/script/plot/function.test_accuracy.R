test_accuracy <- function(true, impute, maf) {
  # x is the data frame of true genotype ; y is the data frame of imputed genotype
  # filter intersected df
  filter(true, ID %in% m) -> x
  filter(impute, ID %in% m) -> y
  # create result df
  df <- data.frame("MAF_group"=levels(maf$MAF_group), r2=0)
  # stop the script on condition of different SNPs or samples ID ?
  if(
    all(colnames(x[,-1]) == colnames(y[,-1])) &
    all(x$ID == y$ID)
  ) {
    print("proceed")
  } else {
    print("dataframe errors")
  }
  #
  # loop through the MAF group
  print(dim(x))
  print(dim(y))
  for (i in 1:nlevels(maf$MAF_group)) {
    # filter the AF group
    MAF_1KGP3 %>%
      filter(MAF_group == levels(maf$MAF_group)[i]) %>%
      as_tibble() -> maf1
    # create x1 dataframe for type snp
    x %>%
      filter(x$ID %in% maf1$ID) %>%
      select(-ID) %>%
      t() %>% as.data.frame() %>% unlist() -> x1
    # create y1 dataframe for impute snp
    y %>%
      filter(y$ID %in% maf1$ID) %>%
      select(-ID) %>%
      t() %>% as.data.frame() %>% unlist() -> y1
    # calculate r2 pearson correlation and append to the result table
    (cor(x1,y1, use="pairwise.complete.obs"))^2 -> df$r2[i]
    print(df$r2[i])
    # print(unique(maf$MAF_group))
    # print the done message
    if (i == nlevels(maf$MAF_group)) {
      cat("Done!\n")}
  }
  return(df)
}

