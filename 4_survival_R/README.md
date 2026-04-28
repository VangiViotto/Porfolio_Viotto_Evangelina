#  Survival Analysis – Telemetry Data

##  Overview
This project applies survival analysis techniques to telemetry data to estimate survival probability over time and evaluate differences between groups.

The analysis includes Kaplan-Meier survival curves, log-rank tests, and Cox proportional hazards models.

---

##  Data
The dataset contains:

- `time`: monitoring duration  
- `event`: survival status (1 = death, 0 = censored)  
- `year`: grouping variable  
- `svl0`: initial body size  
- `mass0`: initial body mass  

 Data are simulated or modified to preserve confidentiality.

---

##  Methods

### Survival Analysis
- Kaplan-Meier estimator to model survival probability  
- Log-rank test to compare survival between groups  

### Modeling
- Cox proportional hazards model to evaluate the effect of covariates (year, size, mass)  

### Diagnostics
- Proportional hazards assumption tested using Schoenfeld residuals  

---
## Key insights 

- Which group survives more?
- Which variables increase risk?
- What does this mean in simple terms?
---

##  Results
- Survival probability varies between years  
- Cox model identifies biological and temporal variables influencing survival  
- Model diagnostics support the validity of the proportional hazards assumption  

---

##  Tools
- R  
- survival  
- survminer  
- dplyr  
- ggplot2  

---

##  Project Structure

```
survival_analysis/
├── data/          # Raw dataset
├── outputs/       # Generated figures and results
├── scripts/       # Analysis scripts
└── README.md      # Project documentation
```

---

## 🚀 How to run

1. Place the dataset in `data/surv_data.csv`  
2. Run the script:

 
##Output
- Survival curves (outputs/survival_curve.png)
- Statistical test results printed in console

---
##Notes

This project demonstrates the application of survival analysis to real-world biological data, including data cleaning, statistical modeling, and result visualization.

The workflow is fully reproducible and follows best practices for data analysis projects.


##Publication

This project is based on:

**Viotto et al. (2022)**  
Winter survivorship of hatchling broad-snouted caimans (*Caiman latirostris*) in Argentina  
*Ethnobiology and Conservation, 11*  
https://doi.org/10.15451/ec2022-07-11.18-1-13
