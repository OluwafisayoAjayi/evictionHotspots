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

## Usage

```r
library(evictionHotspots)
library(sf)

# Example data
example_data <- st_as_sf(
  data.frame(
    id = 1:10,
    evictions = sample(1:100, 10),
    lon = runif(10, -100, -90),
    lat = runif(10, 30, 40)
  ),
  coords = c("lon", "lat"),
  crs = 4326
)

# Identify hotspots
res <- calculate_hotspots(example_data, "evictions")

# View Global Moran’s I
res$global_moran

# Plot hotspots
plot_hotspots(res$data)
