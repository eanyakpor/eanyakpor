# Spotify audio-feature analysis (R)

Project repo for the [Large Spotify Dataset](https://www.kaggle.com/discussions/general/153757)
([Kaggle dataset: 1921–2020, 600k+ tracks](https://www.kaggle.com/datasets/yamaerenay/spotify-dataset-19212020-600k-tracks)).

This folder is meant to be opened in **RStudio**. The CSV is already tidy enough
to import. Do the remaining recoding, assumption checks, and modeling **in R**
so your write-up matches the code.

## What is in the repo

| Path | Purpose |
| --- | --- |
| `data/spotify_tracks_analysis.csv` | ~21k tracks for **R** (keep this file for the scripts) |
| `data/spotify_tracks_google_sheets.csv` | Same data with readable column names for Sheets/Excel |
| `data/spotify_tracks_preview_500.csv` | First 500 rows, easier to skim |
| `data/codebook.md` | Column definitions and filter rules |
| `R/install_packages.R` | One-time package install |
| `R/00_setup_and_clean.R` | Import + factor recodes |
| `R/01_correlation.R` | Scatterplots + Pearson/Spearman |
| `R/02_anova.R` | Three-group ANOVA + diagnostics |
| `R/03_regression.R` | Multiple linear regression |
| `ANALYSIS_GUIDE.md` | Which tests/graphs to use and how to interpret them |

The original `tracks.csv` is ~107 MB, so it is **not** committed. Genre is
**not** on the track file; it is joined from the artist. Afrobeats is uncommon
here (~2,100 cleaned tracks), so every one of those rows is kept. Rock, pop,
and classical have far more songs in the raw dump.

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

## Browse the data (Google Sheets or Excel)

Do **not** replace `spotify_tracks_analysis.csv`. R needs those short column names (`danceability`, `genre_family`, …).

**Google Sheets**

1. Pull the latest branch so you have the new files (`git pull`).
2. Open [Google Sheets](https://sheets.google.com) → **Blank spreadsheet**.
3. **File → Import → Upload**.
4. Upload `data/spotify_tracks_google_sheets.csv`  
   (or the 500-row `data/spotify_tracks_preview_500.csv` if you only want a peek).
5. Import location: **Replace current sheet**. Separator: **Comma**. Click **Import data**.
6. Freeze the header: click row 1 → **View → Freeze → 1 row**. Turn on filter: **Data → Create a filter**.

Direct download from GitHub (while on the analysis branch): open the file on GitHub → **Download raw file**, then import that.

**Excel / Numbers:** double-click `spotify_tracks_google_sheets.csv`, or **File → Import**.

**Inside RStudio (no spreadsheet):** after `source("R/00_setup_and_clean.R")` run `View(tracks)` for a clickable table.

The Sheets file uses labels like `Genre family` and `Danceability (0-1)`, and rounds decimals to 3 places. Use it to look at the data; keep running models on the original CSV.

## Suggested models (ready to defend)

**Correlation**  
Energy vs loudness (strong +), energy vs acousticness (strong −),
danceability vs valence (moderate +), energy vs popularity (weaker).

**ANOVA**  
`danceability ~ genre_family` with Afrobeats, Hip hop, Latin, Pop, Rock, and Classical.  
Backup: `acousticness ~ era` (1921–1969 / 1970–1999 / 2000–2020).

**Multiple regression**  
`popularity ~ danceability + energy + acousticness + valence + loudness + duration_min`  
and `danceability ~ energy + valence + acousticness + genre_family` (Afrobeats as the reference).

Details, assumption checks, graph types, and limitations:
[ANALYSIS_GUIDE.md](ANALYSIS_GUIDE.md).

## Source

Yamac Eren Ay, Spotify Web API via Kaggle. License: CDLA-Sharing-1.0.
See the [dataset page](https://www.kaggle.com/datasets/yamaerenay/spotify-dataset-19212020-600k-tracks)
for the full file if you need it. Optional helper: `python3 scripts/download_full_kaggle.py`.
