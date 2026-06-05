-- Partition Fact_Transactions by Month
-- This means the database only scans the relevant month's data instead of scanning all 18 months
CREATE TABLE Fact_Transactions_New (
    Txn_ID INT NOT NULL,
    Txn_Date DATE NOT NULL,
    Customer_ID INT,
    Product_ID INT,
    Amount DECIMAL(18,2),
    Balance_After DECIMAL (18,2),
    PRIMARY KEY (Txn_ID, Txn_Date) -- Date MUST be here
)
PARTITION BY RANGE COLUMNS (Txn_Date) (
    PARTITION p2024_01 VALUES LESS THAN ('2024-02-01'),
    PARTITION p2024_02 VALUES LESS THAN ('2024-03-01'),
    PARTITION p_future VALUES LESS THAN (MAXVALUE)
);

--- INDEX--
-- Index 1: Date_Key (most common filter)
CREATE INDEX idx_date 
ON Fact_Transactions(Date_Key);

-- Index 2: Customer_Key (customer analysis)
CREATE INDEX idx_customer 
ON Fact_Transactions(Customer_Key);

-- Index 3: Branch_Key (regional analysis)
CREATE INDEX idx_branch 
ON Fact_Transactions(Branch_Key);

-- Index 4: Composite index for common queries
CREATE INDEX idx_date_branch 
ON Fact_Transactions(Date_Key, Branch_Key);

-- Monthly Revenue Summary by Branch
-- This pre-calculates common queries
-- so the dashboard loads instantly

CREATE TABLE Agg_Monthly_Branch_Revenue (
    Agg_Key         INT             PRIMARY KEY AUTO_INCREMENT,
    Year            INT             NOT NULL,   -- 2024
    Month           INT             NOT NULL,   -- 1-12
    Branch_Key      INT             NOT NULL,   -- FK to Dim_Branch
    Total_Amount    DECIMAL(18,2)   NOT NULL,   -- Total transactions
    Total_Deposits  DECIMAL(18,2)   NOT NULL,   -- Total deposits only
    Total_Withdrawals DECIMAL(18,2) NOT NULL,   -- Total withdrawals only
    Transaction_Count INT           NOT NULL,   -- Number of transactions

    CONSTRAINT fk_agg_branch
        FOREIGN KEY (Branch_Key)
        REFERENCES Dim_Branch(Branch_Key)
);