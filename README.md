# Device Performance & Purchase Funnel Analysis

**Where is a marketing-driven e-commerce site losing customers, and why?**

A SQL + Python + Tableau analysis of the Google Analytics Sample Dataset (Google
Merchandise Store), built as an MSBA portfolio project.

---

## The Finding

Desktop sessions convert at **~5x** the rate of mobile or tablet (2.05% vs. 0.39%/0.41%) and among sessions that *do* convert, desktop buyers also spend
significantly more per order ($130.29 vs. $67.25 mobile, $38.01 tablet). Breaking the
purchase funnel out by device shows the conversion gap **widens at every
stage**, peaking at the final Checkout → Purchase step, pointing to checkout/payment friction
as the most likely cause rather than a general browsing problem.

**Recommendation:** Prioritize an audit of the  mobile checkout process to better understand why customers are lost here. 

---

## Live Dashboard

**[View the interactive Tableau Public dashboard →](https://public.tableau.com/views/GoogleAnalyticsDashboard_17871650518290/Dashboard1?:language=en-US&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)**

---

## Repository Contents

| File | Description |
|---|---|
| [`Final_GA_Portfolio_Queries.sql`](final_ga_portfolio_queries.sql) | All SQL queries, run in BigQuery against the public GA sample dataset |
| [`FINAL_segment_hypothesis_testing.ipynb`](FINAL_segment_hypothesis_testing.ipynb) | Python notebook: two-proportion z-tests, chi-square test, and confidence intervals |
| [`dashboard.twbx`](dashboard.twbx) | Tableau Public packaged workbook |
| `data/` | All query results (CSV) used by the notebook and dashboard |

---

## Approach

1. **SQL (BigQuery)** — Extracted and aggregated session-level data from
   `bigquery-public-data.google_analytics_sample`
2. **Python (`scipy`, `statsmodels`)** - Ran hypothesis tests to check whether observed
   differences between segments were statistically significant or plausibly due to chance
3. **Tableau Public** - Built an interactive dashboard visualizing the device-performance
   story

## Scope & Methodology Notes

- **Date range:** all analysis is restricted to a single month (July 2017) to hold
  seasonality constant across comparisons, so that device and channel level differences
  reflect genuine behavioral differences rather than seasonal effects.
- **Average order value (AOV)** is calculated among *converting* sessions only which
  isolates spend per purchase from likelihood of purchase, so it can be compared
  independently of the conversion rate finding.
- **Total Sessions (74,368)** in the dashboard's KPI tile is a sum of daily distinct
  session counts; the device breakdown (74,263) uses a single distinct count across the
  full period. The ~0.1% difference reflects a small number of session IDs that recur
  across multiple days in this sample dataset.

## Limitations

- **Device-level, not person-level:** This dataset identifies visitors using `fullVisitorId`,
  a device/browser-scoped identifier — not a persistent identity. If the same person visits
  on their phone and later returns on their laptop, these appear as two unrelated visitors
  with no way to link them. `fullVisitorId` also resets if a user clears cookies. As a result,
  this analysis cannot measure cross-device behavior (e.g., users who browse on mobile and
  purchase on desktop), and the device-level conversion gap reported here may be partly
  inflated by real purchase journeys that started on mobile but converted on desktop under a
  different session ID. A production GA4 implementation with Google Signals or authenticated
  User-ID tracking would be needed to analyze this properly.
- **Correlational, not causal:** The funnel and hypothesis tests establish that the device
  gap is statistically significant but it does not explain why it exists. Friction in the mobile checkout process
  (likely due to screen size) is a very likely and logical read of the funnel shape, but confirming it would require
  further research as suggested. 
- **Single-month window:** Restricting to July 2017 controls for seasonality but means the
  findings reflect one month of behavior and haven't been validated against other periods.
- **Conversion only, no cost data:** The channel finding (paid vs. unpaid, CPC vs. organic)
  compares conversion rates only. Without acquisition cost per channel, this can't be used
  directly to justify reallocating budget.

## Key Findings

- **Device:** Desktop significantly outperforms mobile and tablet on both conversion rate
  and average order value.
- **Funnel:** The desktop vs. mobile gap widens at every stage of the purchase funnel,
  peaking at Checkout → Purchase (1.72x). This is the strongest evidence pointing
  toward checkout/payment friction on mobile.
- **Channel:** Paid traffic converts at a significantly higher rate than unpaid overall
  (2.36% vs. 1.44%), and CPC specifically outperforms organic by an even wider margin (2.24%
  vs. 0.81%). This suggests that the aggregate unpaid segment rate is propped up by direct/referral
  traffic rather than organic search. This measures conversion only, not ROI, so additional acquisition
  cost data would be needed before making a budget decision.





## Tools

`SQL (BigQuery)` · `Python (pandas, scipy, statsmodels)` · `Tableau Public`
