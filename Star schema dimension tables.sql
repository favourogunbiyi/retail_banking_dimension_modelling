-- PALLADIUM BANK DIMENSIONAL MODEL
-- Date: April 2026
-- Description: Star Schema for Retail Banking

-- DIMENSION TABLES

-- DIMENSION 1: Dim_Date
-- Purpose: Supports all time-based analysis and drill-down from Year to Month to Day
CREATE TABLE Dim_Date (
    Date_Key INT PRIMARY KEY,    	-- Format: YYYYMMDD e.g. 20240115
    full_Date DATE NOT NULL,       	-- Actual date value
    Day INT NOT NULL,       	-- Day number 1-31
    Month INT NOT NULL,     	    -- Month number 1-12
    Month_Name VARCHAR(20)  NOT NULL,       -- January, February etc
    Quarter VARCHAR(5) NOT NULL,       		-- Q1, Q2, Q3, Q4
    Year INT NOT NULL,       				-- 2023, 2024 etc
    Is_Weekend CHAR(3)  NOT NULL,       	-- Yes or No
    Is_Public_Holiday	CHAR(3)	NOT NULL	-- Yes or No
);


-- DIMENSION 2: Dim_Customer
-- Purpose: Stores customer identity and tier segmentation for behavioural analysis 
-- I used SCD Type 2 because it allows me to keep history of transactions instead of overwriting them which leads to accurate reports.
CREATE TABLE Dim_Customer 
	(Customer_Key INT PRIMARY KEY  AUTO_INCREMENT, 	-- Surrogate Key
    Customer_ID VARCHAR(20) NOT NULL,       		-- Natural Key from source
    Customer_Name VARCHAR(100) NOT NULL,      		-- Full customer name
    Tier VARCHAR(20) NOT NULL,       				-- Gold, Silver, Bronze etc
	UNIQUE(Customer_ID),
    
    -- SCD Type 2 columns is added for future use
    Effective_Date  DATE NOT NULL,      	 -- When this record became active
    Expiry_Date DATE NULL,          		 -- When this record was replaced
    Is_Current CHAR(3) NOT NULL       		 -- Yes = current record
);

-- DIMENSION 3: Dim_Branch
-- Purpose: Stores branch name and location for regional performance analysis
CREATE TABLE Dim_Branch 
	(Branch_Key INT PRIMARY KEY AUTO_INCREMENT, 	-- Surrogate Key
    Branch_ID  VARCHAR(30) NOT NULL,      	 -- Natural Key from source
    Branch_Name VARCHAR(100) NOT NULL,       -- Name of branch
    State VARCHAR(50) NOT NULL,       	-- Lagos, Abuja, Kano etc
	UNIQUE (Branch_ID),
    -- SCD Type 2 columns for future use
    Effective_Date DATE NOT NULL,
    Expiry_Date DATE NULL,
    Is_Current CHAR(3) NOT NULL
);

-- DIMENSION 4: Dim_Product
-- Purpose: Stores banking product details for product performance analysis
CREATE TABLE Dim_Product 
	(Product_Key INT PRIMARY KEY AUTO_INCREMENT, 	-- Surrogate Key
    Product_ID VARCHAR(20) NOT NULL,       	-- Natural Key from source
    Product_Name VARCHAR(100) NOT NULL,     -- Name of product
    Product_Type VARCHAR(50) NOT NULL,		-- Savings, Loan, Current etc
    UNIQUE (Product_ID)
);

-- DIMENSION 5: Dim_Txn_Profile
-- Purpose: Stores details for transaction channels for future channel analysis
CREATE TABLE Dim_Channel 
	(Channel_Key INT PRIMARY KEY AUTO_INCREMENT, -- Surrogate Key
    Channel_Name VARCHAR(60) NOT NULL    -- Mobile, ATM, Branch, USSD, Web
);

