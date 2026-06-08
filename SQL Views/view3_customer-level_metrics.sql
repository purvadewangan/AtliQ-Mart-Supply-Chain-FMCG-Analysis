-- View 3 - Customer level metrics
-- Customer level OT%, IF%, OTIF% measured against each
-- customer's individual contracted target, not the average.
-- Feeds the customer matrix visual on the dashboard.
-- Each customer is benchmarked against their own target
-- because targets are negotiated individually per contract.

CREATE VIEW v_otif_by_customer AS
SELECT
    c.customer_id,
    c.customer_name,
    c.city,
    COUNT(*)                                        AS total_orders,
    ROUND(SUM(f.on_time)::NUMERIC /
          COUNT(*) * 100, 2)                        AS ot_pct,
    ROUND(SUM(f.in_full)::NUMERIC /
          COUNT(*) * 100, 2)                        AS if_pct,
    ROUND(SUM(f.otif)::NUMERIC /
          COUNT(*) * 100, 2)                        AS otif_pct,
    t.ontime_target_pct                             AS ot_target,
    t.infull_target_pct                             AS if_target,
    t.otif_target_pct                               AS otif_target,
    ROUND(SUM(f.on_time)::NUMERIC /
          COUNT(*) * 100, 2) -
    t.ontime_target_pct                             AS ot_gap,
    ROUND(SUM(f.in_full)::NUMERIC /
          COUNT(*) * 100, 2) -
    t.infull_target_pct                             AS if_gap,
    ROUND(SUM(f.otif)::NUMERIC /
          COUNT(*) * 100, 2) -
    t.otif_target_pct                               AS otif_gap
FROM fact_orders_agg f
JOIN dim_customers c      ON f.customer_id = c.customer_id
JOIN dim_targets_orders t ON f.customer_id = t.customer_id
GROUP BY
    c.customer_id,
    c.customer_name,
    c.city,
    t.ontime_target_pct,
    t.infull_target_pct,
    t.otif_target_pct
ORDER BY otif_gap ASC;