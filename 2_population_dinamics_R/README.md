# Population Dynamics Model – Caiman latirostris

## Overview
Stage-structured population model to evaluate population dynamics under uncertainty.  
This project applies stochastic simulations and matrix population models to identify key drivers of population growth (λ).

---

## Approach
- Survival rates simulated using beta distributions  
- Fecundity estimated from body size (allometric relationship)  
- Lefkovitch transition matrices (5 life stages)  
- 5,000 stochastic simulations  
- Sensitivity (elasticity) and correlation analysis  

---

## Workflow
1. Parameter generation (`2_1_build_parameters.R`)
   - Simulates vital rates  
   - Builds transition matrices  
   - Saves model parameters  

2. Simulation and analysis (`2_2_simulation_analisis.R`)
   - Runs population projections  
   - Calculates λ, R0, generation time, damping ratio  
   - Performs elasticity and correlation analysis  
   - Generates figures and summary tables  


---

## Project structure

2_population_dinamics/
├── data/
│ ├── raw/
│ └── processed/
├── outputs/
│ ├── figures/
│ └── tables/
├── scripts/
│ ├── 2_1_build_parameters.R
│ └── 2_2_simulation_analisis.R
├── mean_matrix.csv
├── survival_parameters.csv
├── model_parameters.RData
└── README.md
---

## Outputs
- Distribution of population growth rate (λ)  
- Elasticity of vital rates  
- Stable stage structure  
- Correlation between parameters and λ  

---

## Key insights
- Population growth is mainly driven by adult survival  
- Early-life stages show higher variability but lower influence on λ  
- A substantial proportion of simulations results in λ < 1  

---

## Tools
- R  
- popbio  
- dplyr  
- ggplot2  

---

## Skills demonstrated
- Statistical modeling  
- Monte Carlo simulation  
- Data analysis and visualization  
- Sensitivity analysis  
- Reproducible workflows  

---

## Scientific background
This implementation is based on a stage-structured modeling approach developed in:

Viotto, E. D. V., Navarro, J. L., Simoncini, M. S., & Piña, C. I. (2023).  
Stage-based model of population dynamics and harvest of Broad-snouted caiman (*Caiman latirostris*) under different management scenarios.  
https://doi.org/10.15451/ec2023-01-12.01-1-20

---

## Author
Evangelina Viotto


## Project structure
