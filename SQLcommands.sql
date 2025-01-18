use database sales_record;

-- Customer Demographics across Region
SELECT 
    c.Country,
    c.Continent,
    c.State,
    c.City,
    c.Gender,
    c.Age_Category,
    COUNT(*) as CustomerCount,
    COUNT(DISTINCT s.OrderNumber) as TotalOrders,
    SUM(s.Revenue_USD) as TotalRevenue,
    AVG(s.Revenue_USD) as AvgRevenue
FROM cleaned_customers c
JOIN cleaned_sales s ON c.CustomerKey = s.CustomerKey
GROUP BY 
    c.Country, c.Continent, c.State, 
    c.City, c.Gender, c.Age_Category;
ORDER BY TotalRevenue DESC;

-- Store Performance Analysis
SELECT 
    st.Country,
    st.Store_Size_Category,
    COUNT(DISTINCT s.OrderNumber) as TotalOrders,
    SUM(s.Revenue_USD) as TotalRevenue
FROM Cleaned_Stores st
JOIN Cleaned_Sales s ON st.StoreKey = s.StoreKey
GROUP BY st.Country, st.Store_Size_Category
ORDER BY TotalOrders DESC;

-- Sales Trend Analysis
SELECT 
    YEAR(OrderDate) as Year,
    MONTH(OrderDate) as Month,
    COUNT(DISTINCT OrderNumber) as TotalOrders,
    SUM(Revenue_USD) as TotalRevenue,
    AVG(Revenue_USD) as AvgOrderValue
FROM Cleaned_Sales
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY Year, Month;


-- Customer Purchase Frequency
SELECT 
    c.CustomerKey,
    COUNT(DISTINCT s.OrderNumber) as OrderCount,
    SUM(s.Revenue_USD) as TotalSpent,
    SUM(s.Revenue_USD)/COUNT(DISTINCT s.OrderNumber) as AvgOrderValue
FROM Cleaned_Customers c
JOIN Cleaned_Sales s ON c.CustomerKey = s.CustomerKey
GROUP BY c.CustomerKey
ORDER BY TotalSpent DESC;

-- Product Performance Analysis
SELECT 
    p.Category,
    p.Subcategory,
    p.Brand,
    COUNT(DISTINCT s.OrderNumber) as OrderCount,
    SUM(s.Quantity) as TotalUnitsSold,
    SUM(s.Revenue_USD) as TotalRevenue,
    AVG(p.UnitPriceUSD) as AvgUnitPrice,
    AVG(p.UnitPriceUSD - p.UnitCostUSD) as AvgProfit,
    ((AVG(p.UnitPriceUSD - p.UnitCostUSD)/AVG(p.UnitPriceUSD)) * 100) as ProfitMargin_Percentage
FROM cleaned_products p
JOIN cleaned_sales s ON p.ProductKey = s.ProductKey
GROUP BY p.Category, p.Subcategory, p.Brand
ORDER BY TotalRevenue DESC;

-- Customer Segment Analysis by Age and Gender
SELECT 
    c.Age_Category,
    c.Gender,
    COUNT(DISTINCT c.CustomerKey) as CustomerCount,
    SUM(s.Revenue_USD) as TotalRevenue,
    AVG(s.Revenue_USD) as AvgRevenue
FROM cleaned_customers c
JOIN cleaned_sales s ON c.CustomerKey = s.CustomerKey
GROUP BY c.Age_Category, c.Gender
ORDER BY TotalRevenue DESC;

-- Store Efficiency Analysis
SELECT 
    st.StoreKey,
    st.Country,
    st.State,
    st.Store_Size_Category,
    st.SquareMeters,
    DATEDIFF(NOW(), st.OpenDate) as DaysInOperation,
    COUNT(DISTINCT s.OrderNumber) as TotalOrders,
    SUM(s.Revenue_USD) as TotalRevenue,
    SUM(s.Revenue_USD)/st.SquareMeters as Revenue_Per_SqMeter,
    SUM(s.Revenue_USD)/NULLIF(DATEDIFF(NOW(), st.OpenDate), 0) as Revenue_Per_Day
FROM cleaned_stores st
JOIN cleaned_sales s ON st.StoreKey = s.StoreKey
GROUP BY 
    st.StoreKey, st.Country, st.State, 
    st.Store_Size_Category, st.SquareMeters, st.OpenDate
ORDER BY TotalRevenue DESC;

-- Top Products by Revenue in Each Category
WITH RankedProducts AS (
    SELECT 
        p.Category,
        p.ProductName,
        SUM(s.Revenue_USD) as TotalRevenue,
        RANK() OVER (PARTITION BY p.Category ORDER BY SUM(s.Revenue_USD) DESC) as RevRank
    FROM cleaned_products p
    JOIN cleaned_sales s ON p.ProductKey = s.ProductKey
    GROUP BY p.Category, p.ProductName
)
SELECT *
FROM RankedProducts
WHERE RevRank <= 3;

-- Sales by Currency Analysis
SELECT 
    s.CurrencyCode,
    COUNT(DISTINCT s.OrderNumber) as Orders,
    SUM(s.Revenue_USD) as Revenue_USD,
    AVG(e.Exchange) as Avg_Exchange_Rate,
    SUM(s.Revenue_USD * e.Exchange) as Local_Currency_Revenue
FROM cleaned_sales s
JOIN cleaned_exchange_rates e 
    ON s.CurrencyCode = e.CurrencyCode 
    AND s.OrderDate = e.Date
GROUP BY s.CurrencyCode
ORDER BY Revenue_USD DESC;

-- Seasonal Sales Analysis by Category
SELECT 
    p.Category,
    QUARTER(s.OrderDate) as Quarter,
    MONTHNAME(s.OrderDate) as Month,
    COUNT(DISTINCT s.OrderNumber) as TotalOrders,
    SUM(s.Quantity) as UnitsSold,
    SUM(s.Revenue_USD) as TotalRevenue,
    AVG(s.Revenue_USD) as AvgOrderValue
FROM cleaned_sales s
JOIN cleaned_products p ON s.ProductKey = p.ProductKey
GROUP BY 
    p.Category,
    QUARTER(s.OrderDate),
    MONTHNAME(s.OrderDate)
ORDER BY 
    p.Category,
    QUARTER(s.OrderDate);
