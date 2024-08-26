# Load dependencies
library(jsonlite)
library(ggplot2)
library(mlflow)
library(reticulate)
library(DominoDataR)

use_python("/opt/conda/bin/python", required = TRUE)
mlflow <- import("mlflow")

# Start an MLFlow run
mlflow_start_run()

# Generate some synthetic data for a simple linear regression model
set.seed(Sys.time())  # For reproducibility
n <- 100
x <- rnorm(n, mean = 50, sd = 10)
y <- 3 * x + rnorm(n, mean = 0, sd = 10)  # Linear relationship with some noise

# Train a simple linear regression model
model <- lm(y ~ x)

# Extract the coefficients and other relevant statistics
coefficients <- summary(model)$coefficients

# Introduce slight variability by adding random noise to each selected statistic
noise_level <- 0.5  # Adjust the noise level as needed

diagnostics <- list(
  "Intercept_Estimate" = coefficients[1, 1] + rnorm(1, mean = 0, sd = noise_level),
  "Slope_Estimate" = coefficients[2, 1] + rnorm(1, mean = 0, sd = noise_level),
  "Slope_p_value" = coefficients[2, 4] + rnorm(1, mean = 0, sd = noise_level * 1e-85)  # Smaller noise for p-value
)

# Log parameters and metrics to MLFlow
mlflow_log_param("Intercept_Estimate", diagnostics$Intercept_Estimate)
mlflow_log_param("Slope_Estimate", diagnostics$Slope_Estimate)
r_squared <- summary(model)$r.squared
mlflow_log_metric("R_squared", r_squared)

# Save the diagnostics to dominostats.json with named elements
fileConn <- file("dominostats.json")
writeLines(toJSON(diagnostics, pretty = TRUE), fileConn)
close(fileConn)

# Create a scatter plot with the regression line
plot <- ggplot(data = data.frame(x = x, y = y), aes(x = x, y = y)) +
  geom_point(color = 'blue') +  # Scatter plot of the data points
  geom_smooth(method = "lm", color = 'red', se = FALSE) +  # Add the regression line
  ggtitle("Linear Regression Fit") +  # Add a title
  xlab("X") +  # Label for X-axis
  ylab("Y") +  # Label for Y-axis
  theme_minimal()  # Use a clean theme

# Save the plot as a PNG file
local_file_path <- "results/regression_plot.png"
dir.create("results", showWarnings = FALSE)  # Ensure the directory exists
ggsave(local_file_path, plot, width = 8, height = 6)

# Log the PNG file as an artifact to MLFlow
mlflow_log_artifact(local_file_path, "plots")

# Initialize the Domino data source client
client <- DominoDataR::datasource_client()

# Upload the PNG file to the specified bucket
DominoDataR::put_object(client, "SE-Demo-Bucket", "regression_plot.png", local_file_path)

# Save the model as an RDS file
model_path <- "linear_model.rds"
saveRDS(model, file = model_path)

# Log the RDS file as an artifact in MLFlow
mlflow_log_artifact(model_path, artifact_path = "models")

# Get the current run ID using R's mlflow_get_run() - CHANGED
run_id <- mlflow_get_run()$run_id  # CHANGED

# Use the Python path where MLflow is installed - CHANGED
use_python("/opt/conda/bin/python", required = TRUE)  # CHANGED

# Verify the Python configuration - CHANGED
py_config()  # CHANGED

# Import the mlflow module in Python - CHANGED
mlflow_py <- import("mlflow")  # CHANGED

# Define the Python function to register the model - CHANGED
register_model_code <- "  # CHANGED
import mlflow  # CHANGED
def register_model(run_id, model_path, model_name):  # CHANGED
    model_uri = f'runs:/{run_id}/{model_path}'  # CHANGED
    result = mlflow.register_model(model_uri, model_name)  # CHANGED
    print(f'Model registered successfully: {result.name} Version: {result.version}')  # CHANGED
    return result  # CHANGED
"  # CHANGED

# Execute Python code to register the model - CHANGED
py_run_string(register_model_code)  # CHANGED

# Call the Python function to register the model - CHANGED
py_register_model <- py$register_model  # CHANGED
py_register_model(run_id, "models/linear_model.rds", "my_model")  # CHANGED

# End the MLFlow run
mlflow_end_run()

# Define the API function to predict based on the input data
# To call model use: {"data": {"x": value}}
my_model <- function(x) {
  # Load the trained model (assuming you saved it earlier)
  model <- readRDS("linear_model.rds")
  
  # Make the prediction
  prediction <- predict(model, newdata = data.frame(x = x))
  
  # Introduce slight variability by adding a small random noise
  noise <- rnorm(1, mean = 0, sd = 0.5)  # Adjust the standard deviation to control variability
  prediction <- prediction + noise
  
  return(list(prediction = prediction))
}
