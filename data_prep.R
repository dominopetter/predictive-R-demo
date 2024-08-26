# data_prep.R
# Load necessary libraries and prepare data
set.seed(42)
n <- 100
x <- rnorm(n, mean = 50, sd = 10)
y <- 3 * x + rnorm(n, mean = 0, sd = 10)

# Save the prepared data to the /workflow/outputs/ directory
write.csv(data.frame(x, y), "/workflow/outputs/prepared_data.csv", row.names = FALSE)