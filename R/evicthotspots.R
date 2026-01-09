#' Calculate eviction hotspots
#'
#' Computes Global Moran's I and Local Moran's I (LISA) for a numeric variable
#' in an sf object. Creates k-nearest-neighbor weights and flags hotspots
#' based on local Moran p-values.
#'
#' @param data An sf object containing geometry and eviction data.
#' @param variable Character. Column name of the numeric eviction variable.
#' @param k Integer. Number of nearest neighbors (auto-reduced for small n).
#' @return A list with `global_moran` (htest) and `data` (sf with LISA results).
#' @export
calculate_hotspots <- function(data, variable, k = 4) {
  if (!inherits(data, "sf")) stop("`data` must be an sf object.")
  if (!is.character(variable) || length(variable) != 1) stop("`variable` must be a single column name (character).")
  if (!variable %in% names(data)) stop("`variable` not found in `data`.")
  if (!is.numeric(data[[variable]])) stop("`data[[variable]]` must be numeric.")

  # Coordinates: points -> direct; polygons -> centroids
  geom <- sf::st_geometry(data)
  if (any(sf::st_geometry_type(geom) %in% c("POLYGON", "MULTIPOLYGON", "LINESTRING", "MULTILINESTRING"))) {
    coords <- sf::st_coordinates(sf::st_centroid(geom))
  } else {
    coords <- sf::st_coordinates(geom)
  }

  n <- nrow(data)
  if (n < 3) stop("Need at least 3 features to compute neighbors.")
  k <- as.integer(k)
  if (k < 1) stop("`k` must be >= 1.")
  k <- min(k, n - 1)

  # Rule-of-thumb: keep k <= floor(n/3) for stability in small samples
  k_max <- max(1L, floor(n / 3))
  if (k > k_max) {
    warning(sprintf("Reducing k from %d to %d because n=%d is small.", k, k_max, n))
    k <- k_max
  }

  nb <- spdep::knn2nb(spdep::knearneigh(coords, k = k))
  lw <- spdep::nb2listw(nb, style = "W", zero.policy = TRUE)

  x <- data[[variable]]

  global_moran <- spdep::moran.test(x, lw, zero.policy = TRUE)

  local_moran <- spdep::localmoran(x, lw, zero.policy = TRUE)

  # localmoran columns vary; compute p-values from Z.Ii (always present)
  z <- local_moran[, "Z.Ii"]
  p <- 2 * stats::pnorm(-abs(z))

  data$local_moran_I <- local_moran[, "Ii"]
  data$local_moran_z <- z
  data$local_moran_p <- p
  data$hotspot <- ifelse(!is.na(p) & p <= 0.05 & data$local_moran_I > 0, "Hotspot", "Not Hotspot")

  list(global_moran = global_moran, data = data)
}


#' Plot eviction hotspots
#'
#' Visualize hotspots from an sf object using either a static map (tmap)
#' or an interactive map (leaflet).
#'
#' @param data An sf object containing a hotspot column (e.g., "hotspot").
#' @param hotspot_column Character. Column name with hotspot labels.
#' @param interactive Logical. If TRUE, uses leaflet; otherwise uses tmap.
#' @export
plot_hotspots <- function(data, hotspot_column = "hotspot", interactive = FALSE) {
  if (!inherits(data, "sf")) stop("`data` must be an sf object.")
  if (!is.character(hotspot_column) || length(hotspot_column) != 1) stop("`hotspot_column` must be a single column name.")
  if (!hotspot_column %in% names(data)) stop("`hotspot_column` not found in `data`.")

  if (!interactive) {
    tmap::tm_shape(data) +
      tmap::tm_dots(col = hotspot_column, title = "Hotspots")
  } else {
    leaflet::leaflet(data) |>
      leaflet::addTiles() |>
      leaflet::addCircleMarkers(
        radius = 5,
        color = "black",
        weight = 1,
        fillColor = ~ifelse(data[[hotspot_column]] == "Hotspot", "red", "gray"),
        fillOpacity = 0.8,
        popup = ~paste("Hotspot:", data[[hotspot_column]])
      )
  }
}

