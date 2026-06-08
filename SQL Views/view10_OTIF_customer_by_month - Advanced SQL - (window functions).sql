-- Shows each customer's cumulative OTIF trend over time.
-- LAG function compares current month to previous month.
-- This surfaces which customers are improving vs declining.

CREATE VIEW v_customer_monthly_trend AS
WITH monthly_customer AS (
    SELECT
        c.customer_name,
        c.city,
        TO_CHAR(f.order_placement_date, 'YYYY-MM') AS month_year,
        COUNT(*)                                    AS total_orders,
        ROUND(SUM(f.otif)::NUMERIC /
              COUNT(*) * 100, 2)                    AS otif_pct,
        t.otif_target_pct                           AS otif_target
    FROM fact_orders_agg f
    JOIN dim_customers c      ON f.customer_id = c.customer_id
    JOIN dim_targets_orders t ON f.customer_id = t.customer_id
    GROUP BY
        c.customer_name, c.city,
        TO_CHAR(f.order_placement_date, 'YYYY-MM'),
        t.otif_target_pct
)
SELECT
    customer_name,
    city,
    month_year,
    total_orders,
    otif_pct,
    otif_target,
    ROUND(otif_pct - otif_target, 2)               AS otif_gap,
    LAG(otif_pct) OVER (
        PARTITION BY customer_name, city
        ORDER BY month_year
    )                                               AS prev_month_otif,
    ROUND(otif_pct - LAG(otif_pct) OVER (
        PARTITION BY customer_name, city
        ORDER BY month_year
    ), 2)                                           AS month_on_month_change
FROM monthly_customer
ORDER BY customer_name, city, month_year;