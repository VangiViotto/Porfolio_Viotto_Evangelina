#  Data

## Description
This folder contains the dataset used for the survival analysis.

## Files

- `surv_data.csv`: telemetry dataset including time-to-event data, survival status, and biological variables.

## Variables (main)

- `time`: monitoring duration  
- `event`: survival status (1 = death, 0 = censored)  
- `year`: grouping variable  
- `svl0`: initial body size  
- `mass0`: initial body mass  

 Data may be simulated or modified to preserve confidentiality.

## Notes
The dataset is structured for survival analysis and can be directly used to build Kaplan-Meier models and Cox regression models.
