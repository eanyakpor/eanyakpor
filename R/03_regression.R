# 03_regression.R
# Hypothesis test + multiple linear regression with at least two predictors.

library(tidyverse)

if (!exists("tracks")) source("R/00_setup_and_clean.R")

# Research question:
# Do danceability and energy predict Spotify popularity after accounting
# for acousticness, valence, loudness, and duration?
#
# Overall H0: all slope coefficients are 0
# For each predictor Hk0: beta_k = 0 | other predictors in the model

model_df <- tracks %>%
  select(
    popularity, danceability, energy, acousticness, valence,
    loudness, duration_min, explicit_label, era
  )

# --- Model -----------------------------------------------------------------
m <- lm(
  popularity ~ danceability + energy + acousticness + valence +
    loudness + duration_min,
  data = model_df
)
print(summary(m))
# Report: F-stat (overall fit), R-squared, adj R-squared, residual SE,
# and each coefficient's estimate, SE, t, p-value.

# Nested comparison: does adding energy+danceability improve a baseline?
m0 <- lm(popularity ~ acousticness + valence + loudness + duration_min, data = model_df)
print(anova(m0, m))  # extra-sum-of-squares F test

if (!requireNamespace("broom", quietly = TRUE)) install.packages("broom")
if (!requireNamespace("car", quietly = TRUE)) install.packages("car")

# --- Coefficient plot ------------------------------------------------------
coef_df <- broom::tidy(m, conf.int = TRUE) %>%
  filter(term != "(Intercept)")

p_coef <- ggplot(coef_df, aes(estimate, reorder(term, estimate))) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.2) +
  geom_point(size = 3) +
  labs(
    title = "Multiple regression coefficients (95% CI)",
    subtitle = "Outcome: popularity",
    x = "Coefficient", y = NULL
  ) +
  theme_minimal()
print(p_coef)
ggsave("output/reg_coefficients.png", p_coef, width = 7, height = 5)

# --- Fit visuals -----------------------------------------------------------
aug <- broom::augment(m)

p_fit <- ggplot(aug, aes(.fitted, popularity)) +
  geom_point(alpha = 0.15) +
  geom_abline(slope = 1, intercept = 0, color = "#c44e52") +
  labs(
    title = "Observed vs fitted popularity",
    x = "Fitted", y = "Observed popularity"
  ) +
  theme_minimal()
print(p_fit)
ggsave("output/reg_obs_vs_fitted.png", p_fit, width = 6, height = 5)

p_resid <- ggplot(aug, aes(.fitted, .resid)) +
  geom_point(alpha = 0.15) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_smooth(se = FALSE, color = "#c44e52") +
  labs(title = "Residuals vs fitted", x = "Fitted", y = "Residual") +
  theme_minimal()
print(p_resid)
ggsave("output/reg_resid_fitted.png", p_resid, width = 6, height = 5)

p_qq <- ggplot(aug, aes(sample = .std.resid)) +
  stat_qq() +
  stat_qq_line() +
  labs(title = "QQ plot of standardized residuals") +
  theme_minimal()
print(p_qq)
ggsave("output/reg_qq.png", p_qq, width = 6, height = 5)

p_scale <- ggplot(aug, aes(.fitted, sqrt(abs(.std.resid)))) +
  geom_point(alpha = 0.15) +
  geom_smooth(se = FALSE, color = "#c44e52") +
  labs(title = "Scale-location", x = "Fitted", y = "sqrt(|std residual|)") +
  theme_minimal()
print(p_scale)
ggsave("output/reg_scale_location.png", p_scale, width = 6, height = 5)

# Added-variable / partial residual idea for one focal predictor
p_partial <- ggplot(model_df, aes(energy, popularity)) +
  geom_point(alpha = 0.12) +
  geom_smooth(method = "lm", se = TRUE, color = "#c44e52") +
  labs(
    title = "Simple view: energy vs popularity",
    subtitle = "The multiple regression coefficient is the slope after controlling for the other predictors",
    x = "Energy", y = "Popularity"
  ) +
  theme_minimal()
print(p_partial)
ggsave("output/reg_energy_popularity.png", p_partial, width = 6, height = 5)

# --- Diagnostics numbers ---------------------------------------------------
# Multicollinearity
print(car::vif(m))

# Influence
cooks <- cooks.distance(m)
cat("Max Cook's distance:", max(cooks, na.rm = TRUE), "\n")

# Optional: add a categorical predictor (still linear regression)
m_era <- lm(
  popularity ~ danceability + energy + acousticness + era,
  data = model_df
)
print(summary(m_era))
print(broom::glance(m))
print(broom::glance(m_era))

# --- Genre-adjusted danceability model -------------------------------------
# H0: after energy, valence, and acousticness are held fixed, genre family
#     is unrelated to danceability (all genre dummies = 0 vs Afrobeats).
if (!exists("genre_compare")) source("R/00_setup_and_clean.R")

m_afro <- lm(
  danceability ~ energy + valence + acousticness + genre_family,
  data = genre_compare
)
print(summary(m_afro))
print(car::vif(m_afro))

coef_afro <- broom::tidy(m_afro, conf.int = TRUE) %>%
  filter(term != "(Intercept)")
p_afro <- ggplot(coef_afro, aes(estimate, reorder(term, estimate))) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.2) +
  geom_point(size = 3) +
  labs(
    title = "Danceability coefficients (reference: Afrobeats)",
    subtitle = "Negative genre dummies mean that family is less danceable than Afrobeats, holding audio features fixed",
    x = "Coefficient", y = NULL
  ) +
  theme_minimal()
print(p_afro)
ggsave("output/reg_genre_danceability.png", p_afro, width = 8, height = 5)
