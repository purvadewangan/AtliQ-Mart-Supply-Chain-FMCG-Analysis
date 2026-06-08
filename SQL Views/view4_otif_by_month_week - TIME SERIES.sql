-- Monthly and weekly OTIF trend for the drillable time
-- series chart on the Executive dashboard. Power BI will
-- use the month_year and week_no columns to enable
-- drill-down from month to week level.
-- This view does not repeat Python's decomposition or
-- Prophet work. It simply structures the raw time series
-- for dashboard consumption.

CREATE VIEW v_otif_by_month_week AS
SELECT
    TO_CHAR(f.order_placement_date, 'YYYY-MM')  AS month_year,
    TO_CHAR(f.order_placement_date, 'YYYY')
        || '-W'
        || TO_CHAR(f.order_placement_date, 'IW') AS week_no,
    f.order_placement_date,
    COUNT(*)                                     AS total_orders,
    ROUND(SUM(f.on_time)::NUMERIC /
          COUNT(*) * 100, 2)                     AS ot_pct,
    ROUND(SUM(f.in_full)::NUMERIC /
          COUNT(*) * 100, 2)                     AS if_pct,
    ROUND(SUM(f.otif)::NUMERIC /
          COUNT(*) * 100, 2)                     AS otif_pct
FROM fact_orders_agg f
GROUP BY
    TO_CHAR(f.order_placement_date, 'YYYY-MM'),
    TO_CHAR(f.order_placement_date, 'YYYY')
        || '-W'
        || TO_CHAR(f.order_placement_date, 'IW'),
    f.order_placement_date
ORDER BY f.order_placement_date;