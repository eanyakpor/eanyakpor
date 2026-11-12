# 01_correlation.R
# Correlation analysis: visual (scatterplots) + numerical (Pearson / Spearman)

library(tidyverse)

if (!exists("tracks")) source("R/00_setup_and_clean.R")

quant <- tracks %>%
  select(
    popularity, danceability, energy, loudness, acousticness,
    instrumentalness, valence, tempo, duration_min, speechiness, liveness
  )

# --- Numerical correlation -------------------------------------------------
pearson_mat <- cor(quant, use = "complete.obs", method = "pearson")
spearman_mat <- cor(quant, use = "complete.obs", method = "spearman")
print(round(pearson_mat, 3))

# One pair with a formal test (example)
cor.test(tracks$energy, tracks$loudness, method = "pearson")
cor.test(tracks$energy, tracks$acousticness, method = "spearman")

# --- Heatmap ---------------------------------------------------------------
pearson_long <- as_tibble(pearson_mat, rownames = "var1") %>%
  pivot_longer(-var1, names_to = "var2", values_to = "r")

p_heat <- ggplot(pearson_long, aes(var1, var2, fill = r)) +
  geom_tile(color = "white") +
  geom_text(aes(label = sprintf("%.2f", r)), size = 3) +
  scale_fill_gradient2(low = "#3b6ba5", mid = "white", high = "#c44e52", midpoint = 0) +
  labs(
    title = "Pearson correlations among audio features",
    x = NULL, y = NULL, fill = "r"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

print(p_heat)
ggsave("output/corr_heatmap.png", p_heat, width = 9, height = 7)

# --- Scatterplots (use a 3,000-row draw so points are readable) ------------
set.seed(42)
plot_df <- tracks %>% sample_n(3000)

p_energy_loud <- ggplot(plot_df, aes(energy, loudness)) +
  geom_point(alpha = 0.25, size = 1.4) +
  geom_smooth(method = "lm", se = TRUE, color = "#c44e52") +
  labs(
    title = "Energy vs loudness",
    subtitle = "Expected strong positive relationship",
    x = "Energy (0-1)", y = "Loudness (dB)"
  ) +
  theme_minimal()

p_energy_acous <- ggplot(plot_df, aes(energy, acousticness)) +
  geom_point(alpha = 0.25, size = 1.4) +
  geom_smooth(method = "lm", se = TRUE, color = "#c44e52") +
  labs(
    title = "Energy vs acousticness",
    subtitle = "Expected strong negative relationship",
    x = "Energy (0-1)", y = "Acousticness (0-1)"
  ) +
  theme_minimal()

p_dance_valence <- ggplot(plot_df, aes(danceability, valence)) +
  geom_point(alpha = 0.25, size = 1.4) +
  geom_smooth(method = "lm", se = TRUE, color = "#c44e52") +
  labs(
    title = "Danceability vs valence",
    x = "Danceability", y = "Valence (positivity)"
  ) +
  theme_minimal()

p_pop_energy <- ggplot(plot_df, aes(energy, popularity)) +
  geom_point(alpha = 0.25, size = 1.4) +
  geom_smooth(method = "lm", se = TRUE, color = "#c44e52") +
  labs(
    title = "Energy vs popularity",
    subtitle = "Weaker than the audio-feature pairs; good contrast in a write-up",
    x = "Energy", y = "Popularity (0-100)"
  ) +
  theme_minimal()

print(p_energy_loud)
print(p_energy_acous)
print(p_dance_valence)
print(p_pop_energy)

ggsave("output/scatter_energy_loudness.png", p_energy_loud, width = 7, height = 5)
ggsave("output/scatter_energy_acousticness.png", p_energy_acous, width = 7, height = 5)
ggsave("output/scatter_dance_valence.png", p_dance_valence, width = 7, height = 5)
ggsave("output/scatter_energy_popularity.png", p_pop_energy, width = 7, height = 5)

# Hexbin alternative when overplotting hides the pattern
if (requireNamespace("hexbin", quietly = TRUE)) {
  p_hex <- ggplot(tracks, aes(energy, acousticness)) +
    geom_hex(bins = 40) +
    scale_fill_viridis_c() +
    labs(title = "Energy vs acousticness (all 20,000 tracks)", x = "Energy", y = "Acousticness") +
    theme_minimal()
  print(p_hex)
  ggsave("output/hex_energy_acousticness.png", p_hex, width = 7, height = 5)
}

if (!exists("genre_compare")) source("R/00_setup_and_clean.R")
set.seed(42)
genre_plot <- genre_compare %>% sample_n(min(3000, nrow(genre_compare)))
p_genre <- ggplot(genre_plot, aes(valence, danceability, color = genre_family)) +
  geom_point(alpha = 0.35, size = 1.3) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "Danceability vs valence by genre family",
    x = "Valence", y = "Danceability", color = "Genre"
  ) +
  theme_minimal()
print(p_genre)
ggsave("output/scatter_dance_valence_genre.png", p_genre, width = 8, height = 5)
