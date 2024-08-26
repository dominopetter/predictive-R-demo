# Predictive Model with Variability in R

## Overview

This project involves the creation of a simple linear regression model in R, which is used to make predictions via an API. The model’s predictions are designed to vary slightly each time it is called, providing a more realistic simulation of predictive behavior. Additionally, key model statistics are saved to a `dominostats.json` file, which is used for diagnostic purposes.

## Steps Involved

### 1. Data Generation and Model Training

We generate synthetic data for a linear regression model. The data consists of 100 observations with a simple linear relationship between the independent variable `x` and the dependent variable `y`:

```r
# Generate synthetic data
set.seed(42)
n <- 100
x <- rnorm(n, mean = 50, sd = 10)
y <- 3 * x + rnorm(n, mean = 0, sd = 5)
```

Using this data, we train a linear regression model:

```r
# Train a simple linear regression model
model <- lm(y ~ x)
```

### 2. Introducing Variability in Predictions

To ensure that the model predictions are not static, we introduce random noise to key statistics that are saved in the `dominostats.json` file. This noise is added to the following statistics:
- `Intercept_Estimate`
- `Slope_Estimate`
- `Slope_p_value`

Here’s how we add noise:

```r
# Add noise to key statistics
noise_level <- 0.05
coefficients <- summary(model)$coefficients
diagnostics <- list(
  "Intercept_Estimate" = coefficients[1, 1] + rnorm(1, mean = 0, sd = noise_level),
  "Slope_Estimate" = coefficients[2, 1] + rnorm(1, mean = 0, sd = noise_level),
  "Slope_p_value" = coefficients[2, 4] + rnorm(1, mean = 0, sd = noise_level * 1e-85)
)
```

### 3. Saving Model Diagnostics

The diagnostics are saved in a JSON file named `dominostats.json`. This file is used to store key model statistics, formatted as follows:

```r
# Save diagnostics to JSON file
fileConn <- file("dominostats.json")
writeLines(toJSON(diagnostics, pretty = TRUE), fileConn)
close(fileConn)
```

The resulting JSON file might look like this (values will vary slightly due to added noise):

```json
{
  "Intercept_Estimate": -1.1158,
  "Slope_Estimate": 3.0186,
  "Slope_p_value": 9.7485e-85
}
```

### 4. API Endpoint for Predictions

An API endpoint is defined to use the trained model for making predictions. Similar to the diagnostics, predictions also include a slight random variation to simulate real-world unpredictability:

```r
# API function to predict based on input data
my_model <- function(x) {
  prediction <- predict(model, newdata = data.frame(x = x))
  noise <- rnorm(1, mean = 0, sd = 0.5)
  prediction <- prediction + noise
  return(list(prediction = prediction))
}
```

### 5. Running the Model

To run the model and generate predictions, load the trained model using:

```r
model <- readRDS("linear_model.rds")
```

Then, you can call the `my_model` function with a specific input value:

```r
result <- my_model(x = 55)
```

### Summary

- **Data Generation**: Synthetic data is created for a simple linear regression model.
- **Model Training**: A linear regression model is trained on the generated data.
- **Variability**: Noise is added to key model statistics and predictions to introduce variability.
- **Diagnostics**: Key statistics are saved in `dominostats.json` for diagnostic purposes.
- **API Endpoint**: An API function is defined to make predictions with variability.

This setup allows for a more dynamic and realistic simulation of a predictive model in a deployed environment.

## How to Use

1. **Run the R script** to train the model and generate the `dominostats.json` file.
2. **Deploy the API endpoint** to start making predictions with slight variability.
3. **Review the `dominostats.json` file** to understand the model’s performance metrics.
4. **Call the `my_model` function** to get predictions, which will vary slightly each time due to the added noise.