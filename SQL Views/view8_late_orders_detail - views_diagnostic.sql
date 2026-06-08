-- Order line level detail for all late deliveries.
-- Shows exactly which orders were late, by how many days,
-- for which customer and product.
-- This is an operational view - not for the executive
-- dashboard but for the diagnostic page where managers
-- can drill into specific late orders.

CREATE VIEW v_late_orders_detail AS
SELECT
    f.order_id,
    f.order_placement_date,
    c.customer_name,
    c.city,
    p.product_name,
    p.category,
    f.agreed_delivery_date,
    f.actual_delivery_date,
    f.days_late,
    f.promise_window,
    f.order_qty,
    f.delivered_qty,
    f.shortfall_qty,
    f.shortfall_pct,
    f.on_time_line,
    f.in_full_line,
    f.otif_line
FROM fact_order_lines f
JOIN dim_customers c ON f.customer_id = c.customer_id
JOIN dim_products  p ON f.product_id  = p.product_id
WHERE f.days_late > 0
ORDER BY f.days_late DESC, f.order_placement_date;