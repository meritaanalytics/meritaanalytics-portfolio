# Notebooks: how each result was reached

One Jupyter notebook per project. Each one reads the raw files in `../datasets/`, works through the analysis in numbered steps and ends with findings and recommendations. Every step starts with a short note on **what** it does and **why**, so the notebooks can be read by a manager as well as run by an analyst.

GitHub shows each notebook with its tables and charts already in place, so there's no need to run anything to read it.

| # | Notebook | Business question | Tools | Headline result |
|---|---|---|---|---|
| 01 | [Digital lending credit risk in SQL](01_lending_credit_risk_sql.ipynb) | How risky is the loan book, and which approval rule makes the most money? | SQL (CTEs, window functions), pandas | Affordability cap: Ksh 9.58M net value vs 4.06M approving everyone |
| 02 | [Predicting loan default](02_predicting_loan_default.ipynb) | Can we rank applicants by risk and set a profitable cut-off? | SQL, scikit-learn | Test AUC 0.84, KS 0.56; a Ksh 1.59M loss turned into a 462k profit |
| 03 | [M-Pesa personal finance analytics](03_mpesa_personal_finance.ipynb) | Where does the money go, and which payments look unusual? | pandas, regex | 26.4% savings rate; 12 of 12 anomalies caught, 0 false alarms |
| 04 | [Customer segmentation for a SACCO](04_customer_segmentation.ipynb) | Which groups of members exist, and what should we do for each? | scikit-learn (k-means, PCA) | 4 stable segments, silhouette 0.465 vs −0.03 at random |
| 05 | [Insurance data quality and claim frequency](05_insurance_data_quality.ipynb) | Which records can be trusted, and what do they say about claims? | pandas, Excel output | 3.15% premium overstatement caught by a merge check |
| 06 | [Shop sales and ledger reconciliation](06_shop_sales_reconciliation.ipynb) | Do the sales numbers agree with the finance ledger? | pandas, Excel output | Ksh 85,000 unexplained posting isolated to one store-month |
| 07 | [Kenya against six regional peers](07_kenya_public_data.ipynb) | How do Kenya's growth and inflation compare with its peers? | pandas, public data | 4.6% real growth a year, 2nd of 7 |
| 08 | [Workshop production and OEE](08_workshop_production_oee.ipynb) | Which machine, shift and cause is behind lost output and scrap? | pandas, Seaborn | Mill is the bottleneck; Grinder night-shift scrap 5.4% |

**Excel.** Project 06 is also rebuilt with live Excel formulas (SUMIFS, INDEX/MATCH, SUMPRODUCT) in [`../excel/06_shop_sales_reconciliation.xlsx`](../excel/06_shop_sales_reconciliation.xlsx). Projects 05 and 06 also write Excel reports to `outputs/`.

**SQL.** Projects 01 and 02 run their SQL against `../datasets/01-lending-credit-risk/sql/lender.db`. The same queries are in `credit_risk_queries.sql` in that folder.

## Run them yourself

```bash
pip install -r ../requirements.txt
jupyter notebook
```

Open any notebook and choose **Run All**. Run from inside this `notebooks/` folder, because the notebooks find the data at `../datasets/`. Each notebook runs in under a minute and gives the same numbers as the portfolio.

## About the data

All projects use synthetic data generated with fixed seeds, except Project 07, which uses public World Bank and Our World in Data files. See [`../datasets/README.md`](../datasets/README.md).

© 2026 Benson M. Merita / MeritaAnalytics
