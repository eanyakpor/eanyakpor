# Spotify audio-feature analysis (R)

Project repo for the [Large Spotify Dataset](https://www.kaggle.com/discussions/general/153757)
([Kaggle dataset: 1921–2020, 600k+ tracks](https://www.kaggle.com/datasets/yamaerenay/spotify-dataset-19212020-600k-tracks)).

This folder is meant to be opened in **RStudio**. The CSV is already tidy enough
to import. Do the remaining recoding, assumption checks, and modeling **in R**
so your write-up matches the code.

## What is in the repo

| Path | Purpose |
| --- | --- |
| `data/spotify_tracks_analysis.csv` | 20,000-track stratified sample, ready to import |
| `data/codebook.md` | Column definitions and filter rules |
| `R/install_packages.R` | One-time package install |
| `R/00_setup_and_clean.R` | Import + factor recodes |
| `R/01_correlation.R` | Scatterplots + Pearson/Spearman |
| `R/02_anova.R` | Three-group ANOVA + diagnostics |
| `R/03_regression.R` | Multiple linear regression |
| `ANALYSIS_GUIDE.md` | Which tests/graphs to use and how to interpret them |

The original `tracks.csv` is ~107 MB, so it is **not** committed. The sample
keeps a similar number of songs from each decade so ANOVA groups are usable.

## Clean here or clean in R?

Do **both**, with a split of labor:

1. **Before R (already done in this repo)**  
   Sample the giant file, drop empty titles, parse year, convert duration to
   minutes, label keys/mode/explicit, and drop spoken-word tracks. That is
   structural prep so GitHub and RStudio stay usable.

2. **In R (you should still do this on the assignment)**  
   `read_csv`, `glimpse`, missing-value check, turn labels into `factor`s with
   ordered levels, scan outliers, then run models. Graders want to see this
   in R, not a black-box Python file.

Do not over-clean before import (for example, deleting “outliers” that are
actually real metal tracks with high energy). Those decisions belong next to
the model that uses the variable.

## Steps in RStudio

1. Download this repo and open `SpotifyAnalysis.Rproj`.
2. Session → Set Working Directory → To Project Directory  
   (or just open the `.Rproj` file, which does this).
3. Run `source("R/install_packages.R")` once.
4. Run `source("R/00_setup_and_clean.R")`.
5. Run the three analysis scripts, in order:
   - `source("R/01_correlation.R")`
   - `source("R/02_anova.R")`
   - `source("R/03_regression.R")`
6. Graphs are printed in the Plots pane and saved under `output/`.
7. Copy tables from the Console into your report. Interpret them using
   `ANALYSIS_GUIDE.md`.

If you prefer clicking: open each `R/*.R` file and use **Source**.

## Suggested models (ready to defend)

**Correlation**  
Energy vs loudness (strong +), energy vs acousticness (strong −),
danceability vs valence (moderate +), energy vs popularity (weaker).

**ANOVA**  
`acousticness ~ era` with three eras: 1921–1969, 1970–1999, 2000–2020.  
Backup: `danceability ~ energy_level` (Low / Medium / High).

**Multiple regression**  
`popularity ~ danceability + energy + acousticness + valence + loudness + duration_min`.

Details, assumption checks, graph types, and limitations:
[ANALYSIS_GUIDE.md](ANALYSIS_GUIDE.md).

## Source

Yamac Eren Ay, Spotify Web API via Kaggle. License: CDLA-Sharing-1.0.
See the [dataset page](https://www.kaggle.com/datasets/yamaerenay/spotify-dataset-19212020-600k-tracks)
for the full file if you need it. Optional helper: `python3 scripts/download_full_kaggle.py`.
