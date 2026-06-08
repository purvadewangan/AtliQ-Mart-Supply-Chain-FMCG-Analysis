-- Flags customers whose recent OTIF is below target.
-- SQL version is a static flag based on overall performance
-- gap. The dynamic rolling trend detection was done in
-- Python using the 4-week rolling window.
-- SQL complements Python here - Python found who is trending
-- down, SQL structures that for dashboard consumption.

CREATE VIEW v_at_risk_customers AS
SELECT
    c.customer_id,
    c.customer_name,
    c.city,
    COUNT(*)                                        AS total_orders,
    ROUND(SUM(f.otif)::NUMERIC /
          COUNT(*) * 100, 2)                        AS otif_pct,
    t.otif_target_pct                               AS otif_target,
    ROUND(SUM(f.otif)::NUMERIC /
          COUNT(*) * 100, 2) -
    t.otif_target_pct                               AS otif_gap,
    CASE
        WHEN ROUND(SUM(f.otif)::NUMERIC /
             COUNT(*) * 100, 2) < t.otif_target_pct
        THEN 'At Risk'
        ELSE 'On Track'
    END                                             AS risk_flag,
    CASE
        WHEN ROUND(SUM(f.otif)::NUMERIC /
             COUNT(*) * 100, 2) <
             t.otif_target_pct * 0.5
        THEN 'Critical'
        WHEN ROUND(SUM(f.otif)::NUMERIC /
             COUNT(*) * 100, 2) <
             t.otif_target_pct * 0.75
        THEN 'Severe'
        WHEN ROUND(SUM(f.otif)::NUMERIC /
             COUNT(*) * 100, 2) <
             t.otif_target_pct
        THEN 'Moderate'
        ELSE 'On Track'
    END                                             AS risk_severity
FROM fact_orders_agg f
JOIN dim_customers c      ON f.customer_id = c.customer_id
JOIN dim_targets_orders t ON f.customer_id = t.customer_id
GROUP BY
    c.customer_id, c.customer_name,
    c.city, t.otif_target_pct
ORDER BY otif_gap ASC;