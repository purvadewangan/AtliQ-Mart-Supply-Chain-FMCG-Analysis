-- Composite health score per customer combining OT gap,
-- IF gap, and OTIF gap into a single ranked score.
-- This is beyond the brief - a senior analyst deliverable
-- that gives account managers a single number to monitor
-- instead of three separate metrics.
-- Score of 100 = perfect performance at target.
-- Score below 50 = critical intervention needed.

CREATE VIEW v_customer_health_score AS
WITH customer_perf AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.city,
        COUNT(*)                                    AS total_orders,
        ROUND(SUM(f.on_time)::NUMERIC /
              COUNT(*) * 100, 2)                    AS ot_pct,
        ROUND(SUM(f.in_full)::NUMERIC /
              COUNT(*) * 100, 2)                    AS if_pct,
        ROUND(SUM(f.otif)::NUMERIC /
              COUNT(*) * 100, 2)                    AS otif_pct,
        t.ontime_target_pct                         AS ot_target,
        t.infull_target_pct                         AS if_target,
        t.otif_target_pct                           AS otif_target
    FROM fact_orders_agg f
    JOIN dim_customers c      ON f.customer_id = c.customer_id
    JOIN dim_targets_orders t ON f.customer_id = t.customer_id
    GROUP BY
        c.customer_id, c.customer_name, c.city,
        t.ontime_target_pct, t.infull_target_pct,
        t.otif_target_pct
)
SELECT
    customer_id,
    customer_name,
    city,
    total_orders,
    ot_pct,
    if_pct,
    otif_pct,
    ot_target,
    if_target,
    otif_target,
    ROUND(ot_pct   - ot_target,   2)               AS ot_gap,
    ROUND(if_pct   - if_target,   2)               AS if_gap,
    ROUND(otif_pct - otif_target, 2)               AS otif_gap,
    -- Health score: weighted average of performance
    -- vs target. OTIF weighted 50%, OT 25%, IF 25%
    -- because OTIF is the primary customer experience metric.
    ROUND(
        (LEAST(ot_pct / ot_target, 1.0) * 25) +
        (LEAST(if_pct / if_target, 1.0) * 25) +
        (LEAST(otif_pct / otif_target, 1.0) * 50)
    , 1)                                            AS health_score,
    CASE
        WHEN ROUND(
            (LEAST(ot_pct / ot_target, 1.0) * 25) +
            (LEAST(if_pct / if_target, 1.0) * 25) +
            (LEAST(otif_pct / otif_target, 1.0) * 50)
        , 1) >= 75 THEN 'Healthy'
        WHEN ROUND(
            (LEAST(ot_pct / ot_target, 1.0) * 25) +
            (LEAST(if_pct / if_target, 1.0) * 25) +
            (LEAST(otif_pct / otif_target, 1.0) * 50)
        , 1) >= 50 THEN 'At Risk'
        ELSE 'Critical'
    END                                             AS health_status
FROM customer_perf
ORDER BY health_score ASC;