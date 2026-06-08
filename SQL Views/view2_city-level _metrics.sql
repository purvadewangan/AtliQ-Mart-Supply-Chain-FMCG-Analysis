-- View 2 - City level metrics
-- City level OT%, IF%, OTIF% with gap to average target.
-- Feeds the city breakdown bar chart on the Executive dashboard.

CREATE VIEW v_otif_by_city AS
WITH city_orders AS (
    SELECT
        c.city,
        COUNT(*)                                    AS total_orders,
        ROUND(SUM(f.on_time)::NUMERIC /
              COUNT(*) * 100, 2)                    AS ot_pct,
        ROUND(SUM(f.in_full)::NUMERIC /
              COUNT(*) * 100, 2)                    AS if_pct,
        ROUND(SUM(f.otif)::NUMERIC /
              COUNT(*) * 100, 2)                    AS otif_pct
    FROM fact_orders_agg f
    JOIN dim_customers c ON f.customer_id = c.customer_id
    GROUP BY c.city
),
avg_targets AS (
    SELECT
        ROUND(AVG(ontime_target_pct), 2)            AS ot_target,
        ROUND(AVG(infull_target_pct), 2)            AS if_target,
        ROUND(AVG(otif_target_pct), 2)              AS otif_target
    FROM dim_targets_orders
)
SELECT
    o.city,
    o.total_orders,
    o.ot_pct,
    o.if_pct,
    o.otif_pct,
    t.ot_target,
    t.if_target,
    t.otif_target,
    ROUND(o.ot_pct   - t.ot_target,   2)            AS ot_gap,
    ROUND(o.if_pct   - t.if_target,   2)            AS if_gap,
    ROUND(o.otif_pct - t.otif_target, 2)            AS otif_gap
FROM city_orders o
CROSS JOIN avg_targets t
ORDER BY o.city;