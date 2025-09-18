USE electronics;

-- Preview the data in all key tables
SELECT * FROM customers;
SELECT * FROM exchange_rates;
SELECT * FROM products;
SELECT * FROM sales;
SELECT * FROM stores;

--------------------------------------------------------------------------------
-- Q1. Customers by Country (France only)
--------------------------------------------------------------------------------
SELECT 
    c.CustomerKey,
    c.Name,
    c.Country
FROM Customers c
WHERE c.Country = 'france';
-- Insight: Helps isolate customers in a specific geography/market.
-- Useful for regional marketing campaigns or evaluating country-wise demand.

--------------------------------------------------------------------------------
-- Q2. Count how many Males and Females are in the table
--------------------------------------------------------------------------------
SELECT Gender, COUNT(*) AS Total
FROM customers
GROUP BY Gender;
-- Insight: The dataset is slightly imbalanced toward Males.
-- This could be relevant for any gender-based demographic analysis.

--------------------------------------------------------------------------------
-- Q3. Filter sales after a certain date (2023 onwards)
--------------------------------------------------------------------------------
SELECT 
    s.`Order Number`,
    s.`Order Date`,
    s.Quantity
FROM Sales s
WHERE s.`Order Date` >= '2023-01-01';
-- Insight: Helps identify recent transactions.
-- Useful for sales analysis or to focus on current trends instead of old data.

--------------------------------------------------------------------------------
-- Q4. Find total sales quantity by product
--------------------------------------------------------------------------------
SELECT 
    p.`Product Name`,
    SUM(s.Quantity) AS TotalQuantity
FROM Sales s
JOIN Products p ON s.ProductKey = p.ProductKey
GROUP BY p.`Product Name`
ORDER BY TotalQuantity DESC;
-- Insight: Helps identify best-selling products.

--------------------------------------------------------------------------------
-- Q5. Find high-value products (Top 10 by price)
--------------------------------------------------------------------------------
SELECT 
    p.`Product Name`,
    p.Brand,
    p.`UnitPriceNumeric`
FROM Products p
ORDER BY p.`UnitPriceNumeric` DESC
LIMIT 10;
-- Insight: Identifies the top premium products in the catalog.

--------------------------------------------------------------------------------
-- Q6. Revenue Contribution by Gender
--------------------------------------------------------------------------------
SELECT 
    c.Gender,
    SUM(s.Quantity * p.UnitPriceNumeric) AS Revenue
FROM Sales s
JOIN Customers c ON s.CustomerKey = c.CustomerKey
JOIN Products p ON s.ProductKey = p.ProductKey
GROUP BY c.Gender
ORDER BY Revenue DESC;
-- Insight: Shows which gender segment spends more.

--------------------------------------------------------------------------------
-- Q7. Total Sales Revenue by Product
--------------------------------------------------------------------------------
SELECT 
    p.`Product Name`,
    SUM(s.Quantity * p.`UnitPriceNumeric`) AS TotalRevenue
FROM Sales s
JOIN Products p ON s.ProductKey = p.ProductKey
GROUP BY p.`Product Name`
ORDER BY TotalRevenue DESC;
-- Insight: Identifies top revenue-generating products.
-- Useful for product portfolio management and promotions.

--------------------------------------------------------------------------------
-- Q8. Total Sales by Country
--------------------------------------------------------------------------------
SELECT 
    c.Country,
    SUM(s.Quantity * p.`UnitPriceNumeric`) AS CountryRevenue
FROM Sales s
JOIN Customers c ON s.CustomerKey = c.CustomerKey
JOIN Products p ON s.ProductKey = p.ProductKey
GROUP BY c.Country
ORDER BY CountryRevenue DESC;
-- Insight: Shows which countries contribute most to revenue.
-- Supports market expansion or regional sales strategy.

--------------------------------------------------------------------------------
-- Q9. Show customers who have placed more than 10 orders
--------------------------------------------------------------------------------
SELECT 
    CustomerKey,
    COUNT(`Order Number`) AS TotalOrders
FROM Sales
GROUP BY CustomerKey
HAVING TotalOrders > 10
ORDER BY TotalOrders DESC;
-- Insight: Highlights frequent buyers.

--------------------------------------------------------------------------------
-- Q10. Show stores that processed more than 200 items in total
--------------------------------------------------------------------------------
SELECT 
    StoreKey,
    SUM(Quantity) AS TotalSold
FROM Sales
GROUP BY StoreKey
HAVING TotalSold > 200
ORDER BY TotalSold DESC;
-- Insight: Identifies high-volume stores for operational focus.

--------------------------------------------------------------------------------
-- Q11. Find all products with “Phone” in the name
--------------------------------------------------------------------------------
SELECT *
FROM Products
WHERE `Product Name` LIKE '%Phone%';
-- Insight: Helps filter products by keyword, e.g., for promotions or catalog searches.

--------------------------------------------------------------------------------
-- Q12. Find products never sold
--------------------------------------------------------------------------------
SELECT ProductKey, `Product Name`
FROM Products
WHERE ProductKey NOT IN (
    SELECT DISTINCT ProductKey
    FROM Sales
);
-- Insight: Useful for inventory optimization and identifying unsold products.

--------------------------------------------------------------------------------
-- Q13. Countries with total sales greater than France
--------------------------------------------------------------------------------
SELECT 
    c.Country,
    SUM(s.Quantity * p.`UnitPriceNumeric`) AS CountryRevenue
FROM Sales s
JOIN Customers c ON s.CustomerKey = c.CustomerKey
JOIN Products p ON s.ProductKey = p.ProductKey
GROUP BY c.Country
HAVING CountryRevenue > (
    SELECT SUM(s2.Quantity * p2.`UnitPriceNumeric`)
    FROM Sales s2
    JOIN Customers c2 ON s2.CustomerKey = c2.CustomerKey
    JOIN Products p2 ON s2.ProductKey = p2.ProductKey
    WHERE c2.Country = 'France'
);
-- Explanation: 
-- Outer query → Calculates revenue for each country.
-- Subquery → Calculates total revenue of France.
-- HAVING clause → Keeps only countries with revenue greater than France.
-- Insight: Helps identify top-performing countries relative to France.
-- Useful for market comparison and expansion strategy.

--------------------------------------------------------------------------------
-- Q14. Store(s) with the largest square meter size
--------------------------------------------------------------------------------
SELECT StoreKey, Country, State, `Square Meters`
FROM Stores
WHERE `Square Meters` = (
    SELECT MAX(`Square Meters`)
    FROM Stores
);
-- Insight: Identifies the largest store footprint in the dataset.
-- Useful for understanding which location has the highest capacity or importance.

--------------------------------------------------------------------------------
-- Q15. Find late deliveries
--------------------------------------------------------------------------------
SELECT 
    s.`Order Number`,
    s.`Order Date`,
    s.`Delivery Date`,
    DATEDIFF(s.`Delivery Date`, s.`Order Date`) AS DeliveryDelay
FROM Sales s
WHERE s.`Delivery Date` > s.`Order Date`
ORDER BY DeliveryDelay DESC
LIMIT 1000;
-- Insight: Useful for improving logistics & supply chain.

--------------------------------------------------------------------------------
-- Q16. Count of Customers by Gender (Alternative Query)
--------------------------------------------------------------------------------
SELECT count(Gender) AS Total
FROM customers
GROUP BY Gender;

--------------------------------------------------------------------------------
-- Q17. List of Female Customers
--------------------------------------------------------------------------------
SELECT * 
FROM customers
WHERE Gender = 'Female';

--------------------------------------------------------------------------------
-- Q18. Revenue by Year
--------------------------------------------------------------------------------
SELECT YEAR(`Order Date`) AS Year, 
       SUM(s.Quantity * p.UnitPriceNumeric) AS TotalRevenue
FROM Sales s
JOIN Products p ON s.ProductKey = p.ProductKey
GROUP BY YEAR(`Order Date`)
ORDER BY Year;
-- Insight: Tracks yearly revenue trends.

--------------------------------------------------------------------------------
-- Q19. Revenue by Month for 2023
--------------------------------------------------------------------------------
SELECT MONTH(`Order Date`) AS Month, 
       SUM(s.Quantity * p.UnitPriceNumeric) AS MonthlyRevenue
FROM Sales s
JOIN Products p ON s.ProductKey = p.ProductKey
WHERE YEAR(`Order Date`) = 2023
GROUP BY MONTH(`Order Date`)
ORDER BY Month;
-- Insight: Useful for analyzing monthly seasonality in 2023.

--------------------------------------------------------------------------------
-- Q20. Top 5 Customers by Revenue
--------------------------------------------------------------------------------
SELECT c.CustomerKey, c.Name, 
       SUM(s.Quantity * p.UnitPriceNumeric) AS CustomerRevenue
FROM Sales s
JOIN Customers c ON s.CustomerKey = c.CustomerKey
JOIN Products p ON s.ProductKey = p.ProductKey
GROUP BY c.CustomerKey, c.Name
ORDER BY CustomerRevenue DESC
LIMIT 5;
-- Insight: Identifies most valuable customers.

--------------------------------------------------------------------------------
-- Q21. Average Orders per Customer
--------------------------------------------------------------------------------
SELECT AVG(OrderCount) AS AvgOrders
FROM (
    SELECT CustomerKey, COUNT(`Order Number`) AS OrderCount
    FROM Sales
    GROUP BY CustomerKey
) AS Sub;
-- Insight: Provides average customer engagement level.

--------------------------------------------------------------------------------
-- Q22. Bottom 5 Products by Sales Quantity
--------------------------------------------------------------------------------
SELECT p.`Product Name`, SUM(s.Quantity) AS TotalQuantity
FROM Sales s
JOIN Products p ON s.ProductKey = p.ProductKey
GROUP BY p.`Product Name`
ORDER BY TotalQuantity ASC
LIMIT 5;
-- Insight: Identifies least popular products.

--------------------------------------------------------------------------------
-- Q23. Top 3 Countries by Revenue
--------------------------------------------------------------------------------
SELECT c.Country, SUM(s.Quantity * p.UnitPriceNumeric) AS CountryRevenue
FROM Sales s
JOIN Customers c ON s.CustomerKey = c.CustomerKey
JOIN Products p ON s.ProductKey = p.ProductKey
GROUP BY c.Country
ORDER BY CountryRevenue DESC
LIMIT 3;
-- Insight: Shows the top 3 most profitable countries.
