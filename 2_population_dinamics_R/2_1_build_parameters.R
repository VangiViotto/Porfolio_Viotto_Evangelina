 
# ============================================
# Population Dynamics Model (Caiman latirostris)
# ============================================

# Author: Evangelina Viotto
# Purpose: Simulate population dynamics using stage-structured matrices
# Approach: Life Stage Simulation Analysis (LSA)

# ============================================
# 1. Libraries
# ============================================

library(dplyr)
library(popbio)
setwd("E:/Documentos/mis_scripts")

#==============================
# 2. Global settings
#==============================
set.seed(568)

n_iter <- 5000  # number of stochastic simulations

#==============================
# 3. Model functions
#==============================

# Probability of remaining in the same stage
calc_P <- function(p, duration){
  p * ((1 - p^(duration - 1)) / (1 - p^duration))
}

# Probability of transitioning to the next stage
calc_G <- function(p, duration){
  (p^duration * (1 - p)) / (1 - p^duration)
}

# Fecundity function
calc_fecundity <- function(mean_clutch, sex_ratio, breeding_prop, hatch_survival){
  mean_clutch * sex_ratio * breeding_prop * hatch_survival
}

# Allometric relationship: body size → clutch size
clutch_size_from_svl <- function(svl){
  -6.77 + 0.5 * svl
}

#==============================
# 4. External data (survival rates)
#==============================

# Load survival data from other species
other_species <- read.csv("data/supotrasespecies.csv")

other_species <- other_species[, 2:6]

# Add additional data point (Green, 2010)
other_species <- rbind(other_species, c(0.10, 0.70, 0.85, 0.99, 0.99))

# Summary statistics
surv_sd <- apply(other_species, 2, sd)
surv_mean <- apply(other_species, 2, mean)

#==============================
# 5. Reproductive parameters
#==============================

# Class III females (smaller reproductive females)
female_class3 <- seq(68, 77.9, 0.5)
mean_clutch_c3 <- mean(clutch_size_from_svl(female_class3))

# Class III2 females (larger reproductive females)
female_class3_2 <- seq(78, 100, 0.5)
mean_clutch_c3_2 <- mean(clutch_size_from_svl(female_class3_2))

# Fixed parameters
sex_ratio <- 0.5
breeding_prop_c3 <- 0.3
breeding_prop_c3_2 <- 0.7

#==============================
# 6. Simulating vital rates
#==============================

SupHU3 <- SupHU4 <- SupCI <- SupCI2 <- SupCII <- SupCIII <- SupCIII2 <- numeric(n_iter)

for(i in 1:n_iter){
  SupHU3[i]   <- popbio::betaval(0.41, 0.07)
  SupHU4[i]   <- popbio::betaval(0.51, 0.07)
  SupCI[i]    <- popbio::betaval(0.10, 0.02)
  SupCI2[i]   <- popbio::betaval(0.60, 0.02)
  SupCII[i]   <- popbio::betaval(0.87, 0.07)
  SupCIII[i]  <- popbio::betaval(surv_mean[4], surv_sd[4])
  SupCIII2[i] <- popbio::betaval(surv_mean[4], surv_sd[4])
}

#==============================
# 7. Stage durations
#==============================

T_CI    <- 1
T_CI2   <- 2
T_CII   <- 6
T_CIII  <- 8
T_CIII2 <- 43

#==============================
# 8. Transition matrices
#==============================

transition_matrices <- vector("list", n_iter)

for(i in 1:n_iter){
  
  # Transition probabilities
  G1   <- calc_G(SupCI[i], T_CI)
  G2   <- calc_G(SupCI2[i], T_CI2)
  G3   <- calc_G(SupCII[i], T_CII)
  G4   <- calc_G(SupCIII[i], T_CIII)
  
  # Persistence probabilities
  P2   <- calc_P(SupCI2[i], T_CI2)
  P3   <- calc_P(SupCII[i], T_CII)
  P4   <- calc_P(SupCIII[i], T_CIII)
  P5   <- calc_P(SupCIII2[i], T_CIII2)
  
  # Fecundity
  F4 <- calc_fecundity(mean_clutch_c3, sex_ratio, breeding_prop_c3, SupHU3[i])
  F5 <- calc_fecundity(mean_clutch_c3_2, sex_ratio, breeding_prop_c3_2, SupHU4[i])
  
  # Leslie/Lefkovitch matrix
  mat <- matrix(c(
    0,   0,   0,   F4,  F5,
    G1,  P2,  0,   0,   0,
    0,   G2,  P3,  0,   0,
    0,   0,   G3,  P4,  0,
    0,   0,   0,   G4,  P5
  ), byrow = TRUE, nrow = 5)
  
  transition_matrices[[i]] <- mat
}

#==============================
# 9. Mean matrix
#==============================

mean_matrix <- Reduce("+", transition_matrices) / n_iter

#==============================
# 10. Parameter dataset
#==============================

parameter_df <- data.frame(
  SupHU3, SupHU4, SupCI, SupCI2, SupCII, SupCIII, SupCIII2
)

mean_parameters <- c(
  apply(parameter_df, 2, mean),
  breeding_prop_c3,
  breeding_prop_c3_2,
  mean_clutch_c3,
  mean_clutch_c3_2,
  sex_ratio
)

#==============================
# 11. Save outputs
#==============================

dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)

save(
  transition_matrices,
  parameter_df,
  mean_parameters,
  mean_matrix,
  file = "data/processed/model_parameters.RData"
)

write.csv(parameter_df, "data/processed/survival_parameters.csv", row.names = FALSE)
write.csv(mean_matrix, "data/processed/mean_matrix.csv")

