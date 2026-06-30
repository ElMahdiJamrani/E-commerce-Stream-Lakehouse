# ShopStream Lakehouse Analytics Platform

A production-style **Lakehouse Analytics Platform** built on the
[Olist Brazilian E-Commerce Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).

## Tech Stack

| Layer             | Technology              |
| ----------------- | ----------------------- |
| Storage & Compute | Databricks + Delta Lake |
| Transformation    | dbt Core                |
| ML Tracking       | MLflow                  |
| Visualization     | Tableau                 |
| Language          | Python + SQL            |

## Architecture

Medallion Architecture: Bronze → Silver → Gold

| Layer  | Purpose                                            |
| ------ | -------------------------------------------------- |
| Bronze | Raw ingestion, no transformation, full audit trail |
| Silver | Cleaned, validated, schema-enforced data           |
| Gold   | Business-ready aggregates for analytics and ML     |

## Dataset

Real commercial data from Olist, a Brazilian e-commerce marketplace.

- 100,000 orders · 9 relational tables · 2016–2018
- Source: [Kaggle — Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

## Project Milestones

- [x] Milestone 1 — Environment setup, Bronze ingestion
- [x] Milestone 2 — Silver layer, data quality checks
- [x] Milestone 3 — Gold layer, dbt transformations
- [x] Milestone 4 — MLflow + churn prediction model
- [ ] Milestone 5 — Tableau dashboards

## Author

El Mahdi Jamrani — [LinkedIn](https://www.linkedin.com/in/el-mahdi-jamrani/)
