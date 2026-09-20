-- ============================================================
-- funnel.sql  — Order-lifecycle funnel
-- Project: E-Commerce Product Analytics (Olist)
-- ============================================================
-- Idea: each order carries timestamps for the stages it went
-- through. A stage timestamp is NULL when that stage never
-- happened, so COUNT(column) counts only the orders that
-- reached that stage. Counting each stage gives us a funnel.
-- ============================================================

-- 1) Raw funnel: how many orders reach each stage.
SELECT
    COUNT(*)                             AS placed,
    COUNT(order_approved_at)             AS approved,
    COUNT(order_delivered_carrier_date)  AS shipped,
    COUNT(order_delivered_customer_date) AS delivered
FROM orders;


-- 2) Same funnel expressed as conversion % of orders placed.
--    Easier to read and what you'll put in the report.
WITH f AS (
    SELECT
        COUNT(*)                             AS placed,
        COUNT(order_approved_at)             AS approved,
        COUNT(order_delivered_carrier_date)  AS shipped,
        COUNT(order_delivered_customer_date) AS delivered
    FROM orders
)
SELECT
    ROUND(100.0 * approved  / placed, 1) AS pct_approved,
    ROUND(100.0 * shipped   / placed, 1) AS pct_shipped,
    ROUND(100.0 * delivered / placed, 1) AS pct_delivered
FROM f;


-- 3) Stage-to-stage conversion (where is the *biggest* single leak?).
WITH f AS (
    SELECT
        COUNT(*)                             AS placed,
        COUNT(order_approved_at)             AS approved,
        COUNT(order_delivered_carrier_date)  AS shipped,
        COUNT(order_delivered_customer_date) AS delivered
    FROM orders
)
SELECT
    ROUND(100.0 * approved  / placed,   1) AS placed_to_approved,
    ROUND(100.0 * shipped   / approved, 1) AS approved_to_shipped,
    ROUND(100.0 * delivered / shipped,  1) AS shipped_to_delivered
FROM f;
