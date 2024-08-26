# train_model.R
# Load necessary libraries and data

# Read input data from the /workflow/outputs/ directory
data <- read.csv("/workflow/outputs/prepared_data.csv")

# Train the model
model <- lm(y ~ x, data=data)

# Save the model to an RDS file in the /workflow/outputs/ directory
saveRDS(model, "/workflow/outputs/linear_model.rds")