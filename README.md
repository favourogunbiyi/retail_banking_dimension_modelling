# Dimensional Data Modelling for Retail Banking Analytics
My first data modelling project. Star Schema for a retail bank — built from 15 raw columns to a fully optimised, analytics-ready warehouse

# The Problem

Palladium Bank had 18 months of transaction data and no way to use it properly. Every report ran directly on raw transaction logs — slow, inconsistent, and impossible to scale across five states: Lagos, Abuja, Kano, Port Harcourt, and Ibadan.

The Head of Retail Banking had four questions nobody could answer cleanly:

- Which customer segments generate the most fee income?
- How does transaction behaviour differ across branches and channels?
- Are high-value customers going quiet?
- Which products drive deposits vs withdrawals?

The data existed. The structure to answer those questions didn't. That's what I built.

# What I Did

This was my first data modelling project. I designed a complete Star Schema from scratch — profiling 15 raw columns, identifying what belonged in dimensions vs facts, making SCD decisions, writing the full SQL, and documenting an ETL strategy that could actually handle 18 months of history plus daily incremental loads going forward.

# The Schema

One fact table at the centre, with five dimensions surrounding it.

| Table | What it stores |
|---|---|
| `Fact_Transactions` | Every single transaction — amount, balance, channel, product, branch, date |
| `Dim_Date` | Full time intelligence: Year → Quarter → Month → Day, weekends, public holidays |
| `Dim_Customer` | Who made the transaction — name, ID, tier (Gold/Silver/Bronze) |
| `Dim_Branch` | Where it happened — branch name, state |
| `Dim_Product` | What product was used — savings, loans, current accounts |
| `Dim_Channel` | How it was done — Mobile, ATM, Branch, USSD, Web |

`Txn_ID` lives directly in the fact table as a degenerate dimension. It's just a reference number — no attributes worth spinning into its own table.

# The Decisions That Mattered

# Why Per-Transaction Grain?

I picked the most granular grain possible — one row per transaction. Some of the key business questions involved churn signals: tracking how recently and how often a customer transacts. You can't do that with daily or monthly summaries. You need every event.

# SCD Type 2 — Where History Actually Matters

Not every dimension needs history. I had to think through each one.

**Dim_Customer → Type 2.** Customers move between tiers. If a Bronze customer becomes Gold and you overwrite that, you've just destroyed the loyalty history the bank needs for segmentation. Type 2 creates a new row on every tier change — old record gets an expiry date, new record comes in marked as current.

**Dim_Branch (State) → Type 2.** States can be redistricted. If Lagos North gets reclassified, overwriting it would corrupt every historical regional report. History preserved.

**Dim_Branch Name → Type 1.** A rebrand is just a rebrand. Nobody needs to know what the branch was called before. Overwrite is fine.

**Dim_Product Name → Type 1.** Same logic — product renames are cosmetic. The analytical value is in what the product does, not what it was called last year.

# ETL Strategy — Getting 18 Months In, Then Keeping It Fresh

**Initial load:**
1. Extract raw CSVs into staging — don't touch the main system yet
2. Clean everything: standardise dates to `YYYY-MM-DD`, strip ₦ symbols from amounts, fix text casing inconsistencies like "mobile" vs "MOBILE"
3. Load dimensions first — Date, then Customer, Branch, Product, Channel
4. Load `Fact_Transactions` last — foreign keys must exist before facts land

**Daily incremental loads:**
- Compare incoming `Txn_ID` values against existing records — only insert what's new
- For tier changes: expire the old customer record, insert a new current one (SCD Type 2 in action)
- Unique constraint on `Txn_ID` physically blocks any duplicate from sneaking in

# Performance — Built for Scale From the Start

Three things I put in from the beginning so the model doesn't slow down as data grows:

**Monthly partitioning.** Instead of one massive `Fact_Transactions` table, I split it into monthly partitions on `Txn_Date`. A query for March data goes straight to the March partition — it doesn't touch 17 other months of transactions.

**Four indexes.** `Date_Key`, `Customer_Key`, `Branch_Key`, and a composite `(Date_Key, Branch_Key)` for regional reports. Think of them as bookmarks at the back of the book — the database jumps straight to the right page instead of reading everything.

**Pre-aggregation table.** `Agg_Monthly_Branch_Revenue` pre-calculates deposits, withdrawals, and transaction counts by branch, per month. Dashboard load time goes from scanning millions of rows every refresh to reading one pre-built summary.

# Data Quality — Four Checks Before Anything Enters the Model

| Check | What it catches | What happens |
|---|---|---|
| Null Amount | Transaction with no value recorded | Rejected and logged to error table |
| Date Range | Date outside the 18-month window or in the future | Flagged and sent to data team |
| Duplicate Txn_ID | Same transaction appearing twice | First occurrence kept, rest discarded |
| Unknown Customer | Transaction linked to a Customer_ID not in the system | Record held until customer is resolved |

# Drill-Down Hierarchies

| Dimension | How analysts can drill down |
|---|---|
| Date | Year → Quarter → Month → Day |
| Location | State → Branch |
| Product | Product Type → Product Name |
| Customer | Tier → Customer Name |

# Files in This Repo

| File | What's inside |
|---|---|
| `star_schema_dimension_tables.sql` | All 5 dimension tables — surrogate keys, SCD columns, comments explaining every decision |
| `star_schema_fact_transaction.sql` | Fact table with all foreign key constraints and the degenerate dimension |
| `star_schema_performance_recommendation.sql` | Partitioning script, 4 indexes, and the aggregation table |
| `star_schema_diagram.pdf` | Visual schema — all tables and relationships at a glance |
| `Dimensional_Data_Modelling_for_Retail_Banking.pdf` | Full technical report — 6 pages covering every design decision |

# Tools & Concepts

`SQL (MySQL)` · `Star Schema Design` · `Dimensional Modelling` · `SCD Type 1 & 2` · `ETL / ELT Strategy` · `Range Partitioning` · `Composite Indexing` · `Aggregation Tables` · `Data Quality Framework` · `Kimball Methodology`

# What This Model Enables

Once data is loaded into this schema:
- Branch revenue reports that load in milliseconds — not minutes
- Customer churn detection using transaction recency and frequency
- Channel performance comparison across all five transaction methods
- Tier-based segmentation for targeted product strategy
- Full-time intelligence: YoY growth, month-on-month trends, quarter comparisons

*This was my first data modelling project — built April 2026 as part of HNG Internship Stage 3.*
*The process of figuring out grain decisions, SCD types, and ETL orders from scratch was genuinely one of the most interesting problems I've worked through.*

*https://github.com/favourogunbiyi/data_analysis_portfolio*
