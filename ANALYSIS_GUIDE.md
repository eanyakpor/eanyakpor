# R analysis guide: correlation, ANOVA, regression

Use `data/spotify_tracks_analysis.csv`. Scripts live in `R/`.

## 0. Import checklist

```r
library(tidyverse)
tracks <- read_csv("data/spotify_tracks_analysis.csv")
glimpse(tracks)
summary(tracks)
colSums(is.na(tracks))
```

Then run `R/00_setup_and_clean.R` so `era`, `decade_label`, `energy_level`,
and `mode_label` are real factors.

Spot-check a few rows. `artists` should look like `The Beatles`, not
`['The Beatles']`. `duration_min` should be a few minutes, not 180000.

---

## 1. Correlation analysis

**Goal.** Describe linear (Pearson) and monotonic (Spearman) relationships
among quantitative audio features.

**Variables that work well**

| Pair | Why |
| --- | --- |
| `energy` & `loudness` | Strong positive; easy scatterplot |
| `energy` & `acousticness` | Strong negative |
| `danceability` & `valence` | Moderate positive |
| `acousticness` & `loudness` | Negative |
| `energy` & `popularity` | Weaker; useful contrast |

Leave `key` out of Pearson. It is a pitch class, not a numeric scale.

### Numerical results

```r
quant <- tracks %>%
  select(popularity, danceability, energy, loudness, acousticness,
         valence, tempo, duration_min)
cor(quant, method = "pearson")
cor(quant, method = "spearman")
cor.test(tracks$energy, tracks$loudness)
```

Report *r*, *p*, and *n*. If |Pearson − Spearman| is large, the relationship
is not linear — mention that.

### Graphs to include

1. **Correlation heatmap** of 8–11 numeric columns (`R/01_correlation.R`).
2. **Scatterplot + `geom_smooth(method = "lm")`** for 2–3 pairs.
3. **Hexbin / 2D density** for energy vs acousticness (20k points overlap).
4. Optional: **pairs plot** on a 1,000-row sample
   (`GGally::ggpairs()` if you install it).

**Do not** dump 20,000 overlapping points as your only figure. Sample ~3,000
for scatterplots, or use hexbin.

### How to interpret

- |r| ≈ 0.1 small, 0.3 medium, 0.5+ large (rough guide).
- Correlation is not causation. Energy and loudness move together because of
  how tracks are mixed, not because one “causes” the other.
- Spotify popularity is not a pure audio feature; it is also recency and
  streaming behavior.

---

## 2. ANOVA

**Goal.** Compare means of a quantitative outcome across **at least three**
groups.

### Recommended primary test (one-way)

**Outcome:** `acousticness`  
**Groups:** `era` (1921–1969, 1970–1999, 2000–2020)

- **H0:** μ_early = μ_mid = μ_recent  
- **Ha:** at least one era mean differs

This is easy to interpret: later popular music is, on average, less acoustic.

### Other ANOVA options on this data

| Model | Groups | Comment |
| --- | --- | --- |
| `acousticness ~ era` | 3 | Best default |
| `acousticness ~ decade_label` | 10–11 | Fine; more pairwise tests |
| `danceability ~ energy_level` | Low/Med/High | 3 groups, not time-based |
| `valence ~ time_signature` | 3, 4, 5 (drop 1 if thin) | Weaker story |
| `energy ~ era * mode_label` | two-way | Add if you need interaction |
| `popularity ~ era` | 3 | Significant, but popularity is biased toward new songs |

Avoid `mode` alone (only two groups → that’s a *t*-test, not ANOVA).
Avoid `key` unless you have a music-theory reason; 12 groups eat power and
are hard to explain.

### Graphs to include

1. **Boxplot** of the outcome by group (show means as a diamond).
2. **Violin + box** if you want distribution shape.
3. **Mean ± 95% CI** — the cleanest “ANOVA result” figure.
4. **QQ plot of residuals** and **residuals vs fitted**.
5. For two-way: **grouped boxplot** or **interaction plot**
   (`emmeans` / `stat_summary` by `era` and `mode_label`).

### Tests and follow-ups

```r
fit <- aov(acousticness ~ era, data = tracks)
summary(fit)
TukeyHSD(fit)
oneway.test(acousticness ~ era, data = tracks, var.equal = FALSE)  # Welch
```

Report:

- *F*, df, *p*
- **eta-squared** (effect size). With 20k rows, tiny differences can have
  *p* < .001. Effect size is what makes the result meaningful.
- Tukey pairwise which eras differ.

### Assumptions (write these explicitly)

| Assumption | How you check | If it fails |
| --- | --- | --- |
| Independence | One track = one row | Do not treat remixes as a mixed model unless you intend to |
| Normal residuals | QQ plot | Large *n*: F-test is still reasonable; you can also use Kruskal–Wallis |
| Equal variances | Levene / Bartlett, residual spread | Welch `oneway.test` |

Kruskal–Wallis is the nonparametric backup:

```r
kruskal.test(acousticness ~ era, data = tracks)
pairwise.wilcox.test(tracks$acousticness, tracks$era, p.adjust.method = "BH")
```

---

## 3. Hypothesis testing and multiple linear regression

**Goal.** Model a quantitative outcome with **at least two predictors**.

### Recommended model

```r
m <- lm(
  popularity ~ danceability + energy + acousticness +
    valence + loudness + duration_min,
  data = tracks
)
summary(m)
```

**Overall hypothesis (model F-test)**  
H0: all slopes = 0. Ha: at least one predictor is associated with popularity.

**Per-coefficient hypotheses**  
H0: β_k = 0 given the other variables in the model.

You need **two or more predictors**. A simple `lm(popularity ~ energy)` is
not enough for this requirement.

### Other MLR specifications that are valid

| Outcome | Predictors | Note |
| --- | --- | --- |
| `popularity` | `danceability + energy + acousticness` | Minimum legal model |
| `popularity` | audio features + `era` | Mix of numeric + dummy variables |
| `valence` | `danceability + energy + acousticness + mode_label` | Mood as outcome |
| `energy` | `loudness + acousticness + instrumentalness` | High R²; more “audio mixing” than “hits” |
| `popularity` | `danceability * energy + acousticness` | Interaction if you want one extra trick |

Predicting **popularity** will likely have a **modest R²**. That is worth
saying out loud: audio features are not the whole story (marketing, artist
fame, recency, playlist placement). Predicting **energy** from loudness and
acousticness will look “better” statistically but is a less interesting
question. Pick popularity if the assignment is about research questions;
mention the modest fit as a limitation.

### What to report

From `summary(m)`:

- *n*
- Residual standard error
- **R² and adjusted R²**
- Overall *F* and *p*
- Table of coefficients: estimate, SE, *t*, *p*, 95% CI (`confint(m)`)

Then:

- Sign: e.g. “holding other predictors fixed, a 0.1 increase in danceability
  is associated with …”
- Practical size, not just stars
- `anova(reduced, full)` if you test a nested hypothesis
  (“do danceability and energy add anything beyond acousticness?”)

### Graphs to include

1. **Coefficient plot** with 95% CIs (best single regression figure).
2. **Observed vs fitted**.
3. **Residuals vs fitted** (linearity / equal variance).
4. **QQ plot** of residuals.
5. **Scale-location**.
6. Optional: one **scatter + regression line** for a focal predictor, with a
   caption that the MLR slope is *adjusted*.

### Diagnostics and limitations

- **VIF** (`car::vif(m)`). Energy and loudness are correlated; if VIF > 5–10,
  drop one or discuss collinearity.
- **Cook’s distance** for influential tracks.
- Popularity is bounded 0–100; OLS can predict outside that range.
- Sample is stratified by decade, so it is **not** a random draw of all
  Spotify songs. Do not generalize to “all music.”
- Explicit lyrics are rare; don’t force `explicit` into the model unless
  you have a reason.

---

## Graph cheat sheet

| Analysis | Primary graph | Supporting graphs |
| --- | --- | --- |
| Correlation | Scatter + smooth; heatmap | Hexbin, pairs plot |
| ANOVA | Boxplot or mean+CI by group | Violin, QQ, residual plot, Tukey plot (`plot(TukeyHSD(fit))`) |
| Regression | Coefficient CI plot | Obs vs fitted, residual plots, scale-location |

Save plots from the scripts in `output/`, then insert the PNGs in your
R Markdown / Word report.

## Order of a short report

1. Data source, sample size, how rows were filtered.
2. Correlation section with heatmap + 2 scatterplots + a small *r* table.
3. ANOVA section with boxplot, *F* table, Tukey, assumption plots.
4. Regression section with coefficient table, R², residual plots, limitations.
5. One paragraph: what you would not claim (causation, “what makes a hit”).
