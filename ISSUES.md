# arabic_names – scan results

## Status after step 1 (written, **not yet compiled or run** – no Flutter toolchain was available)

Done in code: A1–A10 and B1–B6, C1–C3, and the unused assets/dependencies/dead files in D.
* Names now come from a pre-built, de-duplicated SQLite file, `assets/names.db` (27 436 names, 9 MB, was ~35 MB of JSON).
  Rebuild it after editing the sources in `tool/data_src/` with `python3 tool/build_names_db.py`.
  When the data changes for an app update, bump `_dbFile` in `lib/DataBase/names_repository.dart`.
* Favourites are stored by a stable name key, can be removed, and old favourites are migrated.
* Search is accent/alef-insensitive, covers Arabic + English names and meanings, and a "no result" search stays empty.
* One `CategoryScreen` replaces three copies; ads go through `lib/ads/` (adaptive banner, one interstitial manager, test ids in debug).
* Redesign (E) written too: dark green/orange Material 3 theme, right-to-left Arabic layout, new menu cards, one names screen with a boys/girls switch, rich tiles (Arabic + English name, meaning, heart), redesigned detail and favourites screens, drawer removed.
* Still open: the signing keystore in git (D), a bundled Arabic font, and new data (C5).

---

Scan of `lib/`, `assets/`, `pubspec.yaml` and the Android config. Nothing here has been
run (no Flutter toolchain on this machine yet), so everything is from reading the code and
analysing the JSON files.

## A. Bugs (things that are plainly wrong)

| # | Where | Problem | Fix |
|---|-------|---------|-----|
| A1 | `names_bloc.dart` `GetNames` | `list` is always empty, so `createItem(model: list)` inserts nothing. The `Name` SQLite table is never filled and `getItems()` always returns `[]`. | Decide on one data source (see C1) and delete the dead path. |
| A2 | `home_screen.dart:306` | `if (filteredNames.isEmpty) filteredNames = List.from(namemodel);` – a search with **no match** instantly refills the list with *all* names. | Keep "no results" as a real state; only initialise the list once when the bloc state changes. |
| A3 | `home_screen.dart` `_filterNames` | Searches `urduName` only: no English/Latin search, no meaning search, no أ/إ/آ/ا normalisation (the alphabet rail normalises, the search does not), `urduName!` can crash on null. | Normalise text once at load (strip diacritics, unify alef/ya/ta-marbuta), search name + English name + meaning, debounce 250 ms. |
| A4 | `names_bloc.dart` `RefreshNames` | Loads `assets/TBoys.json` / `TGirls.json`, which don't exist; has two identical `"Male"` branches; `GetNamesOnGender` repeats the same 6 branches again (~200 duplicated lines). | One `NamesRepository.load(category)` driven by a map `{category -> asset}`. |
| A5 | Data / gender filter | Rows are filtered with `element.gender == event.gender`. `girls_name.json` has gender values `Female` 13467, `Girl` 340, `Boy` 65, `Unisex` 9, null 8, `"Fmale "`, `"Intelligent"`; `cgirls` has `Girl`/`Unisex`/`Boy`/`Intelligent`; `ArabicData` has 2 `Unisex` + 1 null. All of those rows are silently dropped, and some Boys sit inside the girls file. | Clean the data once (see C2), and use an enum (`boy`, `girl`, `unisex`) instead of strings like `Larka`/`Larki`. |
| A6 | JSON keys | Typos make fields unreadable: `"EnglishDescription "` (trailing space, ArabicData), `UrduFamousPersion`, `UrduLangauge` (trending_boys). Those fields always load as null. | Fix in the data (script), not in code. |
| A7 | Favourites | `FavouriteBloc` only has `GetFavourites`/`AddtoFavourite`: there is **no remove**. The table has no `UNIQUE` constraint (ConflictAlgorithm.ignore does nothing), so tapping twice stores duplicates. List screens never read the favourites table, so the heart is not shown as filled. | Store favourites as a set of name ids; add `ToggleFavourite`; list/detail read from the same set. |
| A8 | Ads (6 files) | `setState` inside `onAdLoaded` without `mounted` check; banner is created per screen with the unit id copy-pasted 6×; `AdController` exists but is unused. Interstitial is shown on **every** gender tap before navigation. | Use the one `AdController`; adaptive banner; interstitial only every N navigations and never as a gate to content (Play policy). |
| A9 | `splash_screen.dart` | Fixed 5 s `Future.delayed`, then `Navigator` with no `mounted` check. | Native splash + navigate when data is ready. |
| A10 | `test/widget_test.dart` | Default counter test; fails, `MyApp` has no counter. | Replace with real tests (parser, search normalisation). |

## B. Speed

| # | Problem | Fix |
|---|---------|-----|
| B1 | `assets/splash_screen.gif` is **22.9 MB**, decoded frame by frame at launch; plus a mandatory 5 s wait. Biggest cause of slow cold start / low-end crashes. | Native splash (`flutter_native_splash`), small logo, no GIF. |
| B2 | Every gender tap re-reads and re-parses a 10–12 MB JSON (`ArabicData.json` 10.4 MB, `girls_name.json` 12.3 MB, ~26 fields per row, 30 % of values empty) and copies the whole string into an isolate. No caching. | Ship a pre-built SQLite DB (or one compact, gzip'd, de-duplicated file with only the fields actually shown), query with `LIMIT`/`OFFSET` and an index on the normalised name. First launch then needs no import step. |
| B3 | Image bloat: `w.png` 7.7 MB used as the background on every screen at full resolution; `aboveMenuImage.svg` 16 MB (unused), `1024.png`, `appbackground.jpg`, `wallpaper.jpg`, `w.jpg`, `splash.png`, `OnBoardingScreen.jpeg` are not referenced anywhere in `lib/`. The whole `assets/` folder is bundled. | Delete unused files, replace `w.png` with a ~150 KB gradient/pattern or plain `BoxDecoration`, list assets explicitly in `pubspec.yaml`. Expect the APK to shrink by roughly 40 MB of raw assets. |
| B4 | `main()` awaits `DefaultCacheManager().emptyCache()` before `runApp` – pointless (no network images) and delays start. `MobileAds.initialize()` not awaited / error-handled. | Remove the cache call; initialise ads after first frame. |
| B5 | Search filters ~12 k rows on the UI thread on every keystroke. | Debounce + DB query (B2). |
| B6 | 53 `print` calls, `log(data.toString())` of the entire favourites table. | Remove / `kDebugMode`. |

## C. Data

* **C1** – Pick one storage: bundled read-only SQLite is the right fit (fast, searchable, small).
* **C2** – Duplicates: `girls_name.json` has 12 291 unique names in 13 891 rows (1 279 dups), `ArabicData` 244, `trending_boys` 112, `trending_girls` 76. `toSet()` in the bloc only dedupes if `NameModel` overrides `==`/`hashCode` (I did not see that). Clean once in a script.
* **C3** – Many empty fields (lucky number/day/colour/stone/metal …). Showing "null" or blank rows in the detail screen looks broken; hide empty sections.
* **C4** – Fields are named `Urdu*` while the UI is Arabic. Worth confirming the text really is Arabic-script and what language the meanings are in, before the redesign.
* **C5** – "Trending/popular" is currently a static list with no ranking.

## D. Code health / housekeeping

* Unused dependencies: `azlistview`, `gif_view`, `intl`, `flutter_svg`; `icons_launcher` is a dev tool but sits under `dependencies`; `flutter_cache_manager` is used only to clear the cache.
* Dead files: `lib/scrolling_screen.dart` (fruit demo), `lib/DataBase/FireBase.dart` (all commented out), `SharedPreference.email/password/uID` keys.
* `NameModel` has 27 nullable strings; `dataBase.dart` maps them by hand twice. Use a small immutable model with only the fields shown.
* `my-release-key.jks` is tracked in git (public repo). Rotate/reset via Play App Signing and add `*.jks`, `key.properties` to `.gitignore`.
* Android 16 target: edge-to-edge is enforced; the bottom banner + `SafeArea` combination needs a device test.

## E. Design / UX (for the redesign)

* No real theme: `ColorScheme.fromSwatch()`, white text hard-coded over background images, no dark mode, no Arabic font, no explicit RTL `Directionality`/locale.
* List rows show only the name + 👨/👩 emoji; the meaning (the thing users want) is hidden behind a tap.
* Search lives inside the AppBar with black text on a coloured bar; 24 px alphabet rail is under the 48 dp touch target guideline.
* Navigation is 5 drawer items + 3 selection screens that are near copies of each other (~240 lines each); English "Extracting Data..." string in an Arabic app.
* Favourites, share and rating are buried in the detail page.

## Suggested order

1. **Foundation (speed + correctness)** – A1–A10, B1–B6: clean data, prebuilt DB, new repository, splash, asset diet, favourites, search, ads controller.
2. **Redesign** – Material 3 theme (light/dark), Arabic font, one list screen with filter chips (boys/girls/trending/celebrity), meaning in each row, search bar on top, name cards with origin/meaning/share/favourite.
3. **New data** – add a ranking/year/origin field to the schema first, then import the new names.
