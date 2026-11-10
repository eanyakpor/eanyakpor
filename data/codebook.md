# Codebook: `spotify_tracks_analysis.csv`

About **21,000 tracks** from Yamac Eren Ay’s
[Spotify Dataset 1921–2020, 600k+ Tracks](https://www.kaggle.com/datasets/yamaerenay/spotify-dataset-19212020-600k-tracks)
(Kaggle discussion: [Large Spotify Dataset](https://www.kaggle.com/discussions/general/153757)).

`tracks.csv` has **no genre column**. Genre is joined from the primary
artist in `artists.csv`.

The sample:

- keeps **every cleaned Afrobeats-family track** (~2,100) so that family is usable
- samples ~2,000 each of Hip hop, Latin, Pop, Rock, and Classical
- adds a decade-balanced remainder for correlation / regression

The full source file is ~107 MB and should not be committed.

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
| `primary_genre` | character | First Spotify genre tag on the primary artist |
| `artist_genres` | character | Up to eight artist tags, separated by `"; "` |
| `genre_family` | character | Coarse family used in ANOVA (see below) |

## Genre families

This 2021 dump **does not contain a tag named `afrobeats`**. Modern Afrobeats
is usually tagged `afropop`, `nigerian pop`, `azonto`, `azontobeats`, or
`afro dancehall`. Classic Fela-style music is tagged `afrobeat`. Both are
rolled into **Afrobeats** so the group is large enough for ANOVA.

| `genre_family` | Example artist tags | Role |
| --- | --- | --- |
| Afrobeats | afropop, afrobeat, nigerian pop, azonto, afroswing, amapiano | Target group; all rows kept |
| Hip hop | hip hop, rap, pop rap, trap | High-danceability comparison |
| Latin | latin, latin pop, reggaeton | High-danceability comparison |
| Pop | pop, dance pop, electropop | High-volume comparison |
| Rock | rock, classic rock, album rock | Lower-danceability comparison |
| Classical | classical, orchestra | Low-danceability comparison |
| R&B / Soul, EDM, Country | matching tags | Present, but thin in this sample |
| Other tagged / Untagged | everything else | Use for correlation, not genre ANOVA |

A track is assigned the **first matching family** in the table order, using
the primary artist's tags. Artists can have several tags, so this is a
proxy, not a gold-standard genre label.

Rebuild with `python3 scripts/build_analysis_csv.py`.
