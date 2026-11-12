"""Optional: download the full 600k-track Kaggle files.

The assignment CSV in data/ is enough. Use this only if you want the
original tracks.csv / artists.csv locally (they are too large for GitHub).

    python3 scripts/download_full_kaggle.py
"""

from pathlib import Path

import kagglehub

DEST = Path("data/raw")


def main() -> None:
    DEST.mkdir(parents=True, exist_ok=True)
    src = Path(
        kagglehub.dataset_download("yamaerenay/spotify-dataset-19212020-600k-tracks")
    )
    print("Cached at:", src)
    for name in ("tracks.csv", "artists.csv"):
        target = DEST / name
        if not target.exists():
            (DEST / name).write_bytes((src / name).read_bytes())
        print("Wrote", target, "bytes", target.stat().st_size)


if __name__ == "__main__":
    main()
