CREATE TABLE sales_store (
    transaction_id   TEXT,
    customer_id      TEXT,
    customer_name    TEXT,
    customer_age     TEXT,
    gender            TEXT,
    product_id       TEXT,
    product_name     TEXT,
    product_category TEXT,
    quantiy           TEXT,
    prce              TEXT,
    payment_mode     TEXT,
    purchase_date    TEXT,
    time_of_purchase TEXT,
    status            TEXT
);

SELECT * FROM sales_store
LIMIT 5;

--Fix Column Name Mistakes

ALTER TABLE sales_store
RENAME COLUMN quantiy TO quantity;

ALTER TABLE sales_store
RENAME COLUMN prce TO price;

--Change date format according to data

SET datestyle = 'DMY'

--Convert Data Types 

ALTER TABLE sales_store
ALTER COLUMN transaction_id TYPE VARCHAR(15) USING transaction_id::VARCHAR(15),
ALTER COLUMN customer_id TYPE VARCHAR(15) USING customer_id::VARCHAR(15),
ALTER COLUMN customer_name TYPE VARCHAR(30) USING customer_name::VARCHAR(30),
ALTER COLUMN customer_age TYPE INT USING customer_age::INT,
ALTER COLUMN gender TYPE VARCHAR(15) USING gender::VARCHAR(15),
ALTER COLUMN product_id TYPE VARCHAR(15) USING product_id::VARCHAR(15),
ALTER COLUMN product_name TYPE VARCHAR(15) USING product_name::VARCHAR(15),
ALTER COLUMN product_category TYPE VARCHAR(15) USING product_category::VARCHAR(15),
ALTER COLUMN quantity TYPE INT USING quantity::INT,
ALTER COLUMN price TYPE FLOAT USING price::FLOAT,
ALTER COLUMN payment_mode TYPE VARCHAR(15) USING payment_mode::VARCHAR(15),
ALTER COLUMN purchase_date TYPE DATE USING purchase_date::DATE,
ALTER COLUMN time_of_purchase TYPE TIME USING time_of_purchase::TIME,
ALTER COLUMN status TYPE VARCHAR(15) USING status::VARCHAR(15);

--Check for duplicate values

SELECT
    transaction_id,
    COUNT(*) AS duplicate_count
FROM sales_store
GROUP BY transaction_id
HAVING COUNT(*) > 1;

SELECT *
FROM sales_store
WHERE transaction_id IN (
    SELECT transaction_id
    FROM sales_store
    GROUP BY transaction_id
    HAVING COUNT(*) > 1
)
ORDER BY transaction_id;

--Drop duplicate

DELETE FROM sales_store a
USING sales_store b
WHERE a.ctid > b.ctid
AND a.transaction_id = b.transaction_id;


--Check for null value

SELECT *
FROM sales_store
WHERE
    transaction_id IS NULL OR
    customer_id IS NULL OR
    customer_name IS NULL OR
    customer_age IS NULL OR
    gender IS NULL OR
    product_id IS NULL OR
    product_name IS NULL OR
    product_category IS NULL OR
    quantity IS NULL OR
    price IS NULL OR
    payment_mode IS NULL OR
    purchase_date IS NULL OR
    time_of_purchase IS NULL OR
    status IS NULL;

--Drop row where transaction id = null

DELETE FROM sales_store
WHERE transaction_id IS NULL

--Alter null values according to previous data

SELECT * FROM sales_store
WHERE customer_name = 'Ehsaan Ram'
--CUST9494

SELECT * FROM sales_store
WHERE customer_name = 'Damini Raju'
--CUST1401

SELECT * FROM sales_store
WHERE customer_id = 'CUST1003'
--Mahika Saini,35,Male

UPDATE sales_store
SET customer_id = 'CUST9494'
WHERE transaction_id = 'TXN977900'

UPDATE sales_store
SET customer_id = 'CUST1401'
WHERE transaction_id = 'TXN985663'


UPDATE sales_store
SET customer_name = 'Mahika Saini',customer_age = '35',gender = 'Male'
WHERE transaction_id = 'TXN432798'

--0null value left

--Data cleaning

SELECT DISTINCT gender
FROM sales_store

UPDATE sales_store
SET gender = 'Male'
WHERE gender = 'M'

UPDATE sales_store
SET gender = 'Female'
WHERE gender = 'F'

SELECT DISTINCT payment_mode
FROM sales_store

UPDATE sales_store
SET payment_mode = 'Credit Card'
WHERE payment_mode = 'CC'

--Add revenue column

ALTER TABLE sales_store
ADD COLUMN total_amount FLOAT;

UPDATE sales_store
SET total_amount = quantity * price;


SELECT * FROM sales_store


-----------------------------------------------------------------------------------------------------

--Data analysis--

-- 1. What are the top 5 most selling products by quantity?


SELECT DISTINCT status
FROM sales_store


SELECT
    product_id,
    product_name,
    SUM(quantity) AS total_quantity_sold
FROM sales_store
WHERE status = 'delivered'
GROUP BY product_id, product_name
ORDER BY total_quantity_sold DESC
LIMIT 5;


--Business Problem: We don't know which products are most in demand.

--Business Impact: Helps prioritize stock and boost sales through targeted promotions.

----------------------------------------------------------------------------------------

-- 2. Which products are most frequently cancelled?

SELECT 
	product_id,
	product_name, 
	SUM(quantity) AS total_quantity_cancelled 
	FROM sales_store
	WHERE status = 'cancelled'
	GROUP BY product_id,product_name
	ORDER BY total_quantity_cancelled DESC
	LIMIT 5;

--Business Problem: Frequent cancellations affect revenue and customer trust.

--Business Impact: Identify poor-performing products to improve quality or remove from catalog.

----------------------------------------------------------------------------------------


-- 3. What time of the day has the highest number of purchases?

SELECT
		
    EXTRACT(HOUR FROM time_of_purchase) AS hour_of_theday,
    CASE
        WHEN EXTRACT(HOUR FROM time_of_purchase) BETWEEN 5 AND 11 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM time_of_purchase) BETWEEN 12 AND 16 THEN 'Afternoon'
        WHEN EXTRACT(HOUR FROM time_of_purchase) BETWEEN 17 AND 21 THEN 'Evening'
        ELSE 'Night'
    END AS time_of_day,
    COUNT(*) AS total_purchases
FROM sales_store
GROUP BY time_of_day,hour_of_theday
ORDER BY total_purchases DESC;

--Business Problem Solved: Find peak sales times.

--Business Impact: Optimize staffing, promotions, and server loads.

----------------------------------------------------------------------------------------


-- 4. Who are the top 5 highest spending customers?

SELECT
    customer_id,
    customer_name,
    SUM(quantity) AS total_orders,
    TO_CHAR(SUM(total_amount), 'FM₹999,99,99,999') AS total_spent
FROM sales_store
WHERE status = 'delivered'
GROUP BY customer_id, customer_name
ORDER BY SUM(total_amount) DESC
LIMIT 5;

--Business Problem Solved: Identify VIP customers.

--Business Impact: Personalized offers, loyalty rewards, and retention.

----------------------------------------------------------------------------------------


-- 5. Which product categories generate the highest revenue?


SELECT
    payment_mode,
    TO_CHAR(SUM(total_amount), 'FM₹999,99,99,999') AS total_revenue
FROM sales_store
GROUP BY payment_mode
ORDER BY SUM(total_amount) DESC;

	

--Business Problem Solved: Identify top-performing product categories.

--Business Impact: Refine product strategy, supply chain, and promotions.
--allowing the business to invest more in high-margin or high-demand categories.

----------------------------------------------------------------------------------------


-- 6. What is the return/cancellation rate per product category?

SELECT
    product_category,
    COUNT(*) AS total_orders,
    COUNT(*) FILTER (
        WHERE LOWER(status) IN ('returned', 'cancelled')
    ) AS returned_cancelled_orders,
    ROUND(
        COUNT(*) FILTER (
            WHERE LOWER(status) IN ('returned', 'cancelled')
        ) * 100.0 / COUNT(*),
        2
    ) AS return_cancel_rate_pct
FROM sales_store
GROUP BY product_category
ORDER BY return_cancel_rate_pct DESC;



--Business Problem Solved: Monitor dissatisfaction trends per category.


---Business Impact: Reduce returns, improve product descriptions/expectations.
--Helps identify and fix product or logistics issues.

----------------------------------------------------------------------------------------

-- 7. What is the most preferred payment mode?

SELECT
    product_category,
    TO_CHAR(SUM(total_amount), 'FM₹999,99,99,999') AS total_revenue
FROM sales_store
WHERE status = 'delivered'
GROUP BY product_category
ORDER BY SUM(total_amount) DESC;

--Business Problem Solved: Know which payment options customers prefer.

--Business Impact: Streamline payment processing, prioritize popular modes.

----------------------------------------------------------------------------------------

-- 8. How does age group affect purchasing behavior?


SELECT
    CASE
        WHEN customer_age < 18 THEN 'Under 18'
        WHEN customer_age BETWEEN 18 AND 25 THEN '18–25'
        WHEN customer_age BETWEEN 26 AND 35 THEN '26–35'
        WHEN customer_age BETWEEN 36 AND 45 THEN '36–45'
        WHEN customer_age BETWEEN 46 AND 60 THEN '46–60'
        ELSE '60+'
    END AS age_group,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(transaction_id) AS total_transactions,
    SUM(quantity) AS total_items_purchased,
    ROUND(AVG(total_amount)::NUMERIC, 2) AS avg_order_value
FROM sales_store
GROUP BY age_group
ORDER BY age_group DESC;

--Business Problem Solved: Understand customer demographics.

--Business Impact: Targeted marketing and product recommendations by age group.

----------------------------------------------------------------------------------------


--9. What’s the monthly sales trend?


SELECT
    TO_CHAR(purchase_date, 'YYYY-MM') AS month,
    TO_CHAR(SUM(total_amount), 'FM₹999,99,99,999') AS monthly_sales
FROM sales_store
GROUP BY month
ORDER BY month;


--Business Problem: Sales fluctuations go unnoticed.


--Business Impact: Plan inventory and marketing according to seasonal trends.


----------------------------------------------------------------------------------------



