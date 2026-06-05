-- PALLADIUM BANK FACT MODEL
-- Date: April 2026
-- Description: Star Schema for Retail Banking

-- FACT TABLES
-- Purpose: Records all financial activities.

CREATE TABLE Fact_Transactions -- surrogate keys first
(Txn_Key INT NOT NULL AUTO_INCREMENT,
Date_Key INT NOT NULL, 
Customer_Key INT NOT NULL,
Branch_Key INT NOT NULL,
Product_Key INT NOT NULL,
Channel_Key INT NOT NULL,
-- degenerate dimension
Txn_ID VARCHAR(50) NOT NULL,
Txn_Type VARCHAR (50) NOT NULL,
-- Facts( Quantitative derivatives)
Amount DECIMAL(18,2) NOT NULL,       -- Transaction amount in Naira
Balance_After DECIMAL(18,2) NOT NULL,       -- Balance after transaction
-- Primary key - ensures uniqueness of transaction
PRIMARY KEY (Txn_Key),
CONSTRAINT unique_txn UNIQUE (Txn_ID),
 -- Foreign Key Constraints
CONSTRAINT fk_date FOREIGN KEY (Date_Key) REFERENCES Dim_Date(Date_Key),
CONSTRAINT fk_customer FOREIGN KEY (Customer_Key) REFERENCES Dim_Customer(Customer_Key),
CONSTRAINT fk_branch FOREIGN KEY (Branch_Key) REFERENCES Dim_Branch(Branch_Key),
CONSTRAINT fk_product FOREIGN KEY (Product_Key) REFERENCES Dim_Product(Product_Key),
CONSTRAINT fk_channel FOREIGN KEY (Channel_Key) REFERENCES Dim_Channel(Channel_Key)
);
