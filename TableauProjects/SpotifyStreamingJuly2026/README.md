# Spotify Artist Streaming Analysis — Tableau Dashboards

An interactive Tableau workbook analyzing the most-streamed artists on Spotify for July 2026, built on top of a SQL-validated dataset (see the DataValidation section below for the full consistency-checking process). The workbook compares performance across genre, geography, role, and demographics, and documents a few data-integrity findings caught and resolved during development.

**Live dashboard:** [Spotify Streaming and Artist Composition — July 2026](https://public.tableau.com/app/profile/billy.conard/viz/SpotifyAnalysis2026/July26StreamingSpecs#1)

**Tableau Public profile:** [Billy Conard](https://public.tableau.com/app/profile/billy.conard/vizzes)

## Data Note

This dataset was sourced from Kaggle (500 unique artists, 14 columns). Before building any visuals, the underlying stream-count columns were validated in SQL:

- Total Streams decomposes cleanly into Solo Streams + Collaborative Streams — confirmed exact across all 500 rows, no discrepancy.
- Total Streams also decomposes into Lead Streams + Feature Streams — confirmed consistent, with negligible (<0.5%) rounding noise from decimal storage, not a data error.
- These are two *independent* breakdowns of the same total (by collaboration status, and separately by artist role), not four additive parts — summing all four together double-counts every stream and was caught early via a market-share sanity check that returned percentages over 100%.

All figures in both dashboards use validated fields only.

## Dashboards

### 1. July '26 Streaming Specs
Ranks artists and genres by total streams, with geographic context by country of origin.

**Business questions:**
1. What artists and/or genres account for the most streams in July?
2. How does each artist rank within their own genre?
3. How does each artist rank within their own country of origin?

**Design:** Genre, artist, and country selections cross-filter one another, with rank recalculating relative to the active selection (e.g., selecting a genre re-ranks the artist table by rank *within that genre*, not overall rank filtered down).

### 2. Artist Profile & Composition
Compares artist composition across genre, streaming role (lead vs. feature), and gender.

**Business questions:**
1. Which genres lean more collaborative vs. solo?
2. What's the average lead vs. feature stream split by artist type (solo/group)?
3. How do gender splits in total streams differ by artist type?
4. Among the top artists overall, who is collab-leaning vs. solo-leaning?

**Finding:** Solo artists show a lower average lead-stream percentage (68.5%) than group artists (84.3%), with solo artists' feature-stream share roughly double that of group artists (31.5% vs. 15.7%). This suggests solo artists guest on other artists' tracks more frequently, rather than being less prominent overall — an artist-type effect on stream *composition*, not stream *volume*.

**Design:** Uses highlight actions rather than filter actions between charts, so all categories stay visible for context (see Design Decisions below).

## Design Decisions

- **Highlight actions over filter actions** for cross-chart interactivity within Dashboard 2. An earlier draft used filter actions on percentage-based charts, which would have caused "% of total" values to recompute against whatever subset remained visible — mathematically correct but misleading at a glance. Dashboard 1 uses filter actions instead, since its charts show absolute rankings rather than percentage compositions, where re-scoping the data on click is the intended behavior.
- **AVG rather than SUM for pre-aggregated percentage fields** (e.g., % of Solo Streams, % Lead Streams). These fields are computed per-artist in the source data; summing them across a group inflates far past 100%, while averaging returns the mathematically correct group-level percentage.
- **Two focused dashboards instead of one combined view.** Streaming volume/rank and artist composition are different analytical lenses, and combining them into a single dashboard would have diluted both.

## Tools Used
- Kaggle — source dataset
- VS Code & DuckDB (SQL) — data validation and exploratory queries
- Tableau Public — dashboard building and publishing

*Part of the [Data Analytics Projects](../../) portfolio repository.*
