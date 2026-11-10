# 00_setup_and_clean.R
# Import the analysis CSV and do the remaining R-side prep.
# Advice: keep this script in your assignment. The CSV is already easy to
# read, but cleaning/recoding in R is what graders usually want to see.

if (!requireNamespace("tidyverse", quietly = TRUE)) {
  install.packages("tidyverse")
}

library(tidyverse)

data_path <- file.path("data", "spotify_tracks_analysis.csv")
if (!file.exists(data_path)) {
  data_path <- file.path("..", "data", "spotify_tracks_analysis.csv")
}

tracks_raw <- read_csv(data_path, show_col_types = FALSE)

# Inspect before you trust it
glimpse(tracks_raw)
summary(tracks_raw)
colSums(is.na(tracks_raw))

tracks <- tracks_raw %>%
  mutate(
    decade_label = factor(
      decade_label,
      levels = paste0(seq(1920, 2020, by = 10), "s")
    ),
    energy_level = factor(energy_level, levels = c("Low", "Medium", "High")),
    mode_label = factor(mode_label, levels = c("Minor", "Major")),
    explicit_label = factor(explicit_label, levels = c("Not explicit", "Explicit")),
    key_label = factor(
      key_label,
      levels = c("C", "C#/Db", "D", "D#/Eb", "E", "F", "F#/Gb", "G", "G#/Ab", "A", "A#/Bb", "B")
    ),
    time_signature = factor(time_signature),
    # Three-era grouping is a clean ANOVA option (exactly 3 groups)
    era = factor(
      case_when(
        year < 1970 ~ "1921-1969",
        year < 2000 ~ "1970-1999",
        TRUE ~ "2000-2020"
      ),
      levels = c("1921-1969", "1970-1999", "2000-2020")
    )
  )

# Optional: drop the 2020s if you want complete decades only
tracks_no_2020s <- tracks %>% filter(decade < 2020)

dir.create("output", showWarnings = FALSE)
saveRDS(tracks, file.path("output", "tracks_clean.rds"))

message("Ready. ", nrow(tracks), " tracks loaded.")
