-- MeritaAnalytics portfolio · Project 01: Digital lending credit risk
-- Database: lender.db (SQLite). Snapshot date: 2025-12-31.
-- Every query below runs as written:  sqlite3 lender.db < credit_risk_queries.sql

-- 1. Data quality checks in one query: each row should show 0 failing
SELECT 'duplicate loan_id' AS chk, COUNT(*) - COUNT(DISTINCT loan_id) AS rows_failing FROM loans
UNION ALL SELECT 'principal <= 0', COUNT(*) FROM loans WHERE principal_ksh <= 0
UNION ALL SELECT 'credit score outside 300-850', COUNT(*) FROM loans WHERE credit_score NOT BETWEEN 300 AND 850
UNION ALL SELECT 'term_months <= 0', COUNT(*) FROM loans WHERE term_months <= 0
UNION ALL SELECT 'loan with unknown customer', COUNT(*) FROM loans WHERE customer_id NOT IN (SELECT customer_id FROM customers)
UNION ALL SELECT 'repayment with unknown loan', COUNT(*) FROM repayments WHERE loan_id NOT IN (SELECT loan_id FROM loans)
UNION ALL SELECT 'defaulted but days_past_due <= 90', COUNT(*) FROM loans WHERE status = 'Defaulted' AND days_past_due <= 90;

-- 2. Right-censoring check: default rate by loan age (young loans have not had time to default)
WITH l AS (SELECT *, CAST(julianday('2025-12-31') - julianday(disbursement_date) AS INTEGER) AS age_days FROM loans)
SELECT CASE WHEN age_days <= 180 THEN '1: up to 180 days' WHEN age_days <= 365 THEN '2: 181-365 days'
            ELSE '3: over 365 days' END AS age_band,
       COUNT(*) AS loans, SUM(status = 'Defaulted') AS defaults,
       ROUND(100.0 * SUM(status = 'Defaulted') / COUNT(*), 1) AS default_rate_pct
FROM l GROUP BY age_band ORDER BY age_band;

-- 3. Mature cohort (>= 180 days) with instalment-to-income ratio, for segment analysis
SELECT l.*, c.age, c.occupation, c.county, c.monthly_income_ksh,
       (status = 'Defaulted') AS is_default,
       principal_ksh * (1 + interest_rate_pct / 100.0 * term_months / 12) / term_months / monthly_income_ksh AS inst_to_income
FROM loans l JOIN customers c ON c.customer_id = l.customer_id
WHERE julianday('2025-12-31') - julianday(disbursement_date) >= 180
LIMIT 10;

-- 4. Vintage analysis with a 3-month rolling default rate (window function)
WITH v AS (
  SELECT strftime('%Y-%m', disbursement_date) AS vintage, COUNT(*) AS loans, SUM(status = 'Defaulted') AS defaults,
         ROUND(100.0 * SUM(status = 'Defaulted') / COUNT(*), 1) AS default_rate_pct, ROUND(AVG(credit_score)) AS avg_score
  FROM loans WHERE julianday('2025-12-31') - julianday(disbursement_date) >= 180
  GROUP BY vintage)
SELECT *, ROUND(AVG(default_rate_pct) OVER (ORDER BY vintage ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 1) AS rolling3_pct
FROM v ORDER BY vintage;

-- 5. Portfolio at risk (PAR30, PAR90) by product, from the repayment schedule
WITH sched AS (
  SELECT loan_id, COUNT(*) AS n_due, SUM(paid_date IS NULL) AS n_unpaid,
         MAX(CASE WHEN paid_date IS NULL THEN julianday('2025-12-31') - julianday(due_date) ELSE 0 END) AS max_overdue
  FROM repayments GROUP BY loan_id),
book AS (
  SELECT l.product, l.principal_ksh * (l.term_months - (s.n_due - s.n_unpaid)) * 1.0 / l.term_months AS outstanding, s.max_overdue
  FROM loans l JOIN sched s USING (loan_id))
SELECT product, COUNT(*) AS loans, ROUND(SUM(outstanding) / 1e6, 2) AS outstanding_m,
       ROUND(100.0 * SUM(CASE WHEN max_overdue > 30 THEN outstanding ELSE 0 END) / SUM(outstanding), 1) AS par30_pct,
       ROUND(100.0 * SUM(CASE WHEN max_overdue > 90 THEN outstanding ELSE 0 END) / SUM(outstanding), 1) AS par90_pct
FROM book WHERE outstanding > 0 GROUP BY product ORDER BY par90_pct DESC;

-- 6. Exposure at default (EAD) on the Active book, by product (feeds expected loss = PD x LGD x EAD)
SELECT l.product, COUNT(*) AS active_loans,
       SUM(l.principal_ksh * (l.term_months - (s.n_due - s.n_unpaid)) * 1.0 / l.term_months) AS ead_ksh
FROM loans l JOIN (SELECT loan_id, COUNT(*) AS n_due, SUM(paid_date IS NULL) AS n_unpaid FROM repayments GROUP BY loan_id) s USING (loan_id)
WHERE l.status = 'Active' GROUP BY l.product;
