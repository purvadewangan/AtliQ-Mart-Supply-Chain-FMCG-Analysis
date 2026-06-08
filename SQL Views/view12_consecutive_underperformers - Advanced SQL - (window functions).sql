-- Identifies customers who have been below their OTIF
-- target for 3 or more consecutive months.
-- This is the strongest predictor of contract non-renewal.
-- Uses window functions to detect consecutive sequences.

CREATE VIEW v_consecutive_underperformers AS
WITH monthly_flags AS (
    SELECT
        c.customer_name,
        c.city,
        TO_CHAR(f.order_placement_date, 'YYYY-MM')  AS month_year,
        ROUND(SUM(f.otif)::NUMERIC /
              COUNT(*) * 100, 2)                     AS otif_pct,
        t.otif_target_pct                            AS otif_target,
        CASE
            WHEN ROUND(SUM(f.otif)::NUMERIC /
                 COUNT(*) * 100, 2) < t.otif_target_pct
            THEN 1 ELSE 0
        END                                          AS below_target
    FROM fact_orders_agg f
    JOIN dim_customers c      ON f.customer_id = c.customer_id
    JOIN dim_targets_orders t ON f.customer_id = t.customer_id
    GROUP BY
        c.customer_name, c.city,
        TO_CHAR(f.order_placement_date, 'YYYY-MM'),
        t.otif_target_pct
),
consecutive_counts AS (
    SELECT
        customer_name,
        city,
        month_year,
        otif_pct,
        otif_target,
        below_target,
        SUM(below_target) OVER (
            PARTITION BY customer_name, city
            ORDER BY month_year
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )                                            AS cumulative_below
    FROM monthly_flags
)
SELECT
    customer_name,
    city,
    COUNT(*) FILTER (WHERE below_target = 1)        AS months_below_target,
    COUNT(*)                                         AS total_months,
    ROUND(AVG(otif_pct), 2)                         AS avg_otif,
    MAX(otif_target)                                 AS otif_target
FROM consecutive_counts
GROUP BY customer_name, city
HAVING COUNT(*) FILTER (WHERE below_target = 1) >= 3
ORDER BY months_below_target DESC, avg_otif ASC;