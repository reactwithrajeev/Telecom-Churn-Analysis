# 📡 ConnectMax Telecom — Customer Churn & Usage Analysis

> **End-to-end Data Analytics Project | Telecom Domain**
>
> Analyst: **Rajeev** | Tools: Python · SQL · Power BI

![Python](https://img.shields.io/badge/Python-3.x-blue?logo=python)
![MySQL](https://img.shields.io/badge/MySQL-Advanced-orange?logo=mysql)
![PowerBI](https://img.shields.io/badge/PowerBI-Dashboard-yellow?logo=powerbi)
![Domain](https://img.shields.io/badge/Domain-Telecom-green)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)

---

## 📌 Project Overview

This project is a complete end-to-end **Customer Churn & Usage Analysis** for a fictional telecom operator, **ConnectMax Telecom**, built on a synthetically generated but realistic dataset. The goal was to analyze **50,000 customers** across 4 linked tables, identify which customer segments are most likely to churn, quantify the revenue impact, and give actionable business recommendations to reduce churn.

| Detail | Information |
|--------|-------------|
| **Domain** | Telecom — Customer Churn & Revenue Risk |
| **Dataset** | 4,71,584 records across 4 linked tables |
| **Tables** | 4 tables — Customers · Churn Status · Usage Data · Complaints |
| **Cities** | Delhi · Gurgaon · Mumbai · Bangalore · Noida · Pune |
| **Plan Types** | Prepaid · Postpaid · Broadband |
| **Overall Churn Rate** | **21.85%** — in line with telecom industry benchmarks (15–25%) ⚠️ |

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|------|---------|
| **Python** (Pandas, NumPy, Matplotlib, Seaborn) | Synthetic data generation, cleaning, feature engineering, EDA |
| **MySQL** (via SQLAlchemy + PyMySQL) | Automated data pipeline, advanced SQL analysis |
| **Power BI** | Interactive 6-page dashboard with advanced DAX |

---

## 📁 Project Structure

```
Telecom-Churn-Analysis/
│
├── 📂 data/
│   ├── raw/
│   │   ├── customers.csv                # 50,000 rows — demographics, plan, contract
│   │   ├── churn_status.csv             # 50,000 rows — churn flag, date, reason
│   │   ├── usage_data.csv               # 3,00,000 rows — monthly usage & recharge
│   │   └── complaints.csv               # 71,584 rows — complaint type & resolution
│   └── processed/
│       └── *_clean.csv                  # Cleaned, analysis-ready versions of all 4 tables
│
├── 📂 notebooks/
│   ├── 01_Data_Generation.ipynb         # Synthetic data generation with business logic
│   ├── 02_Data_Cleaning.ipynb           # Null/duplicate checks, dtype fixes, referential integrity
│   └── 03_EDA.ipynb                     # Feature engineering + 10 charts
│
├── 📂 charts/
│   ├── chart1_churn_by_contract.png
│   ├── chart2_churn_by_tenure.png
│   ├── chart3_churn_by_city.png
│   ├── chart4_usage_decline_boxplot.png
│   ├── chart5_churn_by_complaints.png
│   ├── chart6_monthly_usage_trend.png
│   ├── chart7_data_vs_calls_twinx.png
│   ├── chart8_correlation_heatmap.png
│   ├── chart9_plan_by_city.png
│   └── chart10_revenue_at_risk.png
│
├── 📂 sql/
│   └── queries.sql                      # 10 queries + 1 view + 2 stored procedures
│
├── 📂 powerbi/
│   └── ConnectMax_Churn_Dashboard.pbix  # 6-page interactive dashboard
│
└── README.md
```

---

## 🔍 Phase 1 — Data Generation & Cleaning (Python)

### 4 Tables — Synthetically Generated with Real Business Logic

| Table | Rows | Columns | Key Columns |
|-------|------|---------|-------------|
| customers | 50,000 | 8 (+4 engineered) | city, plan_type, contract_type, tenure_months, monthly_charges |
| churn_status | 50,000 | 4 | is_churned, churn_date, churn_reason |
| usage_data | 3,00,000 | 6 | month, data_used_gb, calls_minutes, recharge_amount |
| complaints | 71,584 | 6 | complaint_type, resolution_status, resolution_days |

Unlike a real-world messy dataset, this data was **synthetically generated with deliberate, interlinked business logic**, so the resulting patterns are genuine rather than random noise:

| # | Business Logic Applied | Implementation |
|---|------------------------|-----------------|
| 1 | Younger customers skew Prepaid, older customers skew Postpaid/Broadband | Age-conditional `np.random.choice()` probability weights |
| 2 | Prepaid customers always have "No Contract" | Contract type derived from plan type |
| 3 | Month-to-Month customers have shorter tenure than 2-Year customers | Tenure range conditioned on contract type |
| 4 | Churn probability driven by contract type + low tenure | Custom `churn_probability()` function → `np.random.binomial()` |
| 5 | Churned customers' usage declines ~2–3 months before their churn date | Month-indexed decline factor applied to usage generation |
| 6 | Churned customers file more complaints, with slower resolution | Complaint count & resolution days conditioned on churn status |

### Cleaning Steps Applied

| # | Check | Result |
|---|-------|--------|
| 1 | Null values | 0 unexpected nulls (only intentional blanks for non-churned customers' churn_date/reason) |
| 2 | Duplicate rows | 0 duplicates across all 4 tables |
| 3 | Data types | All date columns converted to `datetime64` via `pd.to_datetime()` |
| 4 | Referential integrity | 0 orphan `customer_id` records across usage_data, complaints, and churn_status |

**Result after cleaning:** 4,71,584 records across 4 tables · fully analysis-ready ✅

---

## 📊 Phase 2 — EDA (Python)

### 10 Business Questions Answered

| # | Chart | Business Question | Key Finding |
|---|-------|--------------------|-------------|
| 1 | Churn by Contract Type | Which contract type churns most? | Month-to-Month: **31.1%** vs 2-Year: **4.8%** — 6.5x gap |
| 2 | Churn by Tenure Bucket | Are new customers riskier? | New (0–6m): **33.5%** vs Loyal (48m+): **5.1%** |
| 3 | Churn by City | Does geography drive churn? | 21.0%–22.4% across cities — no significant difference |
| 4 | Usage Decline % (Boxplot) | Does usage predict churn? | Churned: 57–63% decline vs Non-churned: -8% to +8% — zero overlap |
| 5 | Churn by Complaint Count | Do complaints predict churn? | 0 complaints: **6.5%** vs 5 complaints: **73.9%** — 11x gap |
| 6 | Monthly Usage Trend | When does decline start? | Usage drops sharply ~2–3 months before churn |
| 7 | Data Usage vs Call Minutes (twinx) | Do both metrics decline together? | Both drop ~60% in sync for churned customers |
| 8 | Correlation Heatmap | Which factor matters most? | Usage decline: **0.91** correlation — strongest predictor |
| 9 | Plan Type by City | Does plan preference vary by city? | Consistent order everywhere: Prepaid > Postpaid > Broadband |
| 10 | Revenue at Risk by Plan | Which plan costs the most in lost revenue? | Broadband: **₹43.7L/month** despite fewest churned customers |

### EDA Charts Preview

| Chart 1 — Churn by Contract Type | Chart 8 — Correlation Heatmap |
|---|---|
| ![Chart1](charts/chart1_churn_by_contract.png) | ![Chart8](charts/chart8_correlation_heatmap.png) |

| Chart 4 — Usage Decline Boxplot | Chart 10 — Revenue at Risk |
|---|---|
| ![Chart4](charts/chart4_usage_decline_boxplot.png) | ![Chart10](charts/chart10_revenue_at_risk.png) |

---

## 💾 Phase 3 — SQL Analysis (MySQL)

Database built via an **automated Python → MySQL pipeline** (SQLAlchemy + `pandas.to_sql()`), with row counts verified to match exactly across all 4 tables (zero data loss).

### 10 Queries — Basic to Advanced

| # | Query | SQL Concept | Key Finding |
|---|-------|-------------|-------------|
| 1 | Top 10 Highest-Revenue Customers | `GROUP BY` + `SUM` | Top customer generated **₹15,829** over 6 months |
| 2 | Complaint Resolution Time by Type | `JOIN` + `AVG` | All 5 complaint types resolve in a tight 5.44–5.51 day range |
| 3 | Month-over-Month Usage Change | **`LAG()` window function** | Churned customers show consecutive declining months, not random dips |
| 4 | Top 3 Revenue Customers Per City | **`RANK()` + `PARTITION BY`** | City-wise VIP list, independent of company-wide ranking |
| 5 | Customer Value Segmentation | **`NTILE(4)` + `CASE WHEN`** | Platinum tier earns **6x** more than Bronze tier |
| 6 | Complaints by Month (Seasonality) | `MONTHNAME()` + `GROUP BY` | Complaints fairly flat year-round — no major seasonal spike |
| 7 | Complaints in 60 Days Before Churn | **Correlated Subquery → optimized to `LEFT JOIN`** | Only 50.17% of churners complained in their final 60 days |
| 8 | City + Plan Revenue Summary | **`ROLLUP`** + `COALESCE` | Broadband drives the most revenue in every city |
| 9 | Customers Below City Average Revenue | **Correlated Subquery → optimized to `AVG() OVER (PARTITION BY)`** | 10 customers earning ~25% of their city's average — upsell targets |
| 10 | Slowest 5% of Complaint Resolutions | **`PERCENT_RANK()`** | Worst delays spread evenly across complaint types — a process issue, not a category issue |

### View & Stored Procedures

```sql
-- Reusable consolidated risk view
CREATE VIEW vw_customer_risk_summary AS
SELECT c.customer_id, c.city, c.plan_type, c.contract_type,
       c.tenure_months, c.usage_decline_pct, ch.is_churned,
       COUNT(co.complaint_id) AS total_complaints
FROM customers c
JOIN churn_status ch ON c.customer_id = ch.customer_id
LEFT JOIN complaints co ON c.customer_id = co.customer_id
GROUP BY c.customer_id, c.city, c.plan_type, c.contract_type,
         c.tenure_months, c.usage_decline_pct, ch.is_churned;
```

| Stored Procedure | Parameters | Purpose |
|-------------------|-----------|---------|
| `sp_Churn_Report` | `p_city`, `p_plan_type` (or `'ALL'`) | On-demand churn statistics by city/plan for regional managers |
| `sp_Complaint_Analysis` | `p_start_date`, `p_end_date` | Complaint trend analysis for any custom date range |

---

## 🖥️ Phase 4 — Power BI Dashboard

Built following a formal **BRD → FRD → Traceability Matrix** workflow — every page maps back to a documented business requirement.

### 6-Page Interactive Report

**Home** — Branded landing page with project summary and navigation to all 5 content pages

**Page 1 — Churn Overview Dashboard**
- 4 KPI Cards: Total Customers · Churn Rate % · Monthly Revenue at Risk · Avg Tenure
- Churn Rate % by Contract Type · New Churns by Month · Plan & City distribution

**Page 2 — Churn Drivers & Risk Segmentation**
- Top 5 Highest-Churn City/Plan Combinations (`RANKX`)
- Churn by Tenure Bucket · Risk Category Distribution (`SWITCH(TRUE())`) · Churn by Complaint Count

**Page 3 — Revenue Impact Analysis**
- Interactive Decomposition Tree (city → plan → contract type)
- Revenue at Risk by Plan · Top 10 Highest-Value At-Risk Customers

**Page 4 — Complaint Trends & Resolution Performance**
- Rolling 3-Month Complaint Trend (`DATESINPERIOD`)
- Month-over-Month Resolution Time (`DATEADD`) · Complaint Type Breakdown

**Page 5 — Customer Deep-Dive & AI Insights**
- **Key Influencers AI visual** — independently validated the same top churn drivers found in Python
- **Field Parameter** metric switcher (Churn Rate % / Revenue at Risk / Complaints) in a single dynamic chart

### DAX Measures Used

```dax
Total Customers          = COUNTROWS(customers_clean)
Churn Rate %              = AVERAGE(churn_status_clean[is_churned]) * 100
Monthly Revenue at Risk   = DIVIDE(CALCULATE(SUM(usage_data_clean[recharge_amount]), churn_status_clean[is_churned]=1), DISTINCTCOUNT(usage_data_clean[month]))
Total Monthly Revenue     = DIVIDE(SUM(usage_data_clean[recharge_amount]), DISTINCTCOUNT(usage_data_clean[month]))
New Churns                = CALCULATE(SUM(churn_status_clean[is_churned]), USERELATIONSHIP(DateTable[Date], churn_status_clean[churn_date]))
Churn Rank                = RANKX(ALL(CityPlanSummary), CALCULATE(MAX(CityPlanSummary[ChurnRate])), , DESC)
Risk Category              = SWITCH(TRUE(), [Usage Decline Pct] >= 40, "High Risk", [Usage Decline Pct] >= 15, "Medium Risk", "Low Risk")
Rolling Complaints         = CALCULATE(COUNTROWS(complaints_clean), USERELATIONSHIP(DateTable[Date], complaints_clean[complaint_date]), DATESINPERIOD(DateTable[Date], MAX(DateTable[Date]), -3, MONTH))
```

### Advanced Power BI Features Used
- ✅ **Star-schema data model** with a dedicated `DateTable` for time intelligence
- ✅ **Inactive relationships + `USERELATIONSHIP()`** to connect one DateTable to three different date columns
- ✅ **Decomposition Tree** for interactive revenue drill-down
- ✅ **Key Influencers AI visual** — cross-validated against manual Python correlation analysis
- ✅ **Field Parameters** for dynamic, single-chart metric switching
- ✅ **Calculated columns rebuilt in DAX** (Tenure Bucket, Usage Decline %, Risk Category) using `SWITCH(TRUE())` and cross-table `CALCULATE`

---

## 🔑 Top Key Findings

| # | Finding | Business Impact |
|---|---------|------------------|
| 1 | Usage decline % has a **0.91 correlation** with churn — the strongest predictor by far | An automated alert for usage drops >30–40% would catch most at-risk customers early |
| 2 | Month-to-Month contract churn (**31.1%**) is **6.5x** higher than 2-Year contract churn (**4.8%**) | Incentivize customers to move to longer-term contracts |
| 3 | New customers (0–6 months tenure) churn at **33.5%** | Focus onboarding support in the first 6 months of the customer lifecycle |
| 4 | Customers with 5 complaints churn at **73.9%** vs 6.5% with none — an **11x** gap | Flag customers with 3+ complaints for priority retention outreach |
| 5 | Only **50.17%** of churned customers complained in their final 60 days | A "last 60 days" alert alone misses half of at-risk customers — a longer observation window is needed |
| 6 | **Broadband** drives the most revenue in every city despite having the fewest customers | Prioritize retention spend on high-value Broadband customers |
| 7 | Total monthly revenue at risk from churn: **~₹94.65 lakh** | Clear, quantified case for investing in a retention program |

---

## 🎯 Business Recommendations

| # | Recommendation | Expected Impact |
|---|------------------|-------------------|
| 1 | Build an automated usage-decline alert (>30–40% drop) | Catches most at-risk customers 2–3 months before they churn |
| 2 | Push Month-to-Month customers toward 1-Year/2-Year contracts via discounts | Directly targets the single largest churn driver |
| 3 | Prioritize onboarding and proactive engagement for customers in their first 6 months | Addresses the highest-risk tenure segment |
| 4 | Flag any customer with 3+ complaints for priority retention outreach | Captures the strongest behavioral churn signal |
| 5 | Extend complaint-based risk monitoring beyond a 60-day window | Prevents missing the ~50% of churners who don't complain right before leaving |
| 6 | Protect high-value Broadband and Postpaid customers first when resources are limited | Maximizes revenue protected per retention dollar spent |

---

## 👤 Author

**Rajeev**
- 🎥 YouTube: [Tuning Data](https://youtube.com/@tuningdata) — Hinglish data analytics tutorials
- 🐙 GitHub: [github.com/reactwithrajeev](https://github.com/reactwithrajeev)

---

> ⭐ If you found this project helpful, please give it a star!

*This project is part of a complete Data Analytics portfolio covering Python, SQL, and Power BI.*
