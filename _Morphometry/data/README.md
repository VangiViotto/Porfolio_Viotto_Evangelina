
# Data

## Overview

This folder contains simulated datasets used to reproduce the analyses presented in this repository.

The original datasets are not publicly available due to ethical and authorship restrictions, as they are part of ongoing and unpublished research.
To ensure transparency and reproducibility, synthetic data were generated based on the structure and statistical properties of the original data.

## Data simulation

Simulated datasets were created to:

* preserve the structure of the original data (variables, factors, formats)
* maintain biologically realistic patterns (e.g., shape variation, group effects)
* allow full reproducibility of the analytical workflow

These data **do not correspond to real individuals** and cannot be traced back to the original dataset.

## Files

### `simulated_metadata.csv`

Tabular dataset containing biological and sampling information for each individual.

**Main variables:**

* `Num_imagen`: unique identifier for each specimen
* `Individuo`: simulated biological ID (egg–nest structure)
* `Sexo`: sex of the individual (Male/Female)
* `Nest`: nest identity
* `Sitio`: sampling site
* Landmark completeness variables (`D_*`, `I_*`, `SD_*`) used for data filtering
* `total`: number of valid landmark observations

---

### `simulated_landmarks.TPS`

Landmark coordinates in TPS format used for geometric morphometric analyses.

* Contains 2D coordinates for each specimen
* Includes replicated digitizations per individual
* Shape variation was simulated to preserve realistic biological patterns, including structured variation among nests

---

## Notes

* These datasets are intended exclusively for demonstration and reproducibility purposes.
* All analyses in this repository can be run using these simulated data without modification.
* The simulation process ensures that results reflect realistic analytical scenarios while protecting sensitive data.

---
