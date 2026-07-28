# Cafe Sales Analysis — Tableau Dashboard

An interactive Tableau workbook analyzing revenue and sales volume for a fictional cafe business, built on top of a SQL-cleaned dataset (see the [DataCleaning](../../DataCleaning/) folder for the full cleaning and validation process). The workbook compares performance across three dimensions — item, location, and month — and documents the design decisions made along the way, including a few mistakes caught and corrected during development.

**Live dashboard:** https://public.tableau.com/app/profile/billy.conard/viz/CafeSalesAnalysis_17852674405110/VolumeRevenueByMonth#1
**Tableau Public profile:** https://public.tableau.com/app/profile/billy.conard/vizzes

## Data Note

This dashboard is built on the clean_sales view from the DataCleaning stage, not the raw dataset. Of the original 10,000 transactions, **4,121 (41.2%) were excluded** due to invalid item names, unknown/missing payment methods, or missing quantity data that made revenue impossible to calculate reliably. All figures in this dashboard reflect the remaining ~59% of transactions with complete, valid data.

## Dashboards

### 1. Revenue & Volume By Item
Compares total revenue, units sold, and each item's share of total revenue. Items are sorted descending by revenue across all charts on this dashboard, so the ranking is visually consistent and comparable at a glance rather than requiring the viewer to cross-reference labels.

**Finding:** Revenue and volume rankings mostly agree, but not entirely — Juice and Cookie sell disproportionately high volume relative to their revenue rank (they're cheaper, higher-frequency items), while items like Salad and Sandwich rank higher on revenue than on volume. This divergence is only visible because both charts share the same sort order; independently sorting each chart by its own metric would hide it, since any chart sorted by its own value always looks like a clean descending staircase regardless of whether there's a real relationship between the two metrics.

### 2. Revenue & Volume By Location
Compares In-store vs. Takeaway performance by item, plus each location's overall share of total revenue.

**Finding:** Item rankings are nearly identical between the two locations — location has minimal effect on which items sell best. This is itself a meaningful (if modest) finding, not a null result: it suggests item popularity is a stronger driver of sales than where the transaction occurs.

### 3. Revenue & Volume By Month
Tracks revenue and volume trends across the 12 months of the dataset.

**Finding:** Month-over-month revenue share stays close to the ~8.3% baseline expected if there were no seasonality at all (1/12 of the year). The variation observed (roughly 7.5%–9.0%) is consistent with random noise rather than a real seasonal pattern — an expected and honest result given the dataset is synthetically generated for practice, not real transactional history. This is reported as-is rather than framed as a trend that isn't actually supported by the data.

**Design note:** month must be sorted chronologically (Jan → Dec), not by revenue value — unlike Item or Location, month is a temporal dimension, and sorting it by measure instead of calendar order would make a flat or noisy trend look like a fabricated decline.

## Design Decisions

- **Highlight actions, not filter actions, for cross-dashboard interactivity.** An earlier version used a filter action between charts, which caused "% of total" calculations to recompute against whatever subset remained visible — clicking one item made it show as 100% of revenue, which is mathematically correct but meaningless. Switching to a highlight action keeps every item visible for context while still calling out the selected one.
- **One workbook, multiple focused dashboards**, rather than a single dashboard trying to cover item, location, and time all at once, or a separate Tableau Public "Viz" per dashboard. Each dashboard answers one specific question; all three live together as sheets/dashboards within a single published workbook.
- **Redundant charts were removed** where a percentage view and a raw-value view told the exact same story in the same order (e.g., an early draft displayed Revenue By Item and Percentage of Total Revenue as two separate, identically-ranked charts before they were combined).

## Tools Used

- SQLiteOnline.com — source data cleaning and analysis queries
- Tableau Public — dashboard building and publishing

---
*Part of the [Data Analytics Projects](../) portfolio repository.*
