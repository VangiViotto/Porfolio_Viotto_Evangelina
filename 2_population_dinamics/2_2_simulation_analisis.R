
# ============================================
# Population Dynamics Model (Caiman latirostris)
# ============================================

# Author: Evangelina Viotto
# Purpose: Simulate population dynamics using stage-structured matrices
# Approach: Life Stage Simulation Analysis (LSA)

#==============================
# 1. Libraries
#==============================
library(ggplot2)
library(dplyr)
library(popbio)

#==============================
# 2. Load model parameters
#==============================
load("data/processed/model_parameters.RData")

n_iter <- length(transition_matrices)

#==============================
# 3. Run stochastic simulations
#==============================

results <- lapply(transition_matrices, function(mat){
  
  proj <- popbio::pop.projection(mat, c(10,10,10,10,10), 100)
  
  list(
    lambda      = proj$lambda,
    elasticity  = popbio::elasticity(mat),
    sensitivity = popbio::sensitivity(mat),
    repro_rate  = popbio::net.reproductive.rate(mat),
    gen_time    = popbio::generation.time(mat),
    damping     = popbio::damping.ratio(mat),
    stable_dist = popbio::stable.stage(mat)
  )
})

#==============================
# 4. Build main dataset
#==============================

lambda      <- sapply(results, function(x) x$lambda)
repro_rate  <- sapply(results, function(x) x$repro_rate)
gen_time    <- sapply(results, function(x) x$gen_time)
damping     <- sapply(results, function(x) x$damping)

df <- data.frame(
  lambda = lambda,
  repro_rate = repro_rate,
  generation_time = gen_time,
  damping_ratio = damping
)

# Add growth classification
df$growth <- ifelse(df$lambda > 1, "Growing", "Declining")

#==============================
# 5. Summary statistics
#==============================

summary(df)

prop_decline <- mean(df$lambda < 1)

cat("Proportion of declining populations:", round(prop_decline, 3), "\n")

#==============================
# 6. Lambda distribution
#==============================

p_lambda <- ggplot(df, aes(x = lambda)) +
  geom_histogram(bins = 50, fill = "white", color = "black") +
  geom_vline(xintercept = 1, color = "red", linewidth = 1) +
  geom_vline(xintercept = mean(lambda), color = "blue", linewidth = 1) +
  labs(
    title = "Distribution of Population Growth Rate (λ)",
    x = "Lambda (λ)",
    y = "Frequency"
  ) +
  theme_minimal()

p_lambda

#==============================
# 7. Elasticity analysis
#==============================

#==============================
# Elasticity extraction (biologically meaningful)
#==============================

el_G1 <- sapply(results, function(x) x$elasticity[2,1])
el_G2 <- sapply(results, function(x) x$elasticity[3,2])
el_G3 <- sapply(results, function(x) x$elasticity[4,3])
el_G4 <- sapply(results, function(x) x$elasticity[5,4])

el_P2 <- sapply(results, function(x) x$elasticity[2,2])
el_P3 <- sapply(results, function(x) x$elasticity[3,3])
el_P4 <- sapply(results, function(x) x$elasticity[4,4])
el_P5 <- sapply(results, function(x) x$elasticity[5,5])

el_F4 <- sapply(results, function(x) x$elasticity[1,4])
el_F5 <- sapply(results, function(x) x$elasticity[1,5])

# Combine
Elasticity <- c(el_G1, el_G2, el_G3, el_G4,
                el_P2, el_P3, el_P4, el_P5,
                el_F4, el_F5)

Parameter <- c(
  rep("G1", n_iter), rep("G2", n_iter), rep("G3", n_iter), rep("G4", n_iter),
  rep("P2", n_iter), rep("P3", n_iter), rep("P4", n_iter), rep("P5", n_iter),
  rep("F4", n_iter), rep("F5", n_iter)
)

elas_df_clean <- data.frame(Elasticity, Parameter)


p_elas <- ggplot(elas_df_clean, aes(x = Parameter, y = Elasticity)) +
  geom_boxplot(fill = "white", color = "black") +
  labs(
    title = "Elasticity of Population Growth Rate (λ)",
    x = "Vital rate",
    y = "Elasticity"
  ) +
  theme_classic()

p_elas


#==============================
# 8. Correlation analysis
#==============================

# Combine lambda with input parameters
full_data <- cbind(df, parameter_df)

cor_results <- sapply(parameter_df, function(x){
  cor(df$lambda, x, method = "pearson")
})

cor_df <- data.frame(
  variable = names(cor_results),
  correlation = cor_results
)

cor_df <- cor_df %>%
  arrange(desc(abs(correlation)))

cor_df

#==============================
# 9. Stable stage structure
#==============================

stable_list <- lapply(results, function(x) x$stable_dist)
stable_mat <- do.call(rbind, stable_list)

stable_df <- as.data.frame(stable_mat)
colnames(stable_df) <- paste0("Stage_", 1:ncol(stable_df))

stable_long <- tidyr::pivot_longer(
  stable_df,
  cols = everything(),
  names_to = "stage",
  values_to = "proportion"
)

p_stable <- ggplot(stable_long, aes(x = proportion)) +
  geom_histogram(bins = 50, fill = "grey", color = "black") +
  facet_wrap(~stage, scales = "free") +
  labs(
    title = "Stable Stage Distribution",
    x = "Proportion",
    y = "Frequency"
  ) +
  theme_minimal()

p_stable

#==============================
# 10. Save outputs
#==============================

dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)

ggsave("outputs/figures/lambda_distribution.png", p_lambda, width = 6, height = 4)
ggsave("outputs/figures/elasticity_boxplot.png", p_elas, width = 7, height = 4)
ggsave("outputs/figures/stable_structure.png", p_stable, width = 8, height = 5)

write.csv(df, "outputs/tables/simulation_summary.csv", row.names = FALSE)
write.csv(cor_df, "outputs/tables/correlations_lambda.csv", row.names = FALSE)

