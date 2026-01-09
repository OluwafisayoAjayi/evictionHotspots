# evictionHotspots

Spatial identification of eviction hotspots using Moran’s I and Local Indicators of Spatial Association (LISA).

## Overview

`evictionHotspots` is an R package designed to identify and visualize spatial clusters of eviction intensity.  
It computes Global Moran’s I to assess overall spatial autocorrelation and Local Moran’s I (LISA) to detect statistically significant eviction hotspots.

The package is intended for researchers, policymakers, and analysts working in housing, urban economics, and spatial analysis.

---

## Methodology

1. Spatial data are provided as an `sf` object.
2. Spatial weights are constructed using *k*-nearest neighbors.
3. Global Moran’s I tests for overall spatial autocorrelation.
4. Local Moran’s I identifies statistically significant local clusters.
5. Hotspots are defined as locations with:
   - Positive Local Moran’s I
   - p-value ≤ 0.05

---

## Installation

Install the development version from GitHub:

```r
install.packages("remotes")
remotes::install_github("OluwafisayoAjayi/evictionHotspots")
```

install.packages("remotes")
remotes::install_github("OluwafisayoAjayi/evictionHotspots")
