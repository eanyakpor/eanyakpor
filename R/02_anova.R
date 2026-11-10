# 02_anova.R
# One-way ANOVA with at least three groups, plus assumption checks.
# Optional two-way ANOVA is included at the bottom.

library(tidyverse)

if (!exists("tracks")) source("R/00_setup_and_clean.R")

# Recommended primary model:
# H0: mean acousticness is the same across the three eras
# Ha: at least one era has a different mean acousticness
#
# Acousticness is a good outcome here because recorded music became less
# acoustic over the 20th century. Popularity also works, but Spotify
# popularity is biased toward recent tracks.

anova_df <- tracks %>%
  select(acousticness, energy, popularity, era, decade_label, energy_level, mode_label)

# --- Visual: boxplot + mean ------------------------------------------------
p_box <- ggplot(anova_df, aes(era, acousticness, fill = era)) +
  geom_boxplot(outlier.alpha = 0.2) +
  stat_summary(fun = mean, geom = "point", shape = 23, size = 3, fill = "white") +
  labs(
    title = "Acousticness by era",
    subtitle = "White diamonds = group means",
    x = "Era", y = "Acousticness (0-1)"
  ) +
  theme_minimal() +
  theme(legend.position = "none")
print(p_box)
ggsave("output/anova_boxplot_era.png", p_box, width = 7, height = 5)

p_violin <- ggplot(anova_df, aes(era, acousticness, fill = era)) +
  geom_violin(trim = TRUE) +
  geom_boxplot(width = 0.12, outlier.shape = NA) +
  labs(title = "Distribution of acousticness by era", x = "Era", y = "Acousticness") +
  theme_minimal() +
  theme(legend.position = "none")
print(p_violin)
ggsave("output/anova_violin_era.png", p_violin, width = 7, height = 5)

# Mean + 95% CI (great for the write-up)
p_ci <- ggplot(anova_df, aes(era, acousticness)) +
  stat_summary(fun = mean, geom = "point", size = 3) +
  stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0.15) +
  labs(
    title = "Mean acousticness with 95% CI",
    x = "Era", y = "Mean acousticness"
  ) +
  theme_minimal()
print(p_ci)
ggsave("output/anova_means_ci.png", p_ci, width = 7, height = 5)

# --- Fit ANOVA -------------------------------------------------------------
fit <- aov(acousticness ~ era, data = anova_df)
print(summary(fit))

# Effect size (eta-squared)
ss <- summary(fit)[[1]]
eta_sq <- ss[1, "Sum Sq"] / sum(ss[, "Sum Sq"])
cat("Eta-squared:", round(eta_sq, 3), "\n")

# Pairwise comparisons
print(TukeyHSD(fit))

# --- Assumptions -----------------------------------------------------------
# 1. Independence: one row = one track; OK if you treat tracks as the unit.
# 2. Normality of residuals (QQ plot). With n=20k the CLT helps the F-test,
#    but you should still show the plot.
# 3. Equal variances: Levene / Bartlett + residual plot.

qq_df <- tibble(residual = residuals(fit))
p_qq <- ggplot(qq_df, aes(sample = residual)) +
  stat_qq() +
  stat_qq_line() +
  labs(title = "QQ plot of ANOVA residuals") +
  theme_minimal()
print(p_qq)
ggsave("output/anova_qq.png", p_qq, width = 6, height = 5)

p_res <- ggplot(tibble(fitted = fitted(fit), resid = residuals(fit)), aes(fitted, resid)) +
  geom_point(alpha = 0.15) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(title = "Residuals vs fitted (ANOVA)", x = "Fitted", y = "Residual") +
  theme_minimal()
print(p_res)
ggsave("output/anova_resid.png", p_res, width = 6, height = 5)

if (requireNamespace("car", quietly = TRUE)) {
  print(car::leveneTest(acousticness ~ era, data = anova_df))
} else {
  print(bartlett.test(acousticness ~ era, data = anova_df))
}

# If variances are unequal, report Welch ANOVA instead of (or beside) aov()
print(oneway.test(acousticness ~ era, data = anova_df, var.equal = FALSE))

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
