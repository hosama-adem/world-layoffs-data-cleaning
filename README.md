# 📊 Global Tech Layoffs Data Cleaning & ETL Pipeline (MySQL)

[![Database](https://img.shields.io/badge/Database-MySQL_8.0+-4479A1?style=for-the-badge&logo=mysql&logoColor=white)](https://www.mysql.com/)
[![SQL Discipline](https://img.shields.io/badge/Discipline-Data_Engineering_%7C_ETL-orange?style=for-the-badge)](#-etl-pipeline-steps)
[![Techniques](https://img.shields.io/badge/Techniques-CTEs_%7C_Window_Functions_%7C_Deduplication-blue?style=for-the-badge)](#-key-sql-operations)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

An end-to-end SQL data cleaning and preparation pipeline built on **MySQL** that transforms raw, inconsistent, and duplicated real-world global tech layoffs data into an analytics-ready dimensional schema.

---

## 🎯 Problem Statement & Objective

Raw business datasets from web scraping and multi-source aggregations typically suffer from:
1. **Duplicate Records**: Multiple submissions with overlapping timestamps.
2. **Inconsistent Naming**: Inconsistent company, industry, and geographic representations (e.g., `"Crypto"`, `"Crypto Currency"`, `"CryptoCurrency"`).
3. **Improper Data Types**: Date strings stored as raw text (`TEXT`/`VARCHAR`) hindering temporal time-series queries.
4. **Missing / Null Values**: Missing industry tags and lay-off counts that require relational imputation.

---

## 🔄 ETL Pipeline Architecture

```
Raw CSV Dataset (data/layoffs.csv)
                │
                ▼
┌───────────────────────────────────────┐
│ 1. Staging Schema & Ingestion         │ ───> `sql/create_staging.sql`
└───────────────────────────────────────┘
                │
                ▼
┌───────────────────────────────────────┐
│ 2. Deduplication via ROW_NUMBER() CTE │ ───> `sql/remove_duplicates.sql`
└───────────────────────────────────────┘
                │
                ▼
┌───────────────────────────────────────┐
│ 3. String Trimming & Standardization  │ ───> `sql/standardize_data.sql`
└───────────────────────────────────────┘
                │
                ▼
┌───────────────────────────────────────┐
│ 4. Null & Blank Value Imputation      │ ───> `sql/handle_nulls.sql`
└───────────────────────────────────────┘
                │
                ▼
┌───────────────────────────────────────┐
│ 5. Analytics-Ready Final Table        │ ───> `sql/final_table.sql`
└───────────────────────────────────────┘
```

---

## ⚡ Key SQL Techniques Implemented

### 1. Window Functions for Duplicate Identification
```sql
WITH duplicate_cte AS (
    SELECT *,
           ROW_NUMBER() OVER(
               PARTITION BY company, location, industry, total_laid_off,
                            percentage_laid_off, `date`, stage, country, funds_raised_millions
           ) AS row_num
    FROM layoffs_staging
)
DELETE FROM layoffs_staging2 
WHERE row_num > 1;
```

### 2. Standardization & Date Type Casting
```sql
-- Standardize inconsistent industry naming conventions
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Convert string dates to ISO standard MySQL DATE format
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;
```

### 3. Self-Join Imputation for Missing Values
```sql
-- Populate missing industries using matching company entries
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
    AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
  AND t2.industry IS NOT NULL
  AND t2.industry != '';
```

---

## 📁 Repository Structure

```
world-layoffs-data-cleaning/
├── data/
│   └── layoffs.csv             # Raw layoffs dataset
├── sql/
│   ├── create_staging.sql      # Staging table setup
│   ├── remove_duplicates.sql   # CTE & Window Function deduplication
│   ├── standardize_data.sql    # String trimming, casing, and date conversion
│   ├── handle_nulls.sql        # Self-joins & null imputation
│   └── final_table.sql         # Production schema definition
└── README.md                   # Project documentation
```

---

## 🚀 How to Run

1. Open your MySQL client (e.g. **MySQL Workbench** or CLI).
2. Create a database:
   ```sql
   CREATE DATABASE world_layoffs;
   USE world_layoffs;
   ```
3. Execute the SQL scripts in numerical order:
   - `create_staging.sql`
   - `remove_duplicates.sql`
   - `standardize_data.sql`
   - `handle_nulls.sql`
   - `final_table.sql`

---

## 📄 License
Distributed under the MIT License. Created by [Hosama Adem](https://github.com/hosama-adem).
