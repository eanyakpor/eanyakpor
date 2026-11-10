"""Build data/spotify_tracks_analysis.csv from the Kaggle Spotify dump.

Joins each track to its primary artist's genre list, maps a coarse
genre_family (including Afrobeats), and writes a GitHub-sized sample
that keeps every cleaned Afrobeats track.
"""

from __future__ import annotations

import ast
from pathlib import Path

import pandas as pd

OUT = Path("data/spotify_tracks_analysis.csv")
KEY_MAP = {
    0: "C",
    1: "C#/Db",
    2: "D",
    3: "D#/Eb",
    4: "E",
    5: "F",
    6: "F#/Gb",
    7: "G",
    8: "G#/Ab",
    9: "A",
    10: "A#/Bb",
    11: "B",
}

# This 2021 dump has no literal "afrobeats" tag. Modern Afrobeats is usually
# afropop / nigerian pop / azonto; classic Fela-style is "afrobeat".
AFROBEATS = {
    "afropop",
    "nigerian pop",
    "azontobeats",
    "azonto",
    "afro dancehall",
    "ghanaian pop",
    "afroswing",
    "nigerian hip hop",
    "afro r&b",
    "amapiano",
    "afro soul",
    "afrobeat",
    "classic afrobeat",
    "latin afrobeat",
    "afrobeat brasileiro",
}
HIPHOP = {
    "hip hop",
    "rap",
    "pop rap",
    "trap",
    "southern hip hop",
    "gangster rap",
    "east coast hip hop",
    "west coast rap",
    "alternative hip hop",
}
LATIN = {"latin", "latin pop", "reggaeton", "tropical", "latin hip hop", "trap latino"}
POP = {"pop", "dance pop", "electropop", "post-teen pop", "europop", "pop dance", "pop rock"}
ROCK = {
    "rock",
    "classic rock",
    "album rock",
    "modern rock",
    "hard rock",
    "soft rock",
    "folk rock",
    "art rock",
}
CLASSICAL = {"classical", "classical performance", "orchestra"}
RNB = {"r&b", "urban contemporary", "neo soul", "soul"}
EDM = {"edm", "electro house", "tropical house", "house", "progressive house"}
COUNTRY = {"country", "contemporary country", "country rock"}

FAMILIES = [
    ("Afrobeats", AFROBEATS),
    ("Hip hop", HIPHOP),
    ("Latin", LATIN),
    ("Pop", POP),
    ("Rock", ROCK),
    ("Classical", CLASSICAL),
    ("R&B / Soul", RNB),
    ("EDM", EDM),
    ("Country", COUNTRY),
]


def parse_list(value):
    if pd.isna(value):
        return []
    try:
        parsed = ast.literal_eval(value)
        return list(parsed) if isinstance(parsed, list) else []
    except Exception:
        return []


def genre_family(genres: list[str]) -> str:
    tags = set(genres)
    for name, family_tags in FAMILIES:
        if tags & family_tags:
            return name
    if genres:
        return "Other tagged"
    return "Untagged"


def parse_artists(value) -> str | None:
    if pd.isna(value):
        return None
    parsed = parse_list(value)
    if parsed:
        return ", ".join(str(x) for x in parsed)
    return str(value).strip("[]'\" ")


def find_source() -> Path:
    cached = Path.home() / ".cache/kagglehub/datasets/yamaerenay/spotify-dataset-19212020-600k-tracks/versions/1"
    if (cached / "tracks.csv").exists():
        return cached
    import kagglehub

    return Path(kagglehub.dataset_download("yamaerenay/spotify-dataset-19212020-600k-tracks"))


def main() -> None:
    src = find_source()
    tracks = pd.read_csv(src / "tracks.csv")
    artists = pd.read_csv(src / "artists.csv", usecols=["id", "genres"])

    tracks["artist_ids"] = tracks["id_artists"].map(parse_list)
    tracks["primary_artist_id"] = tracks["artist_ids"].map(lambda ids: ids[0] if ids else None)
    genre_map = (
        artists.set_index("id")["genres"]
        .map(lambda s: [g.lower() for g in parse_list(s)])
        .to_dict()
    )
    tracks["genre_list"] = tracks["primary_artist_id"].map(lambda i: genre_map.get(i, []))
    tracks["primary_genre"] = tracks["genre_list"].map(lambda g: g[0] if g else None)
    tracks["artist_genres"] = tracks["genre_list"].map(lambda g: "; ".join(g[:8]) if g else None)
    tracks["genre_family"] = tracks["genre_list"].map(genre_family)
    tracks["artists"] = tracks["artists"].map(parse_artists)
    tracks["year"] = pd.to_numeric(tracks["release_date"].astype(str).str.slice(0, 4), errors="coerce")

    df = tracks.dropna(subset=["name", "year", "popularity", "danceability", "energy"])
    df = df[(df["year"] >= 1921) & (df["year"] <= 2020)]
    df = df[(df["duration_ms"] >= 30_000) & (df["duration_ms"] <= 900_000)]
    df = df[df["tempo"] > 0]
    df = df[df["time_signature"].isin([1, 3, 4, 5])]
    df = df[df["speechiness"] <= 0.66]
    df = df.drop_duplicates(subset=["id"])

    df["duration_min"] = df["duration_ms"] / 60_000.0
    df["decade"] = (df["year"] // 10 * 10).astype(int)
    df["decade_label"] = df["decade"].astype(str) + "s"
    df["key_label"] = df["key"].map(KEY_MAP)
    df["mode_label"] = df["mode"].map({0: "Minor", 1: "Major"})
    df["explicit_label"] = df["explicit"].map({0: "Not explicit", 1: "Explicit"})
    df["energy_level"] = pd.qcut(df["energy"], 3, labels=["Low", "Medium", "High"])

    keep = [
        "id",
        "name",
        "artists",
        "year",
        "decade",
        "decade_label",
        "release_date",
        "popularity",
        "duration_min",
        "explicit",
        "explicit_label",
        "danceability",
        "energy",
        "energy_level",
        "key",
        "key_label",
        "loudness",
        "mode",
        "mode_label",
        "speechiness",
        "acousticness",
        "instrumentalness",
        "liveness",
        "valence",
        "tempo",
        "time_signature",
        "primary_genre",
        "artist_genres",
        "genre_family",
    ]
    df = df[keep]

    rng = 42
    parts = []

    afro = df[df["genre_family"] == "Afrobeats"]
    parts.append(afro)

    for family in ["Hip hop", "Latin", "Pop", "Rock", "Classical"]:
        block = df[df["genre_family"] == family]
        n = min(len(block), 2000)
        parts.append(block.sample(n=n, random_state=rng))

    used_ids = pd.concat(parts)["id"]
    remainder = df[~df["id"].isin(used_ids)]
    decade_parts = []
    for _, group in remainder.groupby("decade"):
        decade_parts.append(group.sample(n=min(len(group), 800), random_state=rng))
    parts.append(pd.concat(decade_parts, ignore_index=True))

    sample = pd.concat(parts, ignore_index=True).drop_duplicates(subset=["id"])
    sample = sample.sort_values(["genre_family", "year", "popularity"], ascending=[True, True, False])
    sample = sample.reset_index(drop=True)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    sample.to_csv(OUT, index=False)
    print("wrote", OUT, "n=", len(sample))
    print(sample["genre_family"].value_counts())
    print(sample.groupby("genre_family")["danceability"].mean().sort_values(ascending=False).round(3))


if __name__ == "__main__":
    main()
