# ============================================================
# Title: Size Frequency Analysis and Cohort Identification
# Author: Evangelina Viotto
# Date: 2026
# Objective:
# This script analyzes size-frequency distributions of individuals
# and identifies potential cohorts using Gaussian mixture models.
# ============================================================

rm(list = ls())

# -------------------------------
# Libraries
# -------------------------------
library(tidyverse)
library(mixtools)

# -------------------------------
# 1. Data loading
# -------------------------------
data_path <- "data/CIPromediosadultosPyWyPYprom.csv"

ci <- read.csv(data_path, sep = ",", dec = ".")

# -------------------------------
# 2. Data cleaning
# -------------------------------
ci_clean <- ci %>%
  slice(-c(1:23,24,25,26,28:30,31:33,35,38:41,45:49,52:54,57:60,62,63,66:68,69))

wy <- ci_clean %>%
  filter(Inicial == "Wy")

# -------------------------------
# 3. Exploratory analysis
# -------------------------------
ggplot(wy, aes(x = SVL)) +
  geom_histogram(binwidth = 1, fill = "grey70", color = "black") +
  theme_classic() +
  labs(x = "SVL (cm)", y = "Frequency")

# -------------------------------
# 4. Gaussian mixture model
# -------------------------------
set.seed(123)
wy_clean <- wy %>%
  filter(!is.na(SVL), is.finite(SVL))

 
mix_model <- normalmixEM(wy_clean$SVL, k = 3)
 

summary(mix_model)
plot(mix_model, which = 2)

# -------------------------------
# 5. Intersection between distributions
# -------------------------------
get_intersection <- function(mu1, mu2, sd1, sd2) {
  xs <- seq(mu1, mu2, by = 0.001)
  f1 <- dnorm(xs, mu1, sd1)
  f2 <- dnorm(xs, mu2, sd2)
  xs[which.min(abs(f1 - f2))]
}

limits <- map_dbl(1:(length(mix_model$mu) - 1), function(i) {
  get_intersection(
    mix_model$mu[i],
    mix_model$mu[i + 1],
    mix_model$sigma[i],
    mix_model$sigma[i + 1]
  )
})

# -------------------------------
# 6. Cohort classification
# -------------------------------
wy <- wy %>%
  mutate(
    cohort = case_when(
      SVL < limits[1] ~ "Cohort 1",
      SVL < limits[2] ~ "Cohort 2",
      TRUE ~ "Cohort 3"
    )
  )

# -------------------------------
# 7. Final visualization
# -------------------------------
ggplot(wy, aes(SVL, fill = cohort)) +
  geom_histogram(binwidth = 1, color = "black") +
  theme_classic()



