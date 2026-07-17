-- ================================================
-- ONLINE RETAIL SQL EDA
-- Author: [Okunowo Oluwademilade David]
-- Date: [09/07/2025]
-- Database: PostgreSQL
-- ================================================


-- ================================================
-- SECTION 1: REVENUE & SALES TRENDS
-- ================================================

-- Q1: Total revenue per month
SELECT Month,
SUM(Revenue) AS Total_revenue
FROM Online_Retail_Stores
GROUP BY MONTH
ORDER BY MONTH;

-- Q2a: Highest revenue month
SELECT MONTH,
SUM(Revenue) AS Total_revenue
FROM Online_Retail_Stores
GROUP BY MONTH
ORDER BY Total_revenue DESC LIMIT 1;

--Q2b:SELECT MONTH,
SUM(Revenue) AS Total_revenue
FROM Online_Retail_Stores
GROUP BY MONTH
ORDER BY Total_revenue ASC LIMIT 1;

-- Q3: Average Order Value (AOV)
SELECT ROUND(AVG(Order_Total), 2) AS AOV
FROM (
    SELECT 
        InvoiceNo,
        SUM(Revenue) AS Order_Total
    FROM Online_Retail_Stores
    GROUP BY InvoiceNo
) AS orders;

-- ============================
-- SECTION 2: Product Performance
-- ============================

-- Q4: Top 10 products by revenue
SELECT Description,
ROUND(SUM(Revenue),2) AS Total_Revenue
FROM Online_Retail_Stores
WHERE Description NOT IN ('Manual', 'Postage', 'Dotcom Postage', 'Bank Charges', 'Amazon Fee')
GROUP BY Description
ORDER BY Total_Revenue DESC LIMIT 10;

-- Q5: Top 10 products by quantity sold
SELECT Description,
SUM(Quantity) AS Quantity_Sold
FROM Online_Retail_Stores
WHERE Description NOT IN ('Manual', 'Postage', 'Dotcom Postage', 'Bank Charges', 'Amazon Fee')
GROUP BY Description
ORDER BY Quantity_Sold DESC LIMIT 10;

-- Q6: Products appearing in both top 10 revenue and top 10 quantity lists
SELECT r.Description
FROM (
    SELECT Description
    FROM Online_Retail_stores
    WHERE Description NOT IN ('Manual','Postage','Dotcom Postage','Bank Charges')
    GROUP BY Description
    ORDER BY SUM(Revenue) DESC LIMIT 10
) r
INNER JOIN (
    SELECT Description
    FROM Online_Retail_stores
    WHERE Description NOT IN ('Manual','Postage','Dotcom Postage','Bank Charges')
    GROUP BY Description
    ORDER BY SUM(Quantity) DESC LIMIT 10
) q ON r.Description = q.Description;

-- ============================
-- SECTION 3: Customer Analysis
-- ============================

-- Q7: Unique customers
SELECT COUNT(DISTINCT CustomerID) AS Unique_Customers
FROM Online_Retail_stores;

-- Q8: One-time vs repeat buyers
SELECT 
    CASE 
        WHEN Order_Count = 1 THEN 'One-Time' 
        ELSE 'Repeat' 
    END AS Customer_Type,
    COUNT(*) AS Num_Customers
FROM (
    SELECT 
        CustomerID,
        COUNT(DISTINCT InvoiceNo) AS Order_Count
    FROM Online_Retail_Stores
    GROUP BY CustomerID
) AS Customer_Orders
GROUP BY Customer_Type;

-- Q9: Top 10 customers by revenue
SELECT CustomerID,ROUND(SUM(Revenue),2)AS Total_Revenue
FROM Online_Retail_Stores
GROUP BY CustomerID
ORDER BY Total_Revenue DESC LIMIT 10;

-- Q10: RFM Segmentation
rfm_scores AS (
    SELECT *,
        NTILE(4) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(4) OVER (ORDER BY Frequency) AS F_Score,
        NTILE(4) OVER (ORDER BY Monetary) AS M_Score
    FROM rfm_base
)
SELECT 
    CustomerID,
    Recency,
    Frequency,
    Monetary,
    R_Score,
    F_Score,
    M_Score,
    CASE 
        WHEN R_Score >= 3 AND F_Score >= 3 AND M_Score >= 3 THEN 'Champions'
        WHEN R_Score >= 3 AND F_Score >= 3 THEN 'Loyal'
        WHEN R_Score <= 2 THEN 'At Risk'
        ELSE 'Others'
    END AS Segment
FROM rfm_scores;

-- ============================
-- SECTION 4: Geographic Analysis
-- ============================

-- Q11: Top 10 countries by revenue
SELECT Country,ROUND(SUM(Revenue),2) AS Total_Revenue
FROM Online_Retail_Stores
GROUP BY Country
ORDER BY Total_Revenue DESC LIMIT 10;

-- Q12: High order volume but low revenue per order
SELECT 
    Country,
    COUNT(DISTINCT InvoiceNo) AS Orders,
    ROUND(SUM(Revenue), 2) AS Total_Revenue,
    ROUND(SUM(Revenue) / COUNT(DISTINCT InvoiceNo), 2) AS Revenue_per_Order
FROM Online_Retail_Stores
GROUP BY Country
ORDER BY Revenue_per_Order ASC
LIMIT 10;

-- ============================
-- SECTION 5: RETURNS ANALYSIS
-- ============================

-- Q13: Overall return rate
SELECT 
    (SELECT COUNT(DISTINCT InvoiceNo) FROM Online_Retail_Stores) AS Completed_Orders,
    (SELECT COUNT(DISTINCT InvoiceNo) 
     FROM Cancelled_Orders
     WHERE ABS(Quantity) < 10000
     AND Description NOT IN ('Manual', 'Postage', 'Dotcom Postage')
    ) AS Cancelled_Order,
    ROUND(
        (SELECT COUNT(DISTINCT InvoiceNo) 
         FROM Cancelled_Orders
         WHERE ABS(Quantity) < 10000
         AND Description NOT IN ('Manual', 'Postage', 'Dotcom Postage')
        ) * 100.0 /
        (SELECT COUNT(DISTINCT InvoiceNo) FROM Online_Retail_Stores), 2
    ) AS Return_Rate_Pct;
-- Q14: Top 10 most returned products
SELECT 
    Description,
    SUM(ABS(Quantity)) AS Units_Returned
FROM Cancelled_Orders
WHERE Description NOT IN ('Manual', 'Postage', 'Dotcom Postage', 'Bank Charges')
AND ABS(Quantity) < 10000
GROUP BY Description
ORDER BY Units_Returned DESC
LIMIT 10;