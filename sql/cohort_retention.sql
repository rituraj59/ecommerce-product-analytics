-- ============================================================
-- cohort_retention.sql — Monthly acquisition cohorts
-- Project: E-Commerce Product Analytics (Olist)
-- ============================================================
-- Goal: group each customer by the month of their FIRST order
-- (their cohort), then count how many are still ordering N
-- months later. This shows how fast retention decays.
--
-- CRITICAL: join to `customers` and use customer_unique_id,
-- NOT customer_id. customer_id is per-order in this dataset;
-- customer_unique_id identifies the real person across orders.
-- ============================================================

WITH order_months AS (
    -- one row per (real customer, order), truncated to month
    SELECT
        c.customer_unique_id,
        date_trunc('month', o.order_purchase_timestamp) AS order_month
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_purchase_timestamp IS NOT NULL
),

cohorts AS (
    -- each customer's cohort = month of their first order
    SELECT
        customer_unique_id,
        MIN(order_month) AS cohort_month
    FROM order_months
    GROUP BY customer_unique_id
),

activity AS (
    -- for every order, how many months after the cohort month it happened
    SELECT
        om.customer_unique_id,
        ch.cohort_month,
        date_diff('month', ch.cohort_month, om.order_month) AS month_number
    FROM order_months om
    JOIN cohorts ch ON om.customer_unique_id = ch.customer_unique_id
)

-- customers active in each (cohort, month_number) cell
SELECT
    cohort_month,
    month_number,
    COUNT(DISTINCT customer_unique_id) AS customers
FROM activity
GROUP BY cohort_month, month_number
ORDER BY cohort_month, month_number;

-- Next step in Python: pivot this (cohort_month as rows,
-- month_number as columns), divide each row by its month_0
-- value to get retention %, and draw it as a heatmap.
