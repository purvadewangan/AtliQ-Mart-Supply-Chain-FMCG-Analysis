-- Fixing join-before-aggregate distortion.
-- Targets are averaged across 35 customers first in a subquery,
-- then joined to order metrics. This ensures each customer
-- contributes equally to the target average regardless of
-- how many orders they placed.

DROP VIEW IF EXISTS v_otif_summary;

CREATE VIEW v_otif_summary AS
WITH order_metrics AS (
    SELECT
        COUNT(*)                                AS total_orders,
        ROUND(SUM(on_time)::NUMERIC /
              COUNT(*) * 100, 2)               AS ot_pct,
        ROUND(SUM(in_full)::NUMERIC /
              COUNT(*) * 100, 2)               AS if_pct,
        ROUND(SUM(otif)::NUMERIC /
              COUNT(*) * 100, 2)               AS otif_pct
    FROM fact_orders_agg
),
target_metrics AS (
    SELECT
        ROUND(AVG(ontime_target_pct), 2)       AS ot_target,
        ROUND(AVG(infull_target_pct), 2)       AS if_target,
        ROUND(AVG(otif_target_pct), 2)         AS otif_target
    FROM dim_targets_orders
)
SELECT
    o.total_orders,
    o.ot_pct,
    o.if_pct,
    o.otif_pct,
    t.ot_target,
    t.if_target,
    t.otif_target,
    ROUND(o.ot_pct   - t.ot_target,   2)      AS ot_gap,
    ROUND(o.if_pct   - t.if_target,   2)      AS if_gap,
    ROUND(o.otif_pct - t.otif_target, 2)      AS otif_gap
FROM order_metrics o
CROSS JOIN target_metrics t;