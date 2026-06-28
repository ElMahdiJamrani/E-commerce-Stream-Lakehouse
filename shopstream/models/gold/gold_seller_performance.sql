-- ============================================================
-- GOLD: Seller Performance
-- Business Question: Which sellers drive the most revenue
-- and have the best customer satisfaction?
-- ============================================================

WITH seller_orders AS (
    SELECT
        oi.seller_id,
        COUNT(DISTINCT oi.order_id)             AS total_orders,
        COUNT(oi.order_item_id)                 AS total_items_sold,
        ROUND(SUM(oi.price), 2)                 AS total_revenue,
        ROUND(AVG(oi.price), 2)                 AS avg_item_price,
        ROUND(SUM(oi.freight_value), 2)         AS total_freight
    FROM workspace.silver.order_items oi
    JOIN workspace.silver.orders o ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY oi.seller_id
),

seller_reviews AS (
    SELECT
        oi.seller_id,
        ROUND(AVG(r.review_score), 2)           AS avg_review_score,
        COUNT(r.review_id)                      AS total_reviews
    FROM workspace.silver.order_items oi
    JOIN workspace.silver.order_reviews r ON oi.order_id = r.order_id
    GROUP BY oi.seller_id
),

seller_delivery AS (
    SELECT
        oi.seller_id,
        ROUND(AVG(
            DATEDIFF(
                o.order_delivered_customer_date,
                o.order_purchase_timestamp
            )
        ), 1)                                   AS avg_delivery_days
    FROM workspace.silver.order_items oi
    JOIN workspace.silver.orders o ON oi.order_id = o.order_id
    WHERE o.order_delivered_customer_date IS NOT NULL
    GROUP BY oi.seller_id
)

SELECT
    s.seller_id,
    s.seller_city,
    s.seller_state,
    so.total_orders,
    so.total_items_sold,
    so.total_revenue,
    so.avg_item_price,
    so.total_freight,
    sr.avg_review_score,
    sr.total_reviews,
    sd.avg_delivery_days,
    -- Performance tier
    CASE
        WHEN so.total_revenue >= 50000
             AND sr.avg_review_score >= 4.0   THEN 'Top Seller'
        WHEN so.total_revenue >= 10000
             AND sr.avg_review_score >= 3.5   THEN 'Good Seller'
        WHEN sr.avg_review_score < 3.0        THEN 'Needs Improvement'
        ELSE 'Standard'
    END AS performance_tier
FROM workspace.silver.sellers s
LEFT JOIN seller_orders   so ON s.seller_id = so.seller_id
LEFT JOIN seller_reviews  sr ON s.seller_id = sr.seller_id
LEFT JOIN seller_delivery sd ON s.seller_id = sd.seller_id