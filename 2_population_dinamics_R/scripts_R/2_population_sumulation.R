# ============================================
# Population Dynamics Model (Caiman latirostris)
# ============================================

# Author: Evangelina Viotto
# Purpose: Simulate population dynamics using stage-structured matrices
# Approach: Life Stage Simulation Analysis (LSA)

# ============================================
# 1. Libraries
# ============================================

library(popbio)
library(ggplot2)

# ============================================
# 2. Helper functions
# ============================================


# Probability of remaining in the same stage
P <- function(p, di){
  p * ((1 - p^(di - 1)) / (1 - p^di))
}

# Probability of growing to next stage
G <- function(p, di){
  (p^di * (1 - p)) / (1 - p^di)
}

# Fecundity
Fec <- function(mn, sex, bre, supHU){
  mn * sex * bre * supHU
}

# ============================================
# 3. Fecundity from body size
# ============================================

# SVL → clutch size relationship
Nsvl <- function(svl){
  -6.77 + 0.5 * svl
}

# Size ranges (cm)
Fem_small <- seq(68, 78, 0.5)
Fem_large <- seq(78, 100, 0.5)

# Mean clutch size
mni  <- mean(Nsvl(Fem_small))
mnii <- mean(Nsvl(Fem_large))

# ============================================
# 4. Simulation settings
# ============================================

set.seed(123)

n_iter <- 1000   # iterations

# Stage duration (years)
TCI    <- 1
TCI2   <- 2
TCII   <- 6
TCIII  <- 8
TCIII2 <- 43

sex_ratio <- 0.5

# Storage
matrices <- vector("list", n_iter)
lambdas  <- numeric(n_iter)

# (opcional pero CLAVE para el segundo script)
vital_rates <- data.frame()

# ============================================
# 5. Simulation loop
# ============================================

for(i in 1:n_iter){
  
  # --- Survival ---
  SupHU3   <- betaval(0.41, 0.07)
  SupHU4   <- betaval(0.51, 0.07)
  SupCI    <- betaval(0.10, 0.02)
  SupCI2   <- betaval(0.60, 0.02)
  SupCII   <- betaval(0.87, 0.07)
  SupCIII  <- betaval(0.97, 0.08)
  SupCIII2 <- betaval(0.97, 0.05)
  
  # --- Transitions ---
  GI    <- G(SupCI, TCI)
  GI2   <- G(SupCI2, TCI2)
  GII   <- G(SupCII, TCII)
  GIII  <- G(SupCIII, TCIII)
  
  PI2   <- P(SupCI2, TCI2)
  PII   <- P(SupCII, TCII)
  PIII  <- P(SupCIII, TCIII)
  PIII2 <- P(SupCIII2, TCIII2)
  
  # --- Fecundity ---
  Fi  <- Fec(mni,  sex_ratio, 0.3, SupHU3)
  Fii <- Fec(mnii, sex_ratio, 0.7, SupHU4)
  
  # --- Matrix ---
  M <- matrix(c(
    0,   0,   0,   Fi,  Fii,
    GI,  PI2, 0,   0,   0,
    0,   GI2, PII, 0,   0,
    0,   0,   GII, PIII,0,
    0,   0,   0,   GIII,PIII2
  ), nrow = 5, byrow = TRUE)
  
  matrices[[i]] <- M
  lambdas[i] <- lambda(M)
  
  # --- Save parameters (CLAVE) ---
  vital_rates <- rbind(vital_rates, data.frame(
    SupHU3, SupHU4, SupCI, SupCI2, SupCII, SupCIII, SupCIII2,
    GI, GI2, GII, GIII,
    PI2, PII, PIII, PIII2,
    Fi, Fii,
    lambda = lambdas[i]
  ))
}

# ============================================
# 6. Save outputs (for next script)
# ============================================

write.csv(vital_rates, "vital_rates_simulated.csv", row.names = FALSE)

# ============================================
# 7. Quick visualization
# ============================================

ggplot(vital_rates, aes(x = lambda)) +
  geom_histogram(bins = 40, fill = "steelblue", color = "black") +
  theme_classic() +
  labs(
    title = "Distribution of population growth rate (λ)",
    x = "Lambda",
    y = "Frequency"
  )