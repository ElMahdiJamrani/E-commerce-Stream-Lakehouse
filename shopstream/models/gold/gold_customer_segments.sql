-- ============================================================
-- GOLD: Customer Segments
-- Business Question: Who are our most valuable customers?
-- This table is the foundation for churn prediction in Milestone 4
-- ============================================================

WITH customer_orders AS (
    SELECT
        o.customer_id,
        COUNT(DISTINCT o.order_id)              AS total_orders,
        MIN(o.order_purchase_timestamp)         AS first_order_date,
        MAX(o.order_purchase_timestamp)         AS last_order_date,
        DATEDIFF(
            MAX(o.order_purchase_timestamp),
            MIN(o.order_purchase_timestamp)
        )                                       AS customer_lifespan_days
    FROM workspace.silver.orders o
    WHERE o.order_status = 'delivered'
    GROUP BY o.customer_id
),

customer_payments AS (
    SELECT
        o.customer_id,
        ROUND(SUM(p.payment_value), 2)          AS total_revenue,
        ROUND(AVG(p.payment_value), 2)          AS avg_order_value
    FROM workspace.silver.orders o
    JOIN workspace.silver.order_payments p ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.customer_id
),

customer_reviews AS (
    SELECT
        o.customer_id,
        ROUND(AVG(r.review_score), 2)           AS avg_review_score
    FROM workspace.silver.orders o
    JOIN workspace.silver.order_reviews r ON o.order_id = r.order_id
    GROUP BY o.customer_id
),

combined AS (
    SELECT
        c.customer_id,
        co.total_orders,
        cp.total_revenue,
        cp.avg_order_value,
        co.first_order_date,
        co.last_order_date,
        co.customer_lifespan_days,
        cr.avg_review_score,
        DATEDIFF(CURRENT_DATE(), co.last_order_date) AS days_since_last_order
    FROM workspace.silver.customers c
    LEFT JOIN customer_orders co      ON c.customer_id = co.customer_id
    LEFT JOIN customer_payments cp    ON c.customer_id = cp.customer_id
    LEFT JOIN customer_reviews cr     ON c.customer_id = cr.customer_id
)

SELECT
    customer_id,
    total_orders,
    total_revenue,
    avg_order_value,
    first_order_date,
    last_order_date,
    customer_lifespan_days,
    avg_review_score,
    days_since_last_order,
    -- RFM Segmentation (Recency, Frequency, Monetary)
    CASE
        WHEN total_orders IS NULL                        THEN 'Never Purchased'
        WHEN days_since_last_order <= 90
             AND total_orders >= 2                       THEN 'Champion'
        WHEN days_since_last_order <= 90                 THEN 'Active'
        WHEN days_since_last_order BETWEEN 91 AND 180    THEN 'At Risk'
        WHEN days_since_last_order > 180                 THEN 'Churned'
        ELSE 'Unknown'
    END AS customer_segment
FROM combined