-- ============================================================
-- GOLD: Monthly Revenue
-- Business Question: What is our revenue trend month over month?
-- Source: silver orders + silver order_items + silver order_payments
-- ============================================================

WITH orders AS (
    SELECT
        order_id,
        customer_id,
        order_status,
        order_purchase_timestamp,
        DATE_TRUNC('month', order_purchase_timestamp) AS order_month
    FROM workspace.silver.orders
    WHERE order_status = 'delivered'
),

payments AS (
    SELECT
        order_id,
        SUM(payment_value) AS total_payment
    FROM workspace.silver.order_payments
    GROUP BY order_id
),

monthly_revenue AS (
    SELECT
        o.order_month,
        COUNT(DISTINCT o.order_id)          AS total_orders,
        COUNT(DISTINCT o.customer_id)       AS unique_customers,
        ROUND(SUM(p.total_payment), 2)      AS total_revenue,
        ROUND(AVG(p.total_payment), 2)      AS avg_order_value
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
    GROUP BY o.order_month
)

SELECT
    order_month,
    total_orders,
    unique_customers,
    total_revenue,
    avg_order_value,
    ROUND(
        (total_revenue - LAG(total_revenue) OVER (ORDER BY order_month))
        / NULLIF(LAG(total_revenue) OVER (ORDER BY order_month), 0) * 100
    , 2) AS revenue_growth_pct
FROM monthly_revenue
ORDER BY order_month