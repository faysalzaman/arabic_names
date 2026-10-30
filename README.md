# arabic_names

Flutter app (Android) for browsing Arabic / Islamic baby names with meanings.
Published on Google Play as `com.sairatec.arabic_names`.

## Run

```bash
flutter pub get
flutter run
```

Debug and profile builds use Google's AdMob test ad units; release builds use the real ones
(`lib/ads/ad_units.dart`).

## Names data

The app reads a pre-built SQLite file, `assets/names.db`. It is generated from the source JSON in
`tool/data_src/`:

```bash
python3 tool/build_names_db.py
```

The script fixes key typos and genders, removes duplicates and adds the search/sort columns.
After changing the data for a release, bump `_dbFile` in `lib/DataBase/names_repository.dart`
so existing installs copy the new database.

## Layout

| Path | What |
|------|------|
| `lib/DataBase/` | `NamesRepository` (read-only names DB), `FavouritesStore` |
| `lib/Bloc/` | `NamesBloc` (list + search), `FavouriteBloc` |
| `lib/ui_screens/` | splash, menu, names list, detail, favourites |
| `lib/widgets/`, `lib/theme/` | shared widgets, dark green/orange theme |
| `lib/ads/` | banner, interstitial manager, ad unit ids |
| `ISSUES.md` | known issues and the improvement plan |
