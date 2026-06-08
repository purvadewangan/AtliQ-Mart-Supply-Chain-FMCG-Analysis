-- Ranks customers within their city by OTIF performance.
-- RANK() assigns the same rank to tied values.
-- Helps identify whether the worst customer in Surat is
-- worse than the worst customer in Vadodara.

CREATE VIEW v_customer_city_rank AS
WITH customer_otif AS (
    SELECT
        c.customer_name,
        c.city,
        ROUND(SUM(f.otif)::NUMERIC /
              COUNT(*) * 100, 2)                    AS otif_pct,
        t.otif_target_pct                           AS otif_target,
        ROUND(SUM(f.otif)::NUMERIC /
              COUNT(*) * 100, 2) -
        t.otif_target_pct                           AS otif_gap
    FROM fact_orders_agg f
    JOIN dim_customers c      ON f.customer_id = c.customer_id
    JOIN dim_targets_orders t ON f.customer_id = t.customer_id
    GROUP BY
        c.customer_name, c.city,
        t.otif_target_pct
)
SELECT
    customer_name,
    city,
    otif_pct,
    otif_target,
    otif_gap,
    RANK() OVER (
        PARTITION BY city
        ORDER BY otif_pct ASC
    )                                               AS rank_within_city,
    RANK() OVER (
        ORDER BY otif_pct ASC
    )                                               AS overall_rank
FROM customer_otif
ORDER BY city, rank_within_city;