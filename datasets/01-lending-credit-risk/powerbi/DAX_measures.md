# DAX measures: Loan Book Dashboard

Create a blank table called `_Measures` (Home → Enter data → OK), then add each measure below to it (Modeling → New measure). The names match the build guide.

## Volume

```DAX
Loans = COUNTROWS ( fact_loans )

Disbursed (Ksh) = SUM ( fact_loans[principal_ksh] )

Outstanding (Ksh) = SUM ( fact_loans[outstanding_ksh] )

Avg Loan Size (Ksh) = DIVIDE ( [Disbursed (Ksh)], [Loans] )
```

## Default rate (mature loans only)

Loans younger than 180 days have not had time to default, so including them understates risk. These measures only count mature loans.

```DAX
Mature Loans = CALCULATE ( [Loans], fact_loans[is_mature] = 1 )

Mature Defaults =
CALCULATE ( [Loans], fact_loans[is_mature] = 1, fact_loans[is_default] = 1 )

Default Rate % = DIVIDE ( [Mature Defaults], [Mature Loans] )
```

Format `Default Rate %` as a percentage with 1 decimal place. With no filters it should show **20.2%**.

## Portfolio at risk

PAR30 is the share of the outstanding balance on loans with an instalment more than 30 days overdue.

```DAX
PAR30 % =
DIVIDE (
    CALCULATE ( [Outstanding (Ksh)], fact_loans[max_overdue_days] > 30 ),
    [Outstanding (Ksh)]
)

PAR90 % =
DIVIDE (
    CALCULATE ( [Outstanding (Ksh)], fact_loans[max_overdue_days] > 90 ),
    [Outstanding (Ksh)]
)
```

## Expected loss: PD × LGD × EAD

```DAX
EAD Active (Ksh) =
CALCULATE ( [Outstanding (Ksh)], fact_loans[status] = "Active" )

Expected Loss (Ksh) =
SUMX (
    VALUES ( fact_loans[product] ),
    VAR prob_default = CALCULATE ( [Default Rate %] )
    VAR lgd = CALCULATE ( MAX ( dim_product[lgd_assumed] ) )
    VAR ead = CALCULATE ( [EAD Active (Ksh)] )
    RETURN prob_default * lgd * ead
)

EL % of EAD = DIVIDE ( [Expected Loss (Ksh)], [EAD Active (Ksh)] )
```

With no filters, `Expected Loss (Ksh)` should be close to **Ksh 2,186,800**, which is 10.9% of EAD.

## Time intelligence

```DAX
Disbursed MoM % =
VAR cur  = [Disbursed (Ksh)]
VAR prev = CALCULATE ( [Disbursed (Ksh)], DATEADD ( dim_date[date], -1, MONTH ) )
RETURN DIVIDE ( cur - prev, prev )

Default Rate 3M Rolling % =
CALCULATE (
    [Default Rate %],
    DATESINPERIOD ( dim_date[date], MAX ( dim_date[date] ), -3, MONTH )
)
```

## Checking your numbers

| Measure | Expected (no filters) |
|---|---|
| Loans | 560 |
| Mature Loans | 485 |
| Default Rate % | 20.2% |
| Default Rate %, Asset Finance | 36.0% |
| Default Rate %, ratio band 60%+ | 55.6% |
| Expected Loss (Ksh) | about 2,186,800 |

If a figure is off, the usual cause is a relationship that is missing or running in the wrong direction. See step 3 of the build guide.
