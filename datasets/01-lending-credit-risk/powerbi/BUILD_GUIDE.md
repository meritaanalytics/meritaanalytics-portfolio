# Build the Loan Book Dashboard in Power BI

This takes about 2–3 hours. When you finish you'll have a `.pbix` file and screenshots for the portfolio.

## 1. Load the four tables

Home → Get data → Text/CSV, then load each file:

| File | Table type | Key |
|---|---|---|
| `fact_loans.csv` | Fact: one row per loan | `loan_id` |
| `dim_customer.csv` | Dimension | `customer_id` |
| `dim_date.csv` | Dimension: calendar, 2024–2025 | `date` |
| `dim_product.csv` | Dimension: product with assumed LGD | `product` |

In Power Query, check these data types:
- `disbursement_date` and `date` are **Date**
- money columns are **Decimal number**
- `is_default` and `is_mature` are **Whole number**

## 2. Mark the date table

Select `dim_date`, then Table tools → Mark as date table → choose `date`.

## 3. Relationships (Model view)

All three are many-to-one with single direction, from the dimension to the fact:

- `dim_customer[customer_id]` 1 → * `fact_loans[customer_id]`
- `dim_date[date]` 1 → * `fact_loans[disbursement_date]`
- `dim_product[product]` 1 → * `fact_loans[product]`

The result is a **star schema**: one fact table with dimensions around it. Job ads often ask for this, so name it in your write-up.

## 4. Measures

Add the measures in `DAX_measures.md`. Then check your numbers against the table at the end of that file before building any visuals.

## 5. Pages

**Page 1: Portfolio overview**
- KPI cards: Loans, Disbursed (Ksh), Outstanding (Ksh), Default Rate %, PAR30 %
- Line chart: Disbursed (Ksh) by `dim_date[year_month]`
- Bar chart: Default Rate % by `product`
- Slicers: product, `dim_customer[county]`, `dim_date[year]`

**Page 2: Risk drivers**
- Column chart: Default Rate % by `score_band` (sort it <550, 550-599 … 700+)
- Column chart: Default Rate % by `ratio_band` (the 60%+ band stands out at 55.6%)
- Bar chart: Default Rate % by `dim_customer[occupation]`
- Matrix: product × score_band showing Default Rate % and Loans

**Page 3: Vintages and expected loss**
- Line chart: Default Rate % and Default Rate 3M Rolling % by `vintage`
- Table: product, Default Rate %, LGD, EAD Active (Ksh), Expected Loss (Ksh)
- Card: Expected Loss (Ksh) and EL % of EAD

## 6. Finish

- Use the same colours as the portfolio: blue `#1B4F8A`, green `#0B8467`, ink `#0D2238`.
- Give every page a title that states the finding, for example "Instalments above 60% of income default at 55.6%".
- Add a footer text box: "Synthetic data, generated with a fixed seed. Illustrative only."
- Save the file as `loan_book_dashboard.pbix`.
- Take one screenshot per page (Windows + Shift + S) and save them as `page1.png`, `page2.png` and `page3.png`.

Send the screenshots back and I'll add them to Project 01 on the portfolio.

Publishing to the web is optional. Power BI's "Publish to web" needs a work account. Screenshots plus the `.pbix` on GitHub are enough for recruiters.
