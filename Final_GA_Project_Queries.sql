# queries filtered by the same sample month 

-- Totals by Day
SELECT
  PARSE_DATE('%Y%m%d', date) AS visit_date,
  COUNT(DISTINCT CONCAT(fullVisitorId, CAST(visitId AS STRING))) AS sessions,
  SUM(totals.transactions) AS transactions,
  ROUND(SUM(totals.transactionRevenue) / 1e6, 2) AS revenue_usd
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20170701' AND '20170801'
GROUP BY visit_date
ORDER BY visit_date;


-- View to Purchase Funnel by Device Type 
WITH session_actions AS (
  SELECT
    CONCAT(fullVisitorId, CAST(visitId AS STRING)) AS session_id,
    device.deviceCategory AS device_type,
    MAX(IF(hits.eCommerceAction.action_type = '2', 1, 0)) AS viewed_product,
    MAX(IF(hits.eCommerceAction.action_type = '3', 1, 0)) AS added_to_cart,
    MAX(IF(hits.eCommerceAction.action_type = '5', 1, 0)) AS reached_checkout,
    MAX(IF(hits.eCommerceAction.action_type = '6', 1, 0)) AS purchased
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`,
    UNNEST(hits) AS hits
  WHERE _TABLE_SUFFIX BETWEEN '20170701' AND '20170801'
  GROUP BY session_id, device_type
)
SELECT
  device_type,
  COUNT(*) AS total_sessions,
  SUM(viewed_product) AS product_views,
  SUM(added_to_cart) AS add_to_cart,
  SUM(reached_checkout) AS checkout,
  SUM(purchased) AS purchases,
  ROUND(SUM(added_to_cart)  / NULLIF(SUM(viewed_product), 0)  * 100, 1) AS view_to_cart_pct,
  ROUND(SUM(reached_checkout) / NULLIF(SUM(added_to_cart), 0) * 100, 1) AS cart_to_checkout_pct,
  ROUND(SUM(purchased) / NULLIF(SUM(reached_checkout), 0) * 100, 1) AS checkout_to_purchase_pct,
  ROUND(SUM(purchased) / NULLIF(SUM(viewed_product), 0) * 100, 2) AS overall_conversion_pct
FROM session_actions
GROUP BY device_type
ORDER BY total_sessions DESC;


-- Sessions & Conversions by Medium - for two proportion z-test
SELECT
  CASE
    WHEN trafficSource.medium = '(not set)' THEN 'unknown' # clear label for output
    ELSE trafficSource.medium
  END AS segment,
  COUNT(DISTINCT CONCAT(fullVisitorId, CAST(visitId AS STRING))) AS sessions,
  COUNTIF(totals.transactions >= 1) AS conversions
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20170701' AND '20170801'
GROUP BY segment
ORDER BY sessions DESC;

-- Sessions & Conversions: Paid vs. Unpaid Traffic (aggregate)
SELECT
  CASE
    WHEN trafficSource.medium IN ('cpc', 'cpm') THEN 'paid'
    WHEN trafficSource.medium IN ('organic', 'referral', '(none)') THEN 'unpaid'
    ELSE 'excluded'  # excludes affiliate, (not set), and anything else
  END AS segment,
  COUNT(DISTINCT CONCAT(fullVisitorId, CAST(visitId AS STRING))) AS sessions, 
  COUNTIF(totals.transactions >= 1) AS conversions
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20170701' AND '20170801'
GROUP BY segment
HAVING segment != 'excluded'; # ensures only unpaid and paid are in the output

-- Conversions and Sessions by Device Type - for chi square test 
SELECT
  device.deviceCategory AS device_type,
  COUNT(DISTINCT CONCAT(fullVisitorId, CAST(visitId AS STRING))) AS sessions,
  COUNTIF(totals.transactions >= 1) AS conversions
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20170701' AND '20170801'
GROUP BY device_type
ORDER BY sessions DESC;

-- Revenue per Session by Device - for confidence intervals (includes purchases only - excludes nulls)
SELECT
  device.deviceCategory AS device_type,
  COUNTIF(totals.transactions >= 1) AS n_sessions,
  ROUND(AVG(IF(totals.transactions >= 1, totals.transactionRevenue / 1e6, NULL)), 4) AS mean_revenue_usd,
  ROUND(STDDEV(IF(totals.transactions >= 1, totals.transactionRevenue / 1e6, NULL)), 4) AS stddev_revenue_usd
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20170701' AND '20170801'
GROUP BY device_type
ORDER BY n_sessions DESC;