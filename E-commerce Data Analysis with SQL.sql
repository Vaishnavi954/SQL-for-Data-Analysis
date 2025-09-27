-- ===========================================
-- 1️⃣ Drop existing tables/views if they exist
-- ===========================================

DROP VIEW IF EXISTS monthly_sales;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS ecommerce;

-- ===========================================
-- 2️⃣ Create ecommerce table
-- ===========================================
CREATE TABLE `ecommerce` (
   `CID` BIGINT DEFAULT NULL,
   `TID` BIGINT DEFAULT NULL,
   `Gender` VARCHAR(10) DEFAULT NULL,
   `Age Group` VARCHAR(20) DEFAULT NULL,
   `Purchase Date` DATETIME DEFAULT NULL,
   `Product Category` VARCHAR(50) DEFAULT NULL,
   `Discount Availed` VARCHAR(5) DEFAULT NULL,
   `Discount Name` VARCHAR(20) DEFAULT NULL,
   `Discount Amount (INR)` FLOAT DEFAULT NULL,
   `Gross Amount` FLOAT DEFAULT NULL,
   `Net Amount` FLOAT DEFAULT NULL,
   `Purchase Method` VARCHAR(50) DEFAULT NULL,
   `Location` VARCHAR(50) DEFAULT NULL,
   `Purchase_Date_Clean` DATE DEFAULT NULL,
   KEY `idx_category` (`Product Category`),
   KEY `idx_purchase_date` (`Purchase Date`),
   KEY `idx_age_group` (`Age Group`),
   KEY `idx_location` (`Location`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ===========================================
-- 3️⃣ Load data from CSV into ecommerce
-- ===========================================
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sampledataset_Ecommerce Dataset for Data Analysis.csv'
INTO TABLE ecommerce
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(CID, TID, Gender, @Age_Group, @Purchase_Date, @Product_Category, @Discount_Availed, @Discount_Name, @Discount_Amount, @Gross_Amount, @Net_Amount, @Purchase_Method, @Location)
SET
  `Age Group` = NULLIF(@Age_Group, ''),
  `Purchase Date` = STR_TO_DATE(NULLIF(@Purchase_Date,''), '%d/%m/%Y %H:%i:%s'),
  `Product Category` = NULLIF(@Product_Category, ''),
  `Discount Availed` = NULLIF(@Discount_Availed, ''),
  `Discount Name` = NULLIF(@Discount_Name, ''),
  `Discount Amount (INR)` = NULLIF(@Discount_Amount, ''),
  `Gross Amount` = NULLIF(@Gross_Amount, ''),
  `Net Amount` = NULLIF(@Net_Amount, ''),
  `Purchase Method` = NULLIF(@Purchase_Method, ''),
  Location = NULLIF(@Location, ''),
  `Purchase_Date_Clean` = STR_TO_DATE(NULLIF(@Purchase_Date,''), '%d/%m/%Y %H:%i:%s');

-- ===========================================
-- 4️⃣ Create customers table with sample data
-- ===========================================
CREATE TABLE customers (
   CID BIGINT PRIMARY KEY,
   Name VARCHAR(50),
   Email VARCHAR(100)
);

-- Sample records
INSERT INTO customers (CID, Name, Email) VALUES
(943146, 'Amit Sharma', 'amit@example.com'),
(587632, 'Priya Nair', 'priya@example.com'),
(123456, 'Rahul Mehta', 'rahul@example.com');

-- ===========================================
-- 5️⃣ Queries for analysis
-- ===========================================

-- View first 10 records
SELECT * FROM ecommerce LIMIT 10;

-- Purchases by Female customers in Electronics category
SELECT CID, Gender, `Product Category`, `Net Amount`, `Purchase Date`
FROM ecommerce
WHERE Gender = 'Female' AND `Product Category` = 'Electronics'
ORDER BY `Net Amount` DESC;

-- Total sales by Product Category
SELECT `Product Category`, SUM(`Net Amount`) AS total_sales
FROM ecommerce
GROUP BY `Product Category`
ORDER BY total_sales DESC;

-- Average discount per location
SELECT Location, AVG(`Discount Amount (INR)`) AS avg_discount
FROM ecommerce
GROUP BY Location;

-- INNER JOIN: customer purchases
SELECT c.Name, e.`Product Category`, e.`Net Amount`, e.Location
FROM ecommerce e
INNER JOIN customers c ON e.CID = c.CID;

-- LEFT JOIN: all customers, even without purchases
SELECT c.Name, e.`Product Category`, e.`Net Amount`
FROM customers c
LEFT JOIN ecommerce e ON c.CID = e.CID;

-- Products with above-average Net Amount
SELECT `Product Category`, `Net Amount`
FROM ecommerce
WHERE `Net Amount` > (
    SELECT AVG(`Net Amount`) FROM ecommerce
);

-- Top 5 customers by spending
SELECT CID, SUM(`Net Amount`) AS total_spent
FROM ecommerce
GROUP BY CID
ORDER BY total_spent DESC
LIMIT 5;

-- ===========================================
-- 6️⃣ Create monthly_sales view
-- ===========================================
CREATE VIEW monthly_sales AS
SELECT DATE_FORMAT(`Purchase Date`, '%Y-%m') AS month,
       SUM(`Net Amount`) AS total_sales
FROM ecommerce
GROUP BY month;

-- Query the view
SELECT * FROM monthly_sales;
