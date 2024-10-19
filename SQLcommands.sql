-- DESCRIBE sales_records.customer_records;
-- DESCRIBE sales_records.exchange_records;
-- DESCRIBE sales_records.product_records;
-- DESCRIBE sales_records.sales_records;
-- DESCRIBE sales_records.stores_records;


-- Customer Records Queries
SELECT * FROM sales_records.customer_records;

SELECT Gender, COUNT(Gender) AS Gender_Count
FROM sales_records.customer_records
WHERE Gender IN ('Male', 'Female')
GROUP BY Gender;

SELECT AgeGroup, COUNT(*) AS Count
FROM sales_records.customer_records
GROUP BY AgeGroup
ORDER BY AgeGroup;

SELECT sr.Country, COUNT(DISTINCT c.CustomerKey) AS customer_count 
FROM sales_records.sales_records c 
JOIN sales_records.stores_records sr ON c.StoreKey = sr.StoreKey
GROUP BY sr.Country 
ORDER BY customer_count DESC;


-- Exchange Records Queries
SELECT * FROM sales_records.exchange_records;

SELECT CurrencyCode, COUNT(*) AS Exchange_Count 
FROM sales_records.exchange_records 
GROUP BY CurrencyCode;

-- Product Records Queries
SELECT * FROM sales_records.product_records;

SELECT Subcategory, COUNT(Subcategory) AS Product_Count 
FROM sales_records.product_records 
GROUP BY Subcategory;

-- Sales Records Queries
SELECT * FROM sales_records.sales_records;

SELECT s.Country, SUM(pr.Unit_Price_USD * sr.Quantity) AS Total_Sales 
FROM sales_records.product_records pr 
JOIN sales_records.sales_records sr ON pr.ProductKey = sr.ProductKey 
JOIN sales_records.stores_records s ON sr.StoreKey = s.StoreKey 
GROUP BY s.Country;


-- Stores Records Queries
SELECT * FROM sales_records.stores_records;

SELECT Country, COUNT(StoreKey) AS Store_Count
FROM sales_records.stores_records
GROUP BY Country
ORDER BY Store_Count DESC;

SELECT s.StoreKey, SUM(pr.Unit_Price_USD * sr.Quantity) AS Total_Sales
FROM sales_records.product_records pr 
JOIN sales_records.sales_records sr ON pr.ProductKey = sr.ProductKey 
JOIN sales_records.stores_records s ON sr.StoreKey = s.StoreKey 
GROUP BY s.StoreKey;


-- Yearly and Brand Profit Queries
SELECT YEAR(Order_Date) AS Year, 
       SUM((Unit_Price_USD - Unit_Cost_USD) * sr.Quantity) AS Profit 
FROM sales_records.sales_records sr 
JOIN sales_records.product_records pr ON sr.ProductKey = pr.ProductKey
GROUP BY YEAR(Order_Date);

SELECT YEAR(Order_Date) AS Year, pr.Brand, 
       ROUND(SUM(Unit_Price_USD * sr.Quantity), 2) AS Year_Sales 
FROM sales_records.sales_records sr 
JOIN sales_records.product_records pr ON sr.ProductKey = pr.ProductKey 
GROUP BY YEAR(Order_Date), pr.Brand;

SELECT Brand,
       SUM(Unit_Cost_USD * sr.Quantity) AS Buying_Price,
       SUM(Unit_Price_USD * sr.Quantity) AS Selling_Price,
       (SUM(Unit_Price_USD * sr.Quantity) - SUM(Unit_Cost_USD * sr.Quantity)) / 
       SUM(Unit_Cost_USD * sr.Quantity) * 100 AS Profit 
FROM sales_records.product_records pr 
JOIN sales_records.sales_records sr ON sr.ProductKey = pr.ProductKey 
GROUP BY Brand;