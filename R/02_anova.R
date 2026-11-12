# 02_anova.R
# One-way ANOVA with at least three groups, plus assumption checks.
# Optional two-way ANOVA is included at the bottom.

library(tidyverse)

if (!exists("tracks")) source("R/00_setup_and_clean.R")

# Recommended primary model (genre):
# H0: mean danceability is the same for Afrobeats, Hip hop, Latin, Pop, Rock,
#     and Classical
# Ha: at least one genre family has a different mean danceability
#
# Tracks.csv has no genre column. Genre comes from the primary artist's
# Spotify tags. This 2021 dump has no literal "afrobeats" label; the
# Afrobeats bucket is afropop, nigerian pop, azonto, afrobeat, etc.
# See data/codebook.md.
#
# Backup: acousticness ~ era (three time groups), still in this script.

if (!exists("genre_compare")) source("R/00_setup_and_clean.R")

anova_df <- genre_compare

# --- Genre ANOVA visuals ---------------------------------------------------
p_box <- ggplot(anova_df, aes(genre_family, danceability, fill = genre_family)) +
  geom_boxplot(outlier.alpha = 0.2) +
  stat_summary(fun = mean, geom = "point", shape = 23, size = 3, fill = "white") +
  labs(
    title = "Danceability by genre family",
    subtitle = "White diamonds = group means. Afrobeats sits between Latin/Hip hop and Rock.",
    x = "Genre family", y = "Danceability (0-1)"
  ) +
  theme_minimal() +
  theme(legend.position = "none")
print(p_box)
ggsave("output/anova_boxplot_genre.png", p_box, width = 8, height = 5)

p_violin <- ggplot(anova_df, aes(genre_family, danceability, fill = genre_family)) +
  geom_violin(trim = TRUE) +
  geom_boxplot(width = 0.12, outlier.shape = NA) +
  labs(title = "Distribution of danceability by genre", x = "Genre family", y = "Danceability") +
  theme_minimal() +
  theme(legend.position = "none")
print(p_violin)
ggsave("output/anova_violin_genre.png", p_violin, width = 8, height = 5)

p_ci <- ggplot(anova_df, aes(genre_family, danceability)) +
  stat_summary(fun = mean, geom = "point", size = 3) +
  stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0.15) +
  labs(
    title = "Mean danceability with 95% CI",
    x = "Genre family", y = "Mean danceability"
  ) +
  theme_minimal()
print(p_ci)
ggsave("output/anova_means_ci_genre.png", p_ci, width = 8, height = 5)

fit <- aov(danceability ~ genre_family, data = anova_df)
print(summary(fit))
ss <- summary(fit)[[1]]
eta_sq <- ss[1, "Sum Sq"] / sum(ss[, "Sum Sq"])
cat("Eta-squared:", round(eta_sq, 3), "\n")
print(TukeyHSD(fit))

qq_df <- tibble(residual = residuals(fit))
p_qq <- ggplot(qq_df, aes(sample = residual)) +
  stat_qq() +
  stat_qq_line() +
  labs(title = "QQ plot of genre-ANOVA residuals") +
  theme_minimal()
print(p_qq)
ggsave("output/anova_qq_genre.png", p_qq, width = 6, height = 5)

if (requireNamespace("car", quietly = TRUE)) {
  print(car::leveneTest(danceability ~ genre_family, data = anova_df))
} else {
  print(bartlett.test(danceability ~ genre_family, data = anova_df))
}
print(oneway.test(danceability ~ genre_family, data = anova_df, var.equal = FALSE))

# --- Backup ANOVA: acousticness by era -------------------------------------
era_df <- tracks %>%
  select(acousticness, energy, popularity, era, decade_label, energy_level, mode_label)

p_box_era <- ggplot(era_df, aes(era, acousticness, fill = era)) +
  geom_boxplot(outlier.alpha = 0.2) +
  stat_summary(fun = mean, geom = "point", shape = 23, size = 3, fill = "white") +
  labs(
    title = "Acousticness by era (backup ANOVA)",
    subtitle = "White diamonds = group means",
    x = "Era", y = "Acousticness (0-1)"
  ) +
  theme_minimal() +
  theme(legend.position = "none")
print(p_box_era)
ggsave("output/anova_boxplot_era.png", p_box_era, width = 7, height = 5)

fit_era <- aov(acousticness ~ era, data = era_df)
print(summary(fit_era))
print(TukeyHSD(fit_era))
print(oneway.test(acousticness ~ era, data = era_df, var.equal = FALSE))

# --- Alternative 3-group ANOVA you can swap in -----------------------------
# energy ~ energy wait that's circular.
# danceability by energy_level:
alt <- aov(danceability ~ energy_level, data = tracks)
print(summary(alt))
print(TukeyHSD(alt))

# --- Optional two-way ANOVA ------------------------------------------------
# H0_era: no era effect on energy
# H0_mode: no mode effect on energy
# H0_int: era and mode do not interact
fit2 <- aov(energy ~ era * mode_label, data = tracks)
print(summary(fit2))

p_int <- ggplot(tracks, aes(era, energy, fill = mode_label)) +
  geom_boxplot(position = position_dodge(width = 0.8), outlier.alpha = 0.15) +
  labs(
    title = "Two-way ANOVA visual: energy by era and mode",
    x = "Era", y = "Energy", fill = "Mode"
  ) +
  theme_minimal()
print(p_int)
ggsave("output/anova_twoway_energy.png", p_int, width = 8, height = 5)
