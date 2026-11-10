# Codebook: `spotify_tracks_analysis.csv`

Stratified sample of **20,000 tracks** from Yamac Eren Ay’s
[Spotify Dataset 1921–2020, 600k+ Tracks](https://www.kaggle.com/datasets/yamaerenay/spotify-dataset-19212020-600k-tracks)
(Kaggle discussion: [Large Spotify Dataset](https://www.kaggle.com/discussions/general/153757)).

Rows are sampled so each decade from the 1920s through the 2020s has a similar
count (~1,800). That keeps ANOVA groups usable and GitHub-friendly. The full
source file is ~107 MB and should not be committed.

## How this sample was filtered

- Dropped tracks with missing name or year
- Kept years 1921–2020
- Dropped clips shorter than 30 seconds or longer than 15 minutes
- Dropped `tempo == 0` and invalid `time_signature`
- Dropped likely spoken-word / audiobook tracks (`speechiness > 0.66`)

## Columns

| Column | Type | Meaning |
| --- | --- | --- |
| `id` | character | Spotify track id |
| `name` | character | Track title |
| `artists` | character | Artist names, comma-separated |
| `year` | integer | Release year parsed from `release_date` |
| `decade` | integer | Decade start year (`1920`, `1930`, …) |
| `decade_label` | character | `"1920s"`, `"1930s"`, … |
| `release_date` | character | Original date string (`yyyy`, `yyyy-mm`, or `yyyy-mm-dd`) |
| `popularity` | integer | Spotify popularity, 0–100 |
| `duration_min` | numeric | Track length in minutes |
| `explicit` | integer | `0` = not explicit, `1` = explicit |
| `explicit_label` | character | Human-readable explicit flag |
| `danceability` | numeric | 0–1 |
| `energy` | numeric | 0–1 |
| `energy_level` | character | Tertile of energy: Low / Medium / High |
| `key` | integer | Pitch class 0–11 (C = 0) |
| `key_label` | character | Pitch name |
| `loudness` | numeric | Overall loudness in dB (typically negative) |
| `mode` | integer | `0` = minor, `1` = major |
| `mode_label` | character | Minor / Major |
| `speechiness` | numeric | 0–1; higher = more spoken words |
| `acousticness` | numeric | 0–1 |
| `instrumentalness` | numeric | 0–1 |
| `liveness` | numeric | 0–1 |
| `valence` | numeric | 0–1; higher = more positive mood |
| `tempo` | numeric | Beats per minute |
| `time_signature` | integer | Estimated meter (1, 3, 4, or 5) |
