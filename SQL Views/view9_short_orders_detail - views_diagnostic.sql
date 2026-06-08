-- Order line level detail for all short deliveries.
-- Shows which orders received less than ordered quantity,
-- the shortfall amount, and the shortfall percentage.
-- Operational diagnostic view for supply team.

CREATE VIEW v_short_orders_detail AS
SELECT
    f.order_id,
    f.order_placement_date,
    c.customer_name,
    c.city,
    p.product_name,
    p.category,
    f.order_qty,
    f.delivered_qty,
    f.shortfall_qty,
    f.shortfall_pct,
    f.in_full_line,
    f.on_time_line,
    f.otif_line
FROM fact_order_lines f
JOIN dim_customers c ON f.customer_id = c.customer_id
JOIN dim_products  p ON f.product_id  = p.product_id
WHERE f.shortfall_qty > 0
ORDER BY f.shortfall_pct DESC, f.order_placement_date;