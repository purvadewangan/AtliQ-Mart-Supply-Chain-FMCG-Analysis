-- LIFR and VOFR at product and category level.
-- Per stakeholder brief, only fill metrics are shown at
-- product level. OT is not measurable at product level
-- because on-time is an order-level concept - a product
-- cannot be late independently of its order.
-- Feeds the product table with sparklines on Page 2.

CREATE VIEW v_lifr_vofr_by_product AS
SELECT
    p.product_id,
    p.product_name,
    p.category,
    COUNT(*)                                        AS total_lines,
    SUM(f.in_full_line)                             AS lines_in_full,
    ROUND(SUM(f.in_full_line)::NUMERIC /
          COUNT(*) * 100, 2)                        AS lifr_pct,
    ROUND((100 - SUM(f.in_full_line)::NUMERIC /
          COUNT(*) * 100), 2)                       AS if_failure_rate,
    SUM(f.order_qty)                                AS total_ordered,
    SUM(f.delivered_qty)                            AS total_delivered,
    ROUND(SUM(f.delivered_qty)::NUMERIC /
          SUM(f.order_qty) * 100, 2)                AS vofr_pct,
    ROUND(AVG(f.shortfall_pct), 2)                  AS avg_shortfall_pct
FROM fact_order_lines f
JOIN dim_products p ON f.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.category
ORDER BY if_failure_rate DESC;