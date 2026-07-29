# Patient Hypertension & BMI Analysis — Tableau Dashboard

An exploratory Tableau workbook analyzing hypertension prevalence and BMI trends across exercise level, age, and gender, built on a synthetic patient health dataset originally sourced from Kaggle. Early exploration used SQL queries written against the raw dataset (see the [Healthcare Dataset](../../HealthcareDataset/) folder, if applicable, for that groundwork) before moving into Tableau Public for visualization and calculated-field analysis.

**Live dashboard:** https://public.tableau.com/app/profile/billy.conard/viz/PatientMedicationOutcomeAnalysis/BloodPressureBreakdownbyExerciseLevel#1

**Tableau Public profile:** https://public.tableau.com/app/profile/billy.conard/vizzes

## Data Note

This workbook uses a relationship between the patients, outcomes and medications data sources (linked on Patient ID). Because a single patient can have multiple medication records, naive SUM/COUNT aggregations across the relationship double-count patients. All percentage calculations in this workbook use COUNTD (count distinct) on Patient ID to guarantee one count per patient, regardless of how many medication rows they're joined to.

## Dashboards & Findings

### 1. Hypertension Rates Dashboard
Compares hypertension prevalence (% of patients diagnosed) across exercise level (Inactive/Sedentary, Light, Moderate, Vigorous) and sex.

**Finding:** Prevalence is essentially flat across every subgroup, ranging narrowly from about 70% to 74%, regardless of exercise level or sex. Females with light and vigorous exercise levels show a slightly higher rate than males in the same categories, while inactive or moderately active males run slightly higher than their female counterparts — but these differences are modest (a few percentage points) against a consistently high baseline. Contrary to the expectation that more active patients would show meaningfully lower hypertension rates, exercise level does not appear to be a strong differentiator in this dataset.

### 2. BMI Breakdown by Age Dashboard
Scatter plots of average BMI by age, split by sex (Female and Male panels share the same y-axis scale for direct comparison).

**Finding:** Average BMI holds steady around 27.5 across nearly the entire adult age range, regardless of gender. Outlier *average* BMI values appear mainly in ages under 30 (likely a smaller sample size at those ages), while outlier *individual* BMI values (min 16, max 49.9 for females at age 82 and 51.4 for males at age 79) appear scattered across all ages rather than clustering at any particular life stage.

### 3. Average BP by Exercise Level Worksheet
Compares average systolic/diastolic blood pressure across exercise level and sex.

**Finding:** Average blood pressure ranges narrowly from 133/84 to 134/85 across all exercise levels and both sexes — another metric that shows minimal variation across the dimensions tested.

## Design Decisions

- **{FIXED} LOD expressions for population-level baselines, plain aggregates for subgroup rates.** Comparing "this subgroup's rate" against "the overall population rate" required two different calculation styles: an unscoped {FIXED : ...} expression that ignores the view entirely for the population baseline, and a plain COUNTD-based aggregate that recomputes per-cell for subgroup prevalence. Using the wrong one produces a number that's technically valid Tableau syntax but answers a different question than intended — this was caught early by noticing an identical percentage repeating across every subgroup in the tooltip, which turned out to be the population-fixed calculation working correctly rather than a bug.
- **COUNTD instead of SUM/COUNT for anything crossing the patients–medications relationship.** Since patients can have multiple medication rows, plain SUM(Hypertension Diagnosis)/COUNT(Patient Id) inflated well past 100% due to row duplication. Switching both numerator and denominator to COUNTD on Patient ID collapses back to one row per patient before the ratio is computed.
- **Bar height must encode the same measure as the label.** An early version of the Hypertension Rates chart used raw diagnosis count (SUM) for bar height but percentage for the label — since count depends on subgroup size and percentage is normalized for it, taller bars didn't necessarily mean higher rates, which is misleading at a glance. Bar height was switched to the percentage measure itself so visual height and printed label always agree.
- **Matched axis scales across split panels.** The Female/Male BMI scatter plots share an identical y-axis range so a viewer can't be misled by independently auto-scaled axes into over- or under-reading a difference between the two groups.
- **Flat/null findings are reported as findings, not hidden.** Several of the core metrics here (hypertension prevalence, BMI, blood pressure) show minimal variation across exercise level — this is stated directly rather than reframed to imply a stronger relationship than the data supports, consistent with this being a synthetic dataset without necessarily strong engineered correlations between fields.

## Tools Used

- SQL — initial exploratory queries on the raw dataset
- Tableau Public — dashboard building, calculated fields (including LOD expressions), and publishing

---
*Part of the [Data Analytics Projects](../../) portfolio repository. Additional dashboards covering patient length of stay and medication data are in progress.*
