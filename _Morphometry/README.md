# 01_Morfometría/ morphometrics

## Geometric Morphometric Analysis

This module performs a geometric morphometric analysis to quantify shape variation and evaluate the effects of biological and environmental factors.

### Overview

Landmark-based morphometrics are used to:

* quantify shape variation
* test differences among groups (sex, nest)
* evaluate allometric effects (shape ~ size)

### Data

* Landmark data: TPS format (`SD.tps`)
* Metadata: Excel file (`Datos_todos.xlsx`)
* Replicates: 3 digitizations per individual

### Workflow

1. Data import and cleaning
2. Generalized Procrustes Analysis (GPA)
3. Averaging of landmark replicates
4. Principal Component Analysis (PCA)
5. Shape analysis using Procrustes ANOVA
6. Canonical Variate Analysis (CVA)
7. Visualization of morphospace

### Outputs

* PCA plot (shape variation)
* CVA plot (group differentiation)
* Statistical models:

  * Shape ~ Sex
  * Shape ~ Nest
  * Shape ~ Size (allometry)

### Requirements

R packages:

* geomorph
* readxl
* dplyr
* ggplot2
* MASS
* viridis

### Notes

* Shape is analyzed independently of size, position, and orientation after GPA.
* CVA is performed on principal components to reduce dimensionality and noise.
* This workflow is suitable for high-replicability morphometric datasets.

---

