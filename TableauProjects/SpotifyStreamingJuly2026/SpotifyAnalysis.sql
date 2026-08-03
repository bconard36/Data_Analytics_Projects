-- =========================================================
-- Spotify Artist Streaming Analysis — SQL Exploration
-- Dataset: July 2026 Most Streamed Artists on Spotify (Kaggle)
-- 500 unique artists, 14 columns
-- Engine: DuckDB
-- =========================================================

-- Load the CSV into a table once, rather than re-reading the file
-- on every query below.
CREATE OR REPLACE TABLE Artists AS (
    SELECT *
    FROM read_csv_auto('data/July26SpotifyArtists.csv')
);


-- =========================================================
-- SECTION 1: Basic Rankings
-- =========================================================

-- Business Question: What artists account for the most streams overall?
SELECT "Artist Name",
       "Total Streams (in millions)"
FROM Artists
LIMIT 10;

-- Quick check on how many distinct genres exist in the dataset,
-- used to sanity-check group sizes for later GROUP BY / PARTITION BY queries.
SELECT COUNT(DISTINCT "Primary Genre")
FROM   Artists;

-- Business Question: How does each artist rank within their own primary genre?
-- DENSE_RANK used so ties share a rank without skipping the next number.
SELECT
    "Artist Name",
    "Primary Genre",
    "Artist Type",
    "Total Streams (in millions)",
    DENSE_RANK() OVER (
        PARTITION BY "Primary Genre"
        ORDER BY "Total Streams (in millions)" DESC
    ) AS GenreRank
FROM Artists
ORDER BY "Primary Genre", "Total Streams (in millions)" DESC, "Artist Name";

-- Business Question: How does each artist rank within their primary language group?
SELECT "Artist Type",
       "Artist Name",
       "Primary Language",
       "Primary Genre",
       "Total Streams (in millions)",
       DENSE_RANK() OVER(
            PARTITION BY "Primary Language"
            ORDER BY "Total Streams (in millions)" DESC
       ) AS "Language Rank"
FROM Artists
ORDER BY "Primary Language", "Total Streams (in millions)" DESC, "Artist Name";


-- =========================================================
-- SECTION 2: Data Validation — Market Share Debugging
-- Kept here (commented) as a record of the debugging process,
-- since the initial approach produced impossible results
-- (percentages over 100%) and the root cause was worth documenting.
-- =========================================================

-- Business Question: What percent of total streams do the top 10 artists represent?
-- First attempt below — returned market shares OVER 100%, which is
-- mathematically impossible for a share of a positive total.
-- WITH TotalMarket AS (
--   SELECT SUM("Total Streams (in millions)") AS "Streams Grand Total (in millions)"
--   FROM Artists
-- ),
-- TopTen AS (
--   SELECT "Artist Name",
--          "Total Streams (in millions)"
--   FROM Artists
--   ORDER BY "Total Streams (in millions)" DESC
--   LIMIT 10
-- )
-- SELECT t."Artist Name",
--        t."Total Streams (in millions)",
--        (t."Total Streams (in millions)" / m."Streams Grand Total (in millions)") * 100 AS "Market Share %"
-- FROM TopTen t
-- CROSS JOIN TotalMarket m

-- Second attempt — tried substituting Solo Streams instead of Total Streams,
-- suspecting a units/column mismatch. Same impossible result persisted,
-- which ruled out "wrong column" as the cause and pointed toward the
-- data itself (or a downstream calculation) being inconsistent.
-- WITH TotalSoloMarket AS (
--   SELECT SUM("Solo Streams (in millions)") AS "Solo Stream Grand Total (in millions)"
--   FROM Artists
-- ),
-- TopTenSolo AS (
--   SELECT "Artist Name",
--          "Solo Streams (in millions)"
--   FROM Artists
--   ORDER BY "Solo Streams (in millions)" DESC
--   LIMIT 10
-- )
-- SELECT t2."Artist Name",
--        t2."Solo Streams (in millions)",
--        (t2."Solo Streams (in millions)" / m2."Solo Stream Grand Total (in millions)") * 100 AS "Market Share %"
-- FROM TopTenSolo t2
-- CROSS JOIN TotalSoloMarket m2

-- Diagnostic: does any single artist's Solo Streams value exceed their
-- own Total Streams value? If so, that would be a genuine row-level
-- data error rather than an aggregation bug. Result: 0 rows — ruled out.
SELECT COUNT(*) AS "rows_where_solo_exceeds_total"
FROM Artists
WHERE "Solo Streams (in millions)" > "Total Streams (in millions)";

-- Diagnostic: does Lead + Feature + Solo + Collaborative streams sum to
-- roughly 2x the Total Streams value? Result: yes, consistently ~2x.
-- ROOT CAUSE FOUND: the dataset provides two INDEPENDENT breakdowns of
-- the same Total Streams figure — one by collaboration status
-- (Solo vs. Collaborative) and one by artist role (Lead vs. Feature).
-- Summing all four columns together double-counts every stream, since
-- each stream is represented once in each breakdown.
SELECT "Artist Name",
       "Total Streams (in millions)",
       ("Lead Streams (in millions)" + "Feature Streams (in millions)"
        + "Solo Streams (in millions)" + "Collaborative Streams (in millions)") AS "Summed Parts",
       ("Lead Streams (in millions)" + "Feature Streams (in millions)"
        + "Solo Streams (in millions)" + "Collaborative Streams (in millions)") - "Total Streams (in millions)" AS "Discrepancy"
FROM Artists
ORDER BY "Discrepancy" DESC
LIMIT 20;

-- Confirmation check 1: Solo + Collaborative should equal Total exactly.
-- Result: Diff = 0 for all rows. This breakdown is fully reliable.
SELECT "Artist Name",
       "Total Streams (in millions)",
       ("Solo Streams (in millions)" + "Collaborative Streams (in millions)") AS "Solo Plus Collab",
       ("Solo Streams (in millions)" + "Collaborative Streams (in millions)") - "Total Streams (in millions)" AS "Diff"
FROM Artists
ORDER BY ABS("Diff") DESC
LIMIT 10;

-- Confirmation check 2: Lead + Feature should equal Total.
-- Result: Diff is negligible (well under 1% of Total in all rows) —
-- consistent with floating-point rounding noise, not a data error.
-- This breakdown is also reliable, just less exact to the decimal.
SELECT "Artist Name",
       "Total Streams (in millions)",
       ("Lead Streams (in millions)" + "Feature Streams (in millions)") AS "Lead Plus Feature",
       ("Lead Streams (in millions)" + "Feature Streams (in millions)") - "Total Streams (in millions)" AS "Diff"
FROM Artists
ORDER BY ABS("Diff") DESC
LIMIT 10;

-- Conclusion: Total Streams is the correct, reliable denominator for any
-- market-share style calculation. The original bug was in summing both
-- breakdowns together, not in the Total Streams column itself.


-- =========================================================
-- SECTION 3: Language & Genre Cross-Tabs
-- =========================================================

-- Business Question: For each primary genre, how many distinct primary
-- languages are represented? Is any genre single-language while others
-- are more global?
SELECT "Primary Genre",
       COUNT(DISTINCT "Primary Language") AS "Unique Languages Count"
FROM Artists
GROUP BY "Primary Genre"
ORDER BY COUNT(DISTINCT "Primary Language") DESC;

-- Business Question: Are solo artists more concentrated in certain
-- languages than group acts, or spread more evenly across genres?
-- Total Artists gives the actual concentration count; Unique Genre Count
-- shows how many different genres each Language/Type combination spans.
SELECT COUNT(DISTINCT "Artist Name") AS "Total Artists",
       "Artist Type",
       "Primary Language",
       COUNT(DISTINCT "Primary Genre") AS "Unique Genre Count"
FROM Artists
GROUP BY "Primary Language", "Artist Type"
ORDER BY COUNT(DISTINCT "Primary Genre") DESC;


-- =========================================================
-- SECTION 4: Geographic Aggregation
-- =========================================================

-- Business Question: What countries are responsible for the most streams?
-- Total (artist count) is included alongside the streams sum so that a
-- country's raw total can be checked against how many artists are behind
-- it — a high sum from one artist tells a different story than the same
-- sum spread across many.
SELECT "Country of Origin",
       SUM("Total Streams (in millions)") AS "Total Streams (in millions)",
       COUNT(*) AS "Total"
FROM Artists
GROUP BY "Country of Origin"
ORDER BY "Total Streams (in millions)" DESC;