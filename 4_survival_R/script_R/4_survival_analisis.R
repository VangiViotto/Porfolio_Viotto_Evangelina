# ==========================================
# Survival Analysis – Telemetry Data
# ==========================================

# Libraries
library(survival)
library(survminer)
library(dplyr)
library(ggplot2)
library(janitor)

 # ==========================================
# Load data
# ==========================================
Su_dat <- read.csv("data/surv_data.csv")

# ==========================================
# Data cleaning
# ==========================================

# Clean column names (snake_case)
Su_dat <- Su_dat %>%
  clean_names()

# Rename key variables (adjust if needed)
 

# Convert types
Su_dat <- Su_dat %>%
  mutate(
    year = as.factor(year),
    event = as.numeric(event2)
  )

# ==========================================
# Survival object
# ==========================================
surv_object <- Surv(time = Su_dat$time, event = Su_dat$event2)

# ==========================================
# Kaplan-Meier model
# ==========================================
km_model <- survfit(surv_object ~ year, data = Su_dat)

# ==========================================
# Log-rank test
# ==========================================
logrank_test <- survdiff(surv_object ~ year, data = Su_dat)

print(logrank_test)

# ==========================================
# Plot survival curves
# ==========================================
plot <- ggsurvplot(
  km_model,
  data = Su_dat,
  pval = TRUE,
  conf.int = TRUE,
  risk.table = TRUE,
  legend.title = "Year",
  xlab = "Time",
  ylab = "Survival probability",
  palette =c("#2C3E50", "#95A5A6"),
  ggtheme = theme_classic(),
  risk.table.y.text.col = TRUE,
  risk.table.height = 0.25
)

plot$plot <- plot$plot +
  theme(
    text = element_text(size = 12),
    legend.position = "top"
  )

print(plot)

# Save plot
ggsave(
  "outputs/survival_curve.png",
  plot = plot$plot,
  width = 8,
  height = 6,
  dpi = 300
)
# ==========================================
# Cox proportional hazards model
# ==========================================
cox_model <- coxph(surv_object ~ year + svl0  + mass0, data = Su_dat)

summary(cox_model)

# ==========================================
# Model diagnostics
# ==========================================
cox_test <- cox.zph(cox_model)
print(cox_test)

# Optional plot
plot(cox_test)

