# Growth Modeling & Cohort Detection in *Caiman latirostris*

**Author:** Evangelina Viotto  
**Year:** 2020  

## Objective

This project implements two analytical workflows:

- Cohort identification from size-frequency distributions  
- Nonlinear growth model fitting and comparison  

The scripts are adapted from analyses used in:  
Viotto, E. V., Navarro, J. L., & Piña, C. I. (2020). *South American Journal of Herpetology*.  

---

## Project Structure

```
3_nonlinear_growth_models_R/
├── scripts/
│   ├── 1_size_frequency_cohorts.R
│   └── 2_growth_models_comparison.R
├── data/
└── README.md
```

---

## Data

Original data cannot be shared.

- Script 1 uses simulated data with similar structure and distributions  
- Script 2 uses masked real data with added noise to preserve statistical properties  

---

## Scripts

### 1. Cohort Detection

- Data cleaning and filtering  
- Size-frequency analysis (SVL)  
- Gaussian mixture models  
- Cohort classification  

### 2. Growth Models

- Logistic, Gompertz, and Von Bertalanffy models  
- Nonlinear fitting (`nls`)  
- Model comparison (AIC, BIC)  
- Growth curve visualization  

---

## Key Skills

- Data wrangling (`tidyverse`)  
- Nonlinear modeling  
- Model selection  
- Functional programming (`purrr`)  
- Reproducible workflows  

---

## Notes

- A reduced set of models is used for clarity and robustness  
- Simulated data were designed to maintain realistic variance and structure  
- Code emphasizes stability and reproducibility  

---

## Extensions
 
- Bayesian approaches  
- Mixed-effects models  
