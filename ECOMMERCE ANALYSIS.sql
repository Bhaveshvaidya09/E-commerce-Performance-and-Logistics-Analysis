SELECT * FROM customers;
SELECT * FROM category_name_translation;
SELECT * FROM geolocation;
SELECT * FROM order_items;
SELECT * FROM order_payments;
SELECT * FROM orders;
SELECT * FROM orders_reviews;
SELECT * FROM products;
SELECT * FROM sellers;

-- #######################################################################
-- # 1. CUSTOMERS TABLE
-- #######################################################################
CREATE TABLE customers (
    customer_id TEXT PRIMARY KEY,
    customer_unique_id TEXT,
    customer_zip_code_prefix VARCHAR(5),
    customer_city TEXT,
    customer_state VARCHAR(2)
);

-- #######################################################################
-- # 2. ORDERS TABLE
-- #######################################################################
CREATE TABLE orders (
    order_id TEXT PRIMARY KEY,
    customer_id TEXT,
    order_status VARCHAR(20),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

-- #######################################################################
-- # 3. ORDER ITEMS TABLE (Composite PK on order_id and order_item_id)
-- #######################################################################
CREATE TABLE order_items (
    order_id TEXT,
    order_item_id INTEGER,
    product_id TEXT,
    seller_id TEXT,
    shipping_limit_date TIMESTAMP,
    price NUMERIC,
    freight_value NUMERIC,
    PRIMARY KEY (order_id, order_item_id)
);

-- #######################################################################
-- # 4. ORDER PAYMENTS TABLE (Composite PK on order_id and payment_sequential)
-- #######################################################################
CREATE TABLE order_payments (
    order_id TEXT,
    payment_sequential INTEGER,
    payment_type VARCHAR(20),
    payment_installments INTEGER,
    payment_value NUMERIC,
    PRIMARY KEY (order_id, payment_sequential)
);

-- #######################################################################
-- # 5. ORDER REVIEWS TABLE
-- #######################################################################
CREATE TABLE order_reviews (
    review_id TEXT PRIMARY KEY,
    order_id TEXT,
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date DATE,
    review_answer_timestamp TIMESTAMP
);

-- #######################################################################
-- # 6. PRODUCTS TABLE
-- #######################################################################
CREATE TABLE products (
    product_id TEXT PRIMARY KEY,
    product_category_name TEXT,
    product_name_lenght INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);

-- #######################################################################
-- # 7. SELLERS TABLE
-- #######################################################################
CREATE TABLE sellers (
    seller_id TEXT PRIMARY KEY,
    seller_zip_code_prefix VARCHAR(5),
    seller_city TEXT,
    seller_state VARCHAR(2)
);

-- #######################################################################
-- # 8. CATEGORY NAME TRANSLATION
-- #######################################################################
CREATE TABLE category_name_translation (
    product_category_name TEXT PRIMARY KEY,
    product_category_name_english TEXT
);

-- #######################################################################
-- # 9. GEOLOCATION TABLE
-- #######################################################################
CREATE TABLE geolocation (
    geolocation_zip_code_prefix VARCHAR(5),
    geolocation_lat NUMERIC,
    geolocation_lng NUMERIC,
    geolocation_city TEXT,
    geolocation_state VARCHAR(2)
);

---What is the total number of orders recorded in the dataset?
SELECT COUNT(order_id) FROM orders;

---How many unique customers have placed an order?
SELECT
      COUNT(DISTINCT CUSTOMER_UNIQUE_ID)
FROM
	CUSTOMERS;

--What is the average review score given by customers?
SELECT AVG(review_score ) AS AVG_REVIEW_SCORE FROM 	orders_reviews;

--What are the top 5 highest item prices sold individually?
SELECT product_id , price FROM order_items ORDER BY price desc LIMIT 5;

--How many orders have the status 'delivered'?
SELECT COUNT(order_status) FROM orders
WHERE order_status = 'delivered';

---List all distinct payment types used.
SELECT  DISTINCT(payment_type) From  order_payments;

--Count the total number of customers per Brazilian State (top 10).
SELECT customer_state, COUNT(customer_id) AS customer_count FROM customers GROUP BY 1 ORDER BY 2 DESC LIMIT 10;


--Find the newest order purchase date in the dataset.
SELECT MAX (order_purchase_timestamp)FROM orders;

---advanced queries
SELECT * FROM customers;
SELECT * FROM category_name_translation;
SELECT * FROM geolocation;
SELECT * FROM order_items;
SELECT * FROM order_payments;
SELECT * FROM orders;
SELECT * FROM orders_reviews;
SELECT * FROM products;
SELECT * FROM sellers;
--Calculate the total revenue and number of orders for each month.
SELECT 
DATE_TRUNC('month',o.order_purchase_timestamp) AS sales_month,
SUM(P.payment_value) AS total_revenue,
COUNT(DISTINCT o.order_id)AS Total_orders
FROM
orders o 
JOIN
order_payments p ON o.order_id = p.order_id
GROUP BY 1
ORDER BY 1;


--Identify the top 5 product categories by total revenue (using the English translation).
SELECT
    T1.product_category_name,
    T1.product_category_name_english,
    ROUND(SUM(T2.price + T2.freight_value), 2) AS TOTAL_REVENUE
FROM
    category_name_translation T1 -- Table Name/Alias check zaroori hai!
JOIN
    products T3 ON T1.product_category_name = T3.product_category_name
JOIN
    order_items T2 ON T2.product_id = T3.product_id
GROUP BY
    -- RULE: SELECT ke saare non-aggregated columns yahan hone chahiye
    T1.product_category_name,
    T1.product_category_name_english
ORDER BY
    TOTAL_REVENUE DESC -- Revenue column se sort karo
LIMIT 5;


--Calculate the average time (in days) it takes for an order to be delivered after the purchase date.

SELECT
    -- 1. EXTRACT(EPOCH) se time difference ko seconds mein badlo,
    -- 2. Phir 86400 (seconds in a day) se divide karke din (days) mein nikalo.
    -- 3. Iska average lo, aur 2 decimal places tak round karo.
    ROUND(
        AVG(
            EXTRACT(EPOCH FROM (order_delivered_customer_date - order_purchase_timestamp))
        ) / 86400,
        2
    ) AS avg_delivery_days
FROM
    orders
WHERE
    order_status = 'delivered' -- Sirf delivered orders ko consider karo
    AND order_delivered_customer_date IS NOT NULL; -- Delivery time available hona chahiye

--Find the top 10 sellers based on average review score, including only sellers with at least 10 orders.
SELECT
    I.seller_id,
    ROUND(AVG(R.review_score), 2) AS avg_score,
    COUNT(DISTINCT I.order_id) AS total_orders
FROM
    order_items I -- Seller ID yahan hai (I)
JOIN
    orders_reviews R ON I.order_id = R.order_id -- Review Score yahan hai (R)
GROUP BY
    I.seller_id
-- Yeh filter zaroori hai: Sirf woh sellers jinke paas 10 ya zyada orders hain
HAVING
    COUNT(DISTINCT I.order_id) >= 10
ORDER BY
    avg_score DESC, -- Pehle score ke hisaab se sort karo
    total_orders DESC -- Score tie hone par orders ke hisaab se sort karo
LIMIT 10;

--List orders that were delivered later than their estimated date and calculate the delay in days.
SELECT
    order_id,
    customer_id,
    ROUND(
        -- Calculation: (Actual Delivery Date - Estimated Date) in seconds / 86400 (seconds in a day)
        EXTRACT(EPOCH FROM (order_delivered_customer_date::timestamp - order_estimated_delivery_date::timestamp))
        / 86400,
        2
    ) AS delay_delivery_days
FROM
    orders
WHERE
    -- Filter: Actual delivery date must be LATER than the estimated date, and not NULL
    order_delivered_customer_date IS NOT NULL
    AND order_delivered_customer_date > order_estimated_delivery_date
ORDER BY
    delay_delivery_days DESC;

--Calculate the total payment value for each payment type and its percentage of the total overall payment value

SELECT
    payment_type,
    ROUND(SUM(payment_value), 2) AS total_payment_value,
    
    -- Calculate percentage using a Window Function to get the overall total
    ROUND(
        (SUM(payment_value) * 100.0) / SUM(SUM(payment_value)) OVER (),
        2
    ) AS percentage_of_total
FROM
    order_payments
GROUP BY
    payment_type
ORDER BY
    total_payment_value DESC;
--Calculate the average time (in hours) it takes for an order to be approved after purchase.

SELECT
	-- Calculation: (Approved Time - Purchase Time) in seconds / 3600 (seconds in an hour)
	ROUND(
		AVG(
			EXTRACT(
				EPOCH
				FROM
					(order_approved_at - order_purchase_timestamp)
			)
		) / 3600,
		2
	) AS avg_approval_time_hours
FROM
	orders
WHERE
	-- Filter for valid records to ensure accurate averaging
	order_approved_at IS NOT NULL
	AND order_purchase_timestamp IS NOT NULL;
	
--Find the unique customer IDs, their cities, and states for all customers who made a purchase in February 2018.

SELECT DISTINCT
    T1.customer_id,
    T2.customer_city,
    T2.customer_state
FROM
    orders T1
JOIN
    customers T2 ON T1.customer_id = T2.customer_id
WHERE
    -- Use DATE_TRUNC to filter all timestamps that fall into February 2018
    DATE_TRUNC('month', T1.order_purchase_timestamp::timestamp) = '2018-02-01'::date;

-- Find the number of unique customers who placed more than one order (Repeat Buyers).

SELECT
    COUNT(customer_id) AS total_repeat_buyers
FROM
    customers -- Is table mein customer_unique_id hai
GROUP BY
    customer_id
HAVING
    -- Count karo ki kitne unique IDs ke saath ek se zyada customer_id associated hain (yaani repeat order)
    COUNT(customer_id) > 1;






