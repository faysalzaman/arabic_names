#!/usr/bin/env python3
"""Builds assets/names.db from the JSON files in tool/data_src/.

Run from the repo root:   python3 tool/build_names_db.py

What it does
  * fixes the misspelled keys ("EnglishDescription ", UrduFamousPersion, UrduLangauge)
  * normalises gender to Male / Female / Unisex (per row, falling back to the file default)
  * drops empty values (stored as NULL) and removes duplicate names inside a category,
    keeping the row that has the most filled-in fields
  * adds search/sort helper columns (norm, letter, search, key)

KEEP normalize_ar() IN SYNC with lib/utils/arabic_text.dart.
"""
import json
import os
import re
import sqlite3
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "tool", "data_src")
OUT = os.path.join(ROOT, "assets", "names.db")

# (file, category, default gender)
SOURCES = [
    ("ArabicData.json", "all", "Male"),
    ("girls_name.json", "all", "Female"),
    ("trending_boys.json", "trending", "Male"),
    ("trending_girls.json", "trending", "Female"),
    ("cboys.json", "celebrity", "Male"),
    ("cgirls.json", "celebrity", "Female"),
]

GENDER_MAP = {
    "male": "Male", "boy": "Male", "larka": "Male",
    "female": "Female", "girl": "Female", "larki": "Female", "fmale": "Female",
    "unisex": "Unisex",
}

# source key (after strip) -> db column
KEY_ALIASES = {
    "UrduFamousPersion": "UrduFamousPerson",
    "UrduLangauge": "UrduLanguage",
}

TEXT_COLUMNS = [
    "EnglishName", "EnglishMeaning", "EnglishReligion", "EnglishLuckyDay",
    "EnglishLuckyColor", "EnglishLuckyStones", "EnglishLanguage",
    "EnglishLuckyMetals", "EnglishFamousPerson", "EnglishDescription",
    "EnglishKnownFor", "EnglishOccopation",
    "UrduName", "UrduMeaning", "UrduReligion", "UrduLuckyNumber", "UrduLuckyDay",
    "UrduLuckyColor", "UrduLuckyStones", "UrduLanguage", "UrduLuckyMetals",
    "UrduFamousPerson", "UrduDescription", "UrduKnownFor", "UrduOccopation",
]

_DIACRITICS = re.compile("[ً-ٰٟـۖ-ۭ]")
_FOLD = str.maketrans({
    "أ": "ا", "إ": "ا", "آ": "ا", "ٱ": "ا",
    "ى": "ي", "ی": "ي", "ے": "ي", "ئ": "ي",
    "ة": "ه", "ہ": "ه", "ھ": "ه", "ۃ": "ه",
    "ک": "ك", "گ": "ك",
    "پ": "ب", "چ": "ج", "ژ": "ز",
    "ٹ": "ت", "ڈ": "د", "ڑ": "ر", "ں": "ن",
    "ؤ": "و",
})


def normalize_ar(text):
    text = _DIACRITICS.sub("", text or "")
    return text.translate(_FOLD).strip()


def clean(value):
    if value is None:
        return None
    value = str(value).strip()
    if value == "" or value.lower() in ("null", "none", "nan", "n/a", "-"):
        return None
    return value


def name_key(en, ar):
    return f"{(en or '').strip().lower()}|{(ar or '').strip()}"


def load_rows(filename, default_gender):
    with open(os.path.join(SRC, filename), encoding="utf-8") as fh:
        raw = json.load(fh)["result"]
    for item in raw:
        row = {}
        for key, value in item.items():
            key = key.strip()
            key = KEY_ALIASES.get(key, key)
            if key in TEXT_COLUMNS:
                row[key] = clean(value)
        gender = GENDER_MAP.get((clean(item.get("Gender")) or "").lower())
        row["Gender"] = gender or default_gender
        yield row


def main():
    if os.path.exists(OUT):
        os.remove(OUT)
    best = {}  # (category, gender, key) -> row
    skipped = 0
    for filename, category, default_gender in SOURCES:
        for row in load_rows(filename, default_gender):
            if not row.get("UrduName") or not row.get("EnglishName"):
                skipped += 1
                continue
            row["category"] = category
            key = name_key(row["EnglishName"], row["UrduName"])
            row["key"] = key
            ident = (category, row["Gender"], key)
            filled = sum(1 for c in TEXT_COLUMNS if row.get(c))
            row["_filled"] = filled
            if ident not in best or filled > best[ident]["_filled"]:
                best[ident] = row

    rows = list(best.values())
    for row in rows:
        norm = normalize_ar(row["UrduName"])
        row["norm"] = norm
        row["letter"] = norm[:1]
        row["search"] = " ".join(filter(None, [
            norm,
            row["EnglishName"].lower(),
            normalize_ar(row.get("UrduMeaning")),
            (row.get("EnglishMeaning") or "").lower(),
        ]))
    rows.sort(key=lambda r: (r["category"], r["norm"], r["EnglishName"].lower()))

    con = sqlite3.connect(OUT)
    cols = ["id INTEGER PRIMARY KEY", "category TEXT NOT NULL", "Gender TEXT NOT NULL",
            "key TEXT NOT NULL", "norm TEXT NOT NULL", "letter TEXT NOT NULL",
            "search TEXT NOT NULL"] + [f"{c} TEXT" for c in TEXT_COLUMNS]
    con.execute("CREATE TABLE names (" + ", ".join(cols) + ")")
    insert_cols = ["category", "Gender", "key", "norm", "letter", "search"] + TEXT_COLUMNS
    con.executemany(
        f"INSERT INTO names ({','.join(insert_cols)}) VALUES ({','.join('?' * len(insert_cols))})",
        [[row.get(c) for c in insert_cols] for row in rows],
    )
    con.execute("CREATE INDEX idx_names_list ON names (category, Gender, norm)")
    con.execute("CREATE INDEX idx_names_key ON names (key)")
    con.commit()
    con.execute("VACUUM")
    con.close()

    summary = {}
    for row in rows:
        summary[(row["category"], row["Gender"])] = summary.get((row["category"], row["Gender"]), 0) + 1
    print(f"wrote {OUT}: {len(rows)} names ({os.path.getsize(OUT) / 1e6:.1f} MB), skipped {skipped} rows without a name")
    for (category, gender), count in sorted(summary.items()):
        print(f"  {category:9} {gender:7} {count}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
