<div align="center">

<img src="Atliq_logo_for_dashboard.png" alt="Logo" width="150">

# AtliQ Mart Supply Chain FMCG Analysis

### From Contract Loss to Operational Clarity
#### A Full-Stack Supply Chain Analytics Case Study

[![Python](https://img.shields.io/badge/Python-3.11-blue?logo=python)](https://python.org)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-17-blue?logo=postgresql)](https://postgresql.org)
[![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-yellow?logo=powerbi)](https://powerbi.microsoft.com)
[![Dataset Source](https://img.shields.io/badge/Dataset_Source-CodeBasics-brightgreen)]()
[![Domain](https://img.shields.io/badge/Domain-FMCG%20Supply%20Chain-orange)]()

</div>

---

## The Business Problem

AtliQ Mart is a growing FMCG manufacturer operating
across Surat, Ahmedabad, and Vadodara. They are
planning to expand to new cities. But key customers
are walking away without renewing annual contracts.

Management suspects delivery failures. The data
confirms something more serious: a systemic operational
breakdown that has normalized failure across the
entire supply chain.

This project was built to answer one question that
the original brief did not ask.

Not just what is failing. But why. And what to do
about it.

---

## Project at a Glance

| Dimension | Detail |
|---|---|
| Domain | FMCG Supply Chain Analytics |
| Data Window | March 2022 to August 2022 |
| Order Lines Analyzed | 57,096 |
| Total Orders | 31,729 |
| Customers | 35 across 3 cities |
| Products | 18 SKUs across 3 categories |
| Hypotheses Tested | 8 |
| Tools Used | Python, PostgreSQL, Power BI |
| Notebooks | 5 |
| SQL Views | 12 |
| Dashboard Pages | 5 |

---

## Headline Findings

| Metric | Actual | Target | Gap |
|---|---|---|---|
| OTIF % | 29.02% | 65.91% | -36.89 pts |
| On Time % | 59.03% | 86.09% | -27.06 pts |
| In Full % | 52.78% | 76.51% | -23.73 pts |
| Line Fill Rate | 65.96% | - | - |
| Volume Fill Rate | 96.59% | - | - |

7 in every 10 orders fail to meet the customer's
basic delivery promise. This has been consistent
across all 6 months with zero recovery trend.

---

## Dataset Summary

Six CSV files in a star schema architecture.

| Table | Rows | Description |
|---|---|---|
| fact_order_lines | 57,096 | Line level order detail |
| fact_orders_agg | 31,729 | Order level aggregates |
| dim_customers | 35 | Customer master with city |
| dim_products | 18 | Product master with category |
| dim_date | 183 | Calendar dimension |
| dim_targets_orders | 35 | Per-customer service targets |

Key schema insight: The same retail brand operating
in multiple cities has a separate customer ID and
separate contracted targets per city. This means
service level measurement is city-specific, not
brand-specific. The same retailer can show completely
different failure profiles across cities, which itself
became a major analytical finding.

---

## Analytical Approach

This project follows a strict tool split principle.
No analysis is duplicated across tools.
---

## Tool Stack

### Python

**Libraries used:**
pandas, numpy, matplotlib, seaborn, prophet,
statsmodels, scikit-learn

**What Python owns in this project:**

Data Quality and Profiling
- Null checks, duplicate detection, cardinality audit
- Foreign key validation across all dimension-fact joins
- Three date format standardization across source files
- Aggregate reconciliation: reconstructed fact_orders_agg
  from fact_order_lines using minimum flag logic and
  confirmed perfect match across all 31,729 orders
- OTIF target independence verification: confirmed
  otif_target = ontime_target x infull_target across
  all 35 customers, revealing AtliQ's embedded assumption
  that OT and IF failures are statistically independent

Feature Engineering
- promise_window: days between order placement and
  agreed delivery date
- days_late: actual delivery date minus agreed date
- shortfall_qty and shortfall_pct: volume gap analysis

Core Metric Computation
- LIFR, VOFR at line level from fact_order_lines
- OT%, IF%, OTIF% at order level from fact_orders_agg
- Gap to target at company, city, customer, product,
  and category level

Eight Hypothesis Tests
- H1: SKU-level IF concentration (forecast failure signal)
- H2: Simultaneous IF failures across customers (supplier signal)
- H3: Random background IF failures (warehouse error signal)
- H4: City-level OT concentration (transport signal)
- H5: Promise window vs OT failure (over-promising signal)
- H6: Customer date changes (untestable, data gap finding)
- H7: Festival demand spike clustering
- H8: Month-end capacity rush (day-of-month analysis)

Root Cause Analysis
- Customer clustering into four failure profiles based
  on OT gap and IF gap: Both Failing, Primarily Late,
  Primarily Short, Moderate Both
- Worst SKU x city combinations by IF failure rate
- Delay distribution analysis: decay curve fingerprinting

Predictive Layer
- Statsmodels seasonal decomposition: trend, seasonality,
  residual separation before Prophet modeling
- Prophet 90-day OTIF forecast with 95% confidence interval
- At-risk customer detection using 4-week rolling OTIF
  and trend direction per customer
- Logistic regression for order-level OTIF failure
  prediction (AUC 0.5077, finding not failure)

---

### PostgreSQL

**Version:** PostgreSQL 17

**What SQL owns in this project:**

Schema and Data Loading
- Full DDL with correct data types, primary keys,
  and foreign key constraints
- Cleaned CSVs loaded from Python output folder
- Row count verification after every table load

12 Production Views

Core Metric Views (03_views_core_metrics.sql)
- v_otif_summary: Company-level headline metrics
  with CTE pattern to prevent join-before-aggregate
  distortion on target averages
- v_otif_by_city: City-level breakdown with gap
  to company average target
- v_otif_by_customer: Customer-level metrics against
  individual contracted targets
- v_otif_by_month_week: Daily time series with month
  and week labels for Power BI drill-down
- v_lifr_vofr_by_product: Product-level fill metrics
  with IF failure rate ranking

Diagnostic Views (04_views_diagnostic.sql)
- v_customer_health_score: Composite weighted score
  per customer (OTIF 50%, OT 25%, IF 25%) with
  Critical, At Risk, Healthy classification
- v_at_risk_customers: Risk flag and severity level
  per customer based on performance vs target
- v_late_orders_detail: Full line-level detail for
  all 16,491 late order lines
- v_short_orders_detail: Full line-level detail for
  all 19,435 short order lines

Advanced Views (05_views_advanced.sql)
- v_customer_monthly_trend: Month-on-month OTIF change
  per customer using LAG window function
- v_customer_city_rank: Customer ranking within city
  using RANK window function partitioned by city
- v_consecutive_underperformers: Customers below target
  for 3 or more consecutive months using running SUM
  window function

Notable SQL engineering decisions:
- CTE pattern used throughout to prevent join-before-
  aggregate errors that distorted target averages by
  up to 0.85 percentage points
- CROSS JOIN pattern to attach scalar aggregates to
  multi-row result sets without row multiplication
- NUMERIC casting on all integer divisions to prevent
  PostgreSQL integer truncation in percentage calculations
- Window functions (LAG, RANK, SUM OVER) for trend
  detection and ranking that GROUP BY cannot produce

---

### Power BI

**What Power BI owns in this project:**

Connection: Live connection to PostgreSQL views only.
No raw tables loaded. No transformations in Power Query.
All data preparation lives in SQL.

Five Pages:
- Home: Navigation hub with project context and links
- Executive Summary: Company KPIs, trend, city split
- Operational Diagnostic: Customer matrix, late and
  short order detail tables
- Customer Intelligence: Single-customer drilldown
  with risk flags and trend analysis
- Product and Supply: Product fill rate table, LIFR
  vs VOFR scatter, shortfall distribution

Key Power BI features implemented:
- Switchable metric trend chart using disconnected
  MetricSelector table and DAX SWITCH measure
- Conditional formatting on matrix: red, amber, green
  based on gap thresholds
- Custom tooltip pages on KPI cards for hover detail
- Page overview panels triggered by button navigation
- Applied filters display using dynamic DAX text measure
- Slicer sync across all pages for persistent filtering
- Benchmark toggle: Vs Target and Vs Last Month
- Help layer overlay with dashboard usage guide
- Mobile layout for Executive Summary page

DAX measures created:
- Selected Metric Value: drives the switchable chart
- Applied Filters display: dynamic text for sidebar
- Health Color: conditional formatting color logic
- Gap Color: matrix cell background color logic

---

## Key Business Insights

### Insight 1: Two Problems Wearing One Mask

OTIF at 29.02 percent is a single number hiding two
completely different operational failures.

Primarily Short customers (13 of 35) show on-time
performance around 70 to 75 percent but in-full
delivery collapsing to 16 to 19 percent. This is
a supply availability and warehouse execution problem.

Primarily Late customers (7 of 35) show in-full
delivery around 66 to 68 percent but on-time delivery
collapsing to 27 to 29 percent. This is a dispatch
scheduling and capacity problem.

These two profiles require entirely different
interventions. A single company-wide fix addresses
neither correctly.

### Insight 2: The LIFR-VOFR Gap Reveals Hidden Damage

Line Fill Rate: 65.96 percent
Volume Fill Rate: 96.59 percent
Gap: 30 percentage points

AtliQ delivers 96.59 percent of ordered volume. But
65.96 percent of order lines fail the binary in-full
test. A customer ordering 100 units and receiving 97
units contributes a failed line to LIFR while barely
moving VOFR.

The strict binary OTIF criterion amplifies small
warehouse execution errors into large metric failures.
Customer experience deteriorates faster than volume
data suggests.

### Insight 3: The Vadodara Supply Signal

13 of 15 worst product-city combinations by IF failure
rate are in Vadodara. City-level OTIF analysis masked
this because OT gaps are geographically uniform. Only
SKU-city intersection analysis surfaces the concentration.

Vadodara has a specific supply availability problem
that Surat and Ahmedabad do not share at the same
severity. This requires city-specific investigation,
not a company-wide policy response.

### Insight 4: The Target Independence Assumption

Mathematical verification confirmed that every one
of AtliQ's 35 customer OTIF targets equals the OT
target multiplied by the IF target.

This means AtliQ assumes OT and IF failures are
statistically independent events. In practice they
are not. A supply disruption that causes a short
delivery often also causes a late delivery. When
both fail together the joint failure rate is higher
than the product of the individual rates.

AtliQ's targets systematically underestimate the
true joint failure risk.

### Insight 5: Delay Profile Points to Capacity Constraint

Delay distribution follows a clean decay curve:
50 percent of late lines are 1 day late,
31 percent are 2 days late,
18 percent are 3 days late.

This pattern is characteristic of operational capacity
constraint, not logistics breakdown. When capacity is
tight, most orders slip by one day. A logistics failure
produces a flat distribution across delay magnitudes.

The failure cannot be fixed by adjusting delivery
promises. It requires capacity resolution upstream.

### Insight 6: Warehouse Execution as Primary IF Driver

Zero order lines in the dataset have a shortfall
exceeding 30 percent of ordered quantity. Every IF
failure is a small to moderate shortfall in the
5 to 20 percent range.

AtliQ does not have a stockout problem. It has a
warehouse precision problem. Miscounts and mispicks
accumulate across thousands of lines without any
single catastrophic event. The fix is operational
precision, not supply chain restructuring.

### Insight 7: Prophet Says Nothing Improves Alone

90-day Prophet forecast: 29.56 percent OTIF.
Current baseline: 29.02 percent.
Change: negligible.

Without deliberate operational intervention the system
will not self-correct. OTIF has been flat for 6 months
and will remain flat for the next 3. Management must
act. The forecast quantifies the cost of inaction.

### Insight 8: Logistic Regression Redirects Investment

Order failure prediction model AUC: 0.5077.
Essentially random guessing.

This is not a model failure. It is a finding. OTIF
failure at individual order level cannot be predicted
from information available at order placement time.
The failure is happening inside operations, in real
time, not in the planning system.

To build a genuine predictive intervention system
AtliQ needs to capture real-time operational signals:
warehouse inventory levels, dispatch queue depth,
and staffing data at order time. This finding
redirects the company's analytics investment toward
the right data capture priorities.

---

## Business Recommendations

### Recommendation 1: Fix Warehouse Execution Precision
Proven by: H3 hypothesis confirmation, shortfall distribution analysis showing zero failures above 30% Implement quantity verification at the picking stage. Introduce barcode scanning for high-volume Dairy SKUs. Target: reduce IF failure rate from 34% toward 15%.

### Recommendation 2: Investigate Vadodara Supply Chain
Proven by: SKU-city intersection analysis, 13 of 15 worst combinations concentrated in Vadodara Audit Vadodara warehouse allocation, inventory planning, and local supplier delivery schedules independently from the other two city operations.

### Recommendation 3: Separate Intervention by Failure Profile
Proven by: Customer clustering analysis, four distinct failure profiles with different OT and IF gap signatures Primarily Late customers need dispatch scheduling review. Primarily Short customers need warehouse allocation review. Do not apply a single fix to both profiles.

### Recommendation 4: Deploy At-Risk Customer Early Warning
Proven by: Rolling 4-week OTIF detection, 18 of 35 customers flagged with declining trend in final weeks Build a weekly account manager alert based on rolling OTIF and trend direction. Intervene before the customer decides not to renew, not after.

### Recommendation 5: Capture Real-Time Operational Data
Proven by: Logistic regression AUC 0.5077, order failure unpredictable from placement-time information Start capturing warehouse inventory levels, dispatch queue depth, and real-time staffing data. This enables genuine predictive intervention in a future iteration.

### Recommendation 6: Capture Order Change History
Proven by: H6 untestable due to missing change log Record order date change events with timestamp and reason. This makes H6 testable and enables future diagnosis of customer-side contribution to OT failures.

### Recommendation 7: Revise Target-Setting Methodology
Proven by: OTIF independence assumption verification across all 35 customers Recalibrate OTIF targets using observed joint failure correlation rather than the product of independent probabilities. Current targets underestimate true joint failure risk.

### Recommendation 8: Benchmark Against World-Class Standards
Proven by: Target range analysis, OTIF targets 49-75% versus world-class 95% plus Establish a multi-year improvement roadmap with intermediate milestones toward 95% OTIF before expanding to new cities. Measuring against historical underperformance is not a growth strategy.

---

## From Reporting to Decision Intelligence

Most supply chain analytics projects compute OTIF and display it.

This project computed OTIF, decomposed it, clustered it, forecasted it, tested eight hypotheses against it, identified the specific failure modes hiding inside it,
segmented customers by those failure modes, detected which customers are actively deteriorating in real time, built a predictive model that produced a finding by
failing, and translated every analytical output into a specific operational recommendation with the evidence that proves it.

The addition of a full predictive layer using Prophet for time series forecasting and scikit-learn for failure prediction, neither of which was requested
by the project brief, transformed this from a reporting exercise into a forward-looking analytical system that gives management both the diagnosis and
the trajectory.

That is the difference between analysis that describes the past and analysis that shapes decisions about the future. And that is what makes this project an outstanding one.

---

## What I Gained With This Project

I came into this project with almost no exposure to FMCG supply chain operations.

I left it understanding how demand forecasting errors propagate into warehouse stockouts, how warehouse execution gaps surface in customer fill rates, how transportation delays compound planning failures into OTIF breakdowns, how customer service level agreements are structured and what sustained underperformance costs in customer trust and contract renewals, and how the tension between operational capacity and sales targets creates the rhythmic performance patterns that analytics can detect and predict.

That domain knowledge is not in the dataset. It comes from treating the analysis as a business question rather than a data exercise.

Beyond domain knowledge I gained structured discipline across three tools, the ability to design an analytical system where Python, SQL, and Power BI each own a distinct layer with no duplication, the practice of turning every hypothesis into a testable proposition with a magnitude threshold and a clear verdict, and
the habit of being honest about what the data cannot tell me and turning that honesty into a recommendation.

Most importantly I gained confirmation of something I believe about this work.

The metric is not the answer. The question behind the metric is the answer. And knowing which question to ask before you open a single tool is the most underrated skill in data analytics.

---

## Connect

**Purva Dewangan**
Data Analyst | MBA in Data Science and Business Analytics

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?logo=linkedin)](https://linkedin.com/in/yourprofile)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-black?logo=github)](https://github.com/yourusername)

Open to full-time opportunities in data analytics
at global organizations.

---

*Project source: CodeBasics Supply Chain FMCG practice
dataset. Analysis, hypotheses, predictive layer, SQL
architecture, and dashboard design are original work.*
