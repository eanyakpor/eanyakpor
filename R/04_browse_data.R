# Open the cleaned data as a table (RStudio spreadsheet or Viewer "webview").
# Run after the project is open, from the Console:
#   source("R/04_browse_data.R")

library(tidyverse)

if (!exists("tracks")) source("R/00_setup_and_clean.R")

browse <- tracks %>%
  transmute(
    Track = name,
    Artist = artists,
    Year = year,
    Decade = decade_label,
    `Genre family` = as.character(genre_family),
    `Primary genre` = primary_genre,
    Popularity = popularity,
    Danceability = round(danceability, 3),
    Energy = round(energy, 3),
    Valence = round(valence, 3),
    Acousticness = round(acousticness, 3),
    `Duration (min)` = round(duration_min, 2)
  )

# Spreadsheet-style window inside RStudio
View(browse)

# Searchable table in the Viewer pane (the HTML webview)
if (!requireNamespace("DT", quietly = TRUE)) install.packages("DT")
DT::datatable(
  browse,
  filter = "top",
  rownames = FALSE,
  options = list(pageLength = 15, scrollX = TRUE, autoWidth = TRUE)
)

message(
  nrow(tracks), " cleaned tracks. Use the search box; filter Genre family to Afrobeats."
)
