set.seed(1337)

# Grab the required packages. Install first if needed.
list_of_packages <- c("ggplot2", "conflicted")

# Extract not installed packages
not_installed <- list_of_packages[!(list_of_packages %in% installed.packages()[, "Package"])]
if (length(not_installed)) install.packages(not_installed)

# Create made-up data.
data_matrix <- matrix(nrow = 100, ncol = 10)

# Let wt represent wild type (i.e. actual, everyday samples).
# Let ko represent knock-out samples (i.e. samples with knocked out genes).
colnames(data_matrix) <- c(
  paste("wt", 1:5, sep = ""),
  paste("ko", 1:5, sep = "")
)

# Name samples gene1, gene2 etc.
rownames(data_matrix) <- paste("gene", 1:100, sep = "")

# Give fake read counts to the genes.
# Poisson ditribution instead of
for (i in 1:100) {
  # Since we're using made-up data, we can use the Poisson Distribution
  # instead of the negative Binomial Distribution for simplicity.
  wt.values <- rpois(5, lambda = sample(x = 10:1000, size = 1))
  ko.values <- rpois(5, lambda = sample(x = 10:1000, size = 1))

  data_matrix[i, ] <- c(wt.values, ko.values)
}

# Compare PCA results with results from using eigen()
# eigen() returns vectors - eigenvectors (vectors with loading scores in this case)
#                           pcs = sum(loading scores * values for sample)
#                 values  - eigenvalues
cov_matrix <- cov(scale(t(data_matrix), center = TRUE))
dim(cov_matrix)

# We saw that the covariance matrix is symmetric. Hence, we can tell eigen()
# to work only on the lower triangle by specifying symmetric = TRUE.
# eigen_res <- eigen(cov_matrix, symmetric = TRUE)
eigen_PCs <- t(t(eigen_res$vectors) %*% t(scale(t(data_matrix), center = TRUE)))
dim(eigen_res$vectors)
head(eigen_res$vectors[, 1:2])

eigen_PCs <- t(t(eigen_res$vectors) %*% t(scale(t(data_matrix), center=TRUE)))
eigen_PCs[, 1:2]

eigen_df <- data.frame(
  Sample = rownames(eigen_PCs),
  X = (-1 * eigen_PCs[, 1]), # eigen() flips the X-axis in this case, so we flip it back
  Y = eigen_PCs[, 2]
) # X axis will be PC1, Y axis will be PC2
eigen_df

eigen_var_prc <- round(eigen_res$values / sum(eigen_res$values) * 100, 1)

ggplot2::ggplot(data = eigen_df, ggplot2::aes(x = X, y = Y, label = Sample)) +
  ggplot2::geom_text() +
  ggplot2::xlab(paste("PC1 - ", eigen_var_prc[1], "%", sep = "")) +
  ggplot2::ylab(paste("PC2 - ", eigen_var_prc[2], "%", sep = "")) +
  ggplot2::theme_bw() +
  ggplot2::ggtitle("eigen on cov(t(data.matrix))")
