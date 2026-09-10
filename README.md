# Device Performance & Purchase Funnel Analysis

**Where is a marketing-driven e-commerce site losing customers, and why?**

A SQL + Python + Tableau analysis of the Google Analytics Sample Dataset (Google
Merchandise Store), built as an MSBA portfolio project.

---

## Key Findings

| Segment | Result |
|---|---|
| Paid vs. unpaid traffic | Paid converts 1.6x higher (2.36% vs. 1.44%|
| CPC vs. organic (top channels) | CPC converts ~2.8x higher than organic (2.24% vs. 0.82%) |
| Desktop vs. mobile/tablet | Desktop converts ~5x higher than either (2.05% vs. 0.39%/0.41%|
| Avg. order value | Desktop ($130) significantly exceeds mobile ($67) and tablet ($38); mobile vs. tablet difference not statistically confirmed (overlapping CIs) |

**Channel:** Paid traffic significantly outperforms unpaid overall. Within unpaid, the aggregate rate is being propped up by direct/referral traffic rather than organic search specifically. A full spend recommendation would need acquisition cost data, which isn't included in this dataset.

**Device:** The real divide is desktop versus portable devices — mobile and tablet convert at similar rates (0.39% vs. 0.41%) and their average order values, while numerically different, aren't statistically distinguishable given overlapping confidence intervals. The funnel breakdown shows the gap between desktop and mobile widens at every stage, peaking at Checkout→Purchase (53.1% vs. 30.8%). Interestingly, tablet outperforms mobile at that same final step (36.1% vs. 30.8%), even though tablet dips earlier at Cart→Checkout, suggesting mobile's friction is more evenly spread across the whole purchase process, while tablet's weak point is more localized (though it should be noted that tablet's sample size is much smaller, with 13 total conversions vs. mobile's 94, means that pattern should be treated cautiously).

**Recommendation:** Prioritize an audit of the mobile checkout process, since the largest gap is between desktop and mobile. This should be a full review of the mobile purchase-experience, since mobile's friction shows up consistently at every stage rather than being isolated to checkout. Tablet's smaller, noisier sample means the dip at cart to checkout stage is worth monitoring but not yet acting on. For channel strategy, acquisition cost data is needed before making changes to the budget. 

## Live Dashboard

The dashboard focuses on the device story - looking at conversion rates and the purchase funnel breakdown while additional findings on channel performance were included in the SQL queries and python notebook. 

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



## Tools

`SQL (BigQuery)` · `Python (pandas, scipy, statsmodels)` · `Tableau Public`
