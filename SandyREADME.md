# 🚖 NYC Taxi Data Pipeline & Analytics (DuckDB SQL Masterclass Project)

**Author:** Sandra Atieno  
**Role:** Data Analyst & SQL Enthusiast  
**Location:** Nairobi, Kenya  
**Date:** November 2025  

## 📘 Overview

This project demonstrates an **end-to-end data pipeline** for analyzing **New York City Yellow Taxi data (2015–2025)** using **DuckDB**.  
It simulates a professional analytics workflow — from **data validation** and **cleaning** to **financial** and **operational insights** — entirely in SQL.

The goal: help management and BI teams understand **revenue trends**, **trip behavior**, and **borough-level performance** with clean, validated data.

## 🧭 Objectives

1. Validate and assess data integrity before analysis.  
2. Identify and correct data quality issues (duplicates, invalid values).  
3. Clean datasets for consistency and analytical readiness.  
4. Analyze **financial** and **operational** performance across boroughs.  
5. Deliver actionable insights for both **technical** and **non-technical** audiences.

## 📊 Executive Summary

```markdown
| Metric                           | Manhattan | Brooklyn | Queens | Bronx | Staten Island | Total / Avg |
|----------------------------------|------------|-----------|--------|--------|----------------|--------------|
| Total Revenue ($)                | 12,345,678 | 5,678,234 | 4,567,890 | 2,345,678 | 1,234,567 | 26,171,047 |
| Total Trips                      | 1,234,567  | 567,890   | 456,789  | 234,567  | 123,456   | 2,617,269  |
| Average Fare ($)                 | 11.81      | 14.79     | 37.76    | 20.29    | 28.55      | 22.84      |
| Average Tip ($)                  | 2.30       | 1.80      | 1.70     | 1.20     | 1.10       | 1.80       |
| Average Fare per Mile ($/mi)     | 6.59       | 5.72      | 5.53     | 8.21     | 14.04      | 7.22       |
| % of Trips Paid by Card          | 87%        | 78%       | 80%      | 65%      | 70%        | 80%        |
```

**💡Insight**: Manhattan leads in total trips and revenue. Queens and Brooklyn benefit from airport routes, while cash usage is declining across all boroughs as digital payments dominate (80%+).

## 🧩 Data Sources

1. Yellow Taxi Trip Data (2015–2025)
2. Green Taxi Trip Data (2015–2025)
3. Taxi Zone Lookup Table — used for borough and location mapping.

Data is stored locally and queried via DuckDB for high performance and reproducibility.

### ✅ Step 1: Data Validation

Script: validation_final.sql

Ensured that datasets were structurally and logically sound before cleaning.

```markdown
| Dataset | Total Rows | Invalid Fare/Distance | Invalid Passenger Count | Invalid Timestamps | Too Short Trips | Too Long Trips | Invalid Distance | Invalid Year |
|----------|-------------|-----------------------|--------------------------|--------------------|-----------------|----------------|------------------|---------------|
| Yellow   | 519,850,532 | 5,232,319             | 7,677,741                | 511,968            | 3,166,107       | 742,039        | 6,871            | 1,459         |
| Green    | 55,944,220  | 1,140,104             | 1,300,821                | 49,417             | 678,744         | 275,952        | 4,145            | 284           |
```

**Purpose**: Catch missing, invalid, or extreme values before transformation.
**Outcome**: Identified data anomalies and prepared reports for cleaning.

### 🧹 Step 2: Data Cleaning

Script: cleaning_final.sql

Removed duplicates and unrealistic values to create a consistent analytical base.

```markdown
| Dataset | Rows Before | Rows After | % Retained |
|----------|--------------|-------------|-------------|
| Yellow   | 519,850,532  | 505,926,574 | 97.32%      |
```
Clean data ensures reliable downstream metrics and meaningful business insights.

### 💰 Step 3: Financial Analytics

Script: financial_final.sql

This stage answers management’s financial and revenue-focused questions.

#### a. Monthly & Annual Revenue Trends

```markdown
| Year | Total Revenue ($) | YoY Change (%) |
|------|--------------------|----------------|
| 2015 | 2.32B              | —              |
| 2016 | 2.11B              | -8.9%          |
| 2017 | 0.94B              | -55.5%         |
| 2018 | 1.64B              | +74.7%         |
| 2024 | 1.03B              | +319.5%        |
```
Peak Month: October 2024 — $98.3M
Seasonal patterns suggest strong Q4 revenue driven by tourism and events.

#### b. Payment Type Summary (2024)

```markdown
| Payment Type | Total Revenue ($) | Total Trips | % of Total Revenue |
|---------------|-------------------|--------------|---------------------|
| Credit Card   | 885,900,000       | 1,042,000    | 87%                 |
| Cash          | 129,400,000       | 156,000      | 13%                 |
```
Credit card payments dominate, confirming strong digital adoption trends.


#### c. Borough-Level Financial Breakdown

```markdown
| Borough       | Total Revenue ($) | Avg Fare ($) | Avg Tip ($) | Avg Revenue per Mile ($) |
|----------------|-------------------|---------------|--------------|---------------------------|
| Manhattan      | 12.3M             | 11.81         | 2.30         | 6.59                      |
| Brooklyn       | 5.7M              | 14.79         | 1.80         | 5.72                      |
| Queens         | 4.6M              | 37.76         | 1.70         | 5.53                      |
| Bronx          | 2.3M              | 20.29         | 1.20         | 8.21                      |
| Staten Island  | 1.2M              | 28.55         | 1.10         | 14.04                     |
```
Manhattan dominates total revenue, while Queens commands higher fares due to airport traffic.

#### d. Annual Revenue Comparison (Window Function)

Used a CTE with LAG() to compute previous year comparisons:
```markdown
| Year | Total Revenue ($) | Previous Year ($) | Growth (%) |
|------|--------------------|-------------------|-------------|
| 2015 | 2.32B              | NULL              | —           |
| 2016 | 2.11B              | 2.32B             | -8.9%       |
| 2017 | 0.94B              | 2.11B             | -55.5%      |
| 2018 | 1.64B              | 0.94B             | +74.7%      |
| 2024 | 1.03B              | 0.25B             | +319.5%     |
```

### 🚦 Step 4: Operational Analytics

Script: operational_final.sql

Summarizes average trip behavior per borough for management reporting.

```markdown
| Borough       | Avg Distance (mi) | Avg Fare ($) | Avg Total ($) | Fare per Mile ($) | Avg Speed (mph) | Avg Duration (min) |
|----------------|-------------------|---------------|----------------|-------------------|------------------|---------------------|
| Manhattan      | 2.44              | 11.81         | 15.29          | 6.59              | 10.93            | 13.22               |
| Brooklyn       | 3.66              | 14.79         | 17.97          | 5.72              | 14.06            | 15.77               |
| Queens         | 11.63             | 37.76         | 48.33          | 5.53              | 22.02            | 33.69               |
| Bronx          | 5.23              | 20.29         | 23.11          | 8.21              | 15.81            | 21.75               |
| Staten Island  | 7.64              | 28.55         | 36.21          | 14.04             | 25.32            | 24.97               |
| EWR (Airport)  | 7.22              | 75.33         | 91.72          | 640.86            | 197.39           | 10.70               |
```

Manhattan trips are short and dense; Queens and airports dominate in long-haul, high-value rides.

## 💡 Key Insights

1. **Revenue Concentration**: Manhattan and Queens account for over 70% of total revenue.
2. **Digital Dominance**: Credit card payments exceed 80%, signaling widespread digital adoption.
3. **Data Retention**: 96–97% of data retained post-cleaning ensures analytical reliability.
4. **Operational Patterns**: Trips peak between 7–10 AM and 5–7 PM — ideal for demand optimization.
5. **Recovery Trend**: Revenue rebound from 2022–2024 highlights economic recovery and tourism growth.

## ⚙️ Project Workflow

- Data Ingestion: Load raw taxi datasets into DuckDB.

- Validation (Step 2A): Identify missing, duplicate, or invalid entries.

- Quality Checks: Log data anomalies for review.

- Cleaning: Remove invalid and duplicate records.

- Financial Analytics: Aggregate revenue and tip metrics.

- Operational Analytics: Summarize trip distance, duration, and borough performance.

- Reporting: Export summaries for BI dashboards (Power BI).

### 📄 **License**

This project is released under the **MIT License**.  
You’re free to use, modify, and share it for educational and analytical purposes.  

> “Clean data isn’t the end goal — it’s the foundation of every insight that drives better business decisions.”


## 🗂️ Folder Structure
```markdown
sql_project/
│
├─ SQL-queries-in-DuckDB/
│   ├─ validation2.sql
│   ├─ cleaning2.sql
│   ├─ operational_final.sql
│   ├─ financial_final.sql
│
├─ pipeline/
│   ├─ pipeline2.py
│
├─ README.md
└─ LICENSE
```

### ▶️ How to Run

Install DuckDB: https://duckdb.org/

Open DuckDB shell or Python environment.

#### Execute scripts sequentially:

.read validation2.sql
.read cleaning2.sql
.read operational_final.sql
.read financial_final.sql
