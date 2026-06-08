# AtliQ-Mart-Supply-Chain-FMCG-Analysis
In the fast-paced FMCG industry, supply chain reliability is everything. This project analyzes AtliQ Mart's delivery performance, focusing on key operational metrics like On-Time (OT)%, In-Full (IF)%, OTIF, LIFR, and VOFR to identify delivery gaps before they impact retail customer relationships.

<div align="center">

<img src="outputs/dashboard_screenshots/atliq_logo.png" 
     alt="AtliQ Mart Logo" width="180"/>

# AtliQ Mart Supply Chain OTIF Analytics

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
