# ============================================================
# Title: Nonlinear Growth Models Comparison (Robust Version)
# Author: Evangelina Viotto
# Date: 2026
# Objective:
# Fit and compare nonlinear growth models (Logistic, Gompertz,
# and Von Bertalanffy) using ecological data.
# The script includes data cleaning, robust model fitting,
# model comparison (AIC/BIC), and visualization.
# ============================================================

rm(list = ls())

# -------------------------------
# Libraries
# -------------------------------
library(tidyverse)
library(AICcmodavg)
library(purrr)

# -------------------------------
# 1. Data loading
# -------------------------------
data_path <- "data/CIadultos_masked.csv"

ci <- read.csv(data_path, sep = ",", dec = ".")

# -------------------------------
# 2. Data cleaning
# -------------------------------
ci_clean <- ci %>%
  slice(-c(1:23,24,25,26,28:30,31:33,35,38:41,45:49,
           52:54,57:60,62,63,66:68,69))

nat <- ci_clean %>%
  filter(ORIGEN == "Wy") %>%
  filter(!is.na(SVL), !is.na(Time),
         is.finite(SVL), is.finite(Time))

# Optional: remove extreme outliers (1% tails)
nat <- nat %>%
  filter(
    SVL > quantile(SVL, 0.01),
    SVL < quantile(SVL, 0.99)
  )

# -------------------------------
# 3. Model fitting function (robust)
# -------------------------------
fit_model <- function(formula, data, start) {
  
  model <- nls(formula,
               data = data,
               start = start,
               algorithm = "port")
  
  list(
    model = model,
    AIC = AICc(model),
    BIC = BIC(model),
    coef = coef(model)
  )
}

# Safe version (prevents crashes if a model fails)
fit_model_safe <- purrr::possibly(fit_model, otherwise = NULL)

# -------------------------------
# 4. Define models with improved starting values
# -------------------------------
models <- list(
  
  logistic = list(
    formula = SVL ~ alpha / (1 + beta * exp(-gamma * Time)),
    start = list(
      alpha = max(nat$SVL),
      beta = 1,
      gamma = 0.2
    )
  ),
  
  gompertz = list(
    formula = SVL ~ alpha * exp(-beta * exp(-gamma * Time)),
    start = list(
      alpha = max(nat$SVL),
      beta = 1,
      gamma = 0.2
    )
  ),
  
  vonbertalanffy = list(
    formula = SVL ~ alpha * (1 - beta * exp(-gamma * Time)),
    start = list(
      alpha = max(nat$SVL),
      beta = 0.9,
      gamma = 0.2
    )
  )
)

# -------------------------------
# 5. Fit models (robust approach)
# -------------------------------
results <- purrr::map(models, ~ fit_model_safe(.x$formula, nat, .x$start))

# Remove models that failed to converge
results_clean <- results[!sapply(results, is.null)]

# -------------------------------
# 6. Model comparison
# -------------------------------
model_comparison <- tibble(
  model = names(results_clean),
  AIC = purrr::map_dbl(results_clean, "AIC"),
  BIC = purrr::map_dbl(results_clean, "BIC")
) %>%
  arrange(AIC)

print(model_comparison)

# Identify best model
best_model_name <- model_comparison$model[1]
best_model <- results_clean[[best_model_name]]

cat("\nBest model:", best_model_name, "\n")

# -------------------------------
# 7. Visualization
# -------------------------------

# Sequence for smooth curves
x_seq <- seq(min(nat$Time), max(nat$Time), length.out = 200)

# Prediction function
predict_model <- function(model_name, coef, x) {
  
  if (model_name == "logistic") {
    coef[1] / (1 + coef[2] * exp(-coef[3] * x))
    
  } else if (model_name == "gompertz") {
    coef[1] * exp(-coef[2] * exp(-coef[3] * x))
    
  } else if (model_name == "vonbertalanffy") {
    coef[1] * (1 - coef[2] * exp(-coef[3] * x))
  }
}

# Build dataframe with all model curves
curve_df <- map_df(names(results_clean), function(name) {
  
  coef <- results_clean[[name]]$coef
  
  tibble(
    Time = x_seq,
    SVL = predict_model(name, coef, x_seq),
    model = name
  )
})

# Plot
ggplot(nat, aes(Time, SVL)) +
  geom_point(size = 2, alpha = 0.7) +
  
  geom_line(data = curve_df,
            aes(color = model),
            size = 1.2, alpha = 0.7) +
  
  theme_classic() +
  labs(
    x = "Time (years)",
    y = "SVL (cm)",
    title = "Nonlinear growth models comparison",
    color = "Model"
  )
