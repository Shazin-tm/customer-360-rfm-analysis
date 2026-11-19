-- ============================================================
-- Customer 360 and RFM Intelligence Platform: SQL analysis
-- Database: Oracle 10g | Table: customer_360 (4,337 customers)
-- Source: UCI Online Retail dataset (Dec 2010 - Dec 2011)
-- ============================================================

SELECT banner FROM v$version;
SELECT COUNT(*) AS total_customers FROM customer_360;

-- Q1: Which segments bring in the most revenue?
-- Shows customers, revenue and % share of total revenue per segment.
SELECT segment, COUNT(*) AS customers, ROUND(SUM(monetary)) AS revenue
FROM customer_360
GROUP BY segment
ORDER BY revenue DESC;


-- Q1b: What share of total revenue does each segment bring?
-- Same as Q1a, plus each segment's % of total revenue (SUM(SUM(...)) OVER () gives the grand total).
SELECT segment,
       COUNT(*) AS customers,
       ROUND(SUM(monetary)) AS revenue,
       ROUND(100 * SUM(monetary) / SUM(SUM(monetary)) OVER (), 1) AS pct_of_revenue
FROM customer_360
GROUP BY segment
ORDER BY revenue DESC;


-- Q2: Who are our top 10 customers by total spend?
-- Sorted inside the brackets first, then ROWNUM keeps the top 10 (Oracle 10g has no FETCH FIRST).
SELECT * FROM (
    SELECT customerid, segment, country, monetary
    FROM customer_360
    ORDER BY monetary DESC
)
WHERE ROWNUM <= 10;

-- Q3: Which 5 countries generate the most revenue?
-- Shows how dependent the business is on a few markets.
SELECT * FROM (
    SELECT country,
           COUNT(*) AS customers,
           ROUND(SUM(monetary)) AS revenue
    FROM customer_360
    GROUP BY country
    ORDER BY revenue DESC
)
WHERE ROWNUM <= 5;

-- Q4: Who should we win back first?
-- At Risk customers who spent over 1000, biggest spenders first.
SELECT customerid, country, recency, frequency, monetary
FROM customer_360
WHERE segment = 'At Risk' AND monetary > 1000
ORDER BY monetary DESC;

-- Q5: Are customers coming back?
-- Compares one-time buyers with repeat buyers: how many, and average spend.
SELECT CASE WHEN frequency = 1 THEN 'One-time' ELSE 'Repeat' END AS buyer_type,
       COUNT(*) AS customers,
       ROUND(AVG(monetary)) AS avg_spend
FROM customer_360
GROUP BY CASE WHEN frequency = 1 THEN 'One-time' ELSE 'Repeat' END;

-- Q6: Which countries have at least 20 customers?
-- HAVING filters groups after counting, so small markets are left out.
SELECT country, COUNT(*) AS customers
FROM customer_360
GROUP BY country
HAVING COUNT(*) >= 20
ORDER BY customers DESC;


-- Practice: segments with at least 500 customers
SELECT segment, COUNT(*) AS customers
FROM customer_360
GROUP BY segment
HAVING COUNT(*) >= 500
ORDER BY customers DESC;


-- Q7: What does a typical customer in each segment look like?
-- Average Recency, Frequency and Monetary per segment.
SELECT segment,
       COUNT(*) AS customers,
       ROUND(AVG(recency)) AS avg_recency,
       ROUND(AVG(frequency), 1) AS avg_frequency,
       ROUND(AVG(monetary)) AS avg_monetary
FROM customer_360
GROUP BY segment
ORDER BY avg_monetary DESC;


-- Q8: How much revenue sits with customers who may be lost?
-- Total spend of At Risk and Hibernating customers.
SELECT segment, COUNT(*) AS customers, ROUND(SUM(monetary)) AS revenue
FROM customer_360
WHERE segment IN ('At Risk', 'Hibernating')
GROUP BY segment;


-- Q9: Which one-time buyers spent a lot?
-- Frequency = 1 and Monetary over 1000: strong candidates for a come-back campaign.
SELECT customerid, country, recency, monetary
FROM customer_360
WHERE frequency = 1 AND monetary > 1000
ORDER BY monetary DESC;


-- Q10: How long do customers stay active in each segment?
-- Average customer lifetime in days (first to last purchase) per segment.
SELECT segment, ROUND(AVG(customer_lifetime_days)) AS avg_lifetime_days
FROM customer_360
GROUP BY segment
ORDER BY avg_lifetime_days DESC;


-- Q11: Where are our Champions?
-- Top 5 countries by number of Champion customers.
SELECT * FROM (
    SELECT country, COUNT(*) AS champions
    FROM customer_360
    WHERE segment = 'Champions'
    GROUP BY country
    ORDER BY champions DESC
)
WHERE ROWNUM <= 5;


--Power BI and Oracle agree on the win-back list.
SELECT COUNT(*) FROM customer_360 WHERE segment = 'At Risk' AND monetary > 1000;




