# 🛒 Olist E-commerce Performance and Logistics Analysis (PostgreSQL/SQL)

## 🌟 Project Overview

This project provides a comprehensive data analysis of the Olist Brazilian E-commerce dataset, focusing on key business metrics across revenue, customer behavior, and logistics performance.

The analysis is performed entirely using **Advanced PostgreSQL SQL**, demonstrating expertise in complex joins, window functions, and temporal data manipulation.

## 🚀 Key Analysis & Insights

The SQL queries in this repository are grouped to deliver actionable business intelligence:

### 1. Revenue & Payment Analysis
* **Monthly Sales Tracking:** Calculate total revenue and order volume over time (`DATE_TRUNC`).
* **Top Categories:** Identify the top 5 product categories by total revenue (requires three-way joins and translation).
* **Payment Breakdown:** Calculate the total value and **percentage of overall revenue** for each payment type using **Window Functions** (`SUM() OVER ()`).

### 2. Logistics & Time Performance
* **Delivery Latency:** Calculated the average time (in days) required for orders to reach the customer.
* **Approval Speed:** Determined the average time (in hours) an order takes to be approved after purchase using **Epoch Time Extraction**.
* **Delay Identification:** Identified and quantified all orders that were delivered later than their estimated date, calculating the precise delay in days.

### 3. Seller & Customer Performance
* **Seller Ranking:** Ranked the top 10 sellers based on average review score, including a filter to ensure only high-volume sellers (minimum 10 orders) are considered (`HAVING` clause).
* **Customer Loyalty (Repeat Buyers):** Identified the total number of unique customers who placed more than one order.
* **Customer Geography:** Found unique customers and their locations for a specific purchasing cohort (e.g., February 2018).

---

## 🛠️ Technical Stack

* **Database:** PostgreSQL (SQL)
* **Data Manipulation:** Advanced JOINs, Aggregation (`GROUP BY`), Window Functions (`SUM() OVER ()`), and complex Temporal Functions (`DATE_TRUNC`, `EXTRACT(EPOCH)`).
* **Execution & Reporting (Recommended):** Python / Pandas (for executing queries and generating visualizations).

---

## 🏗️ Database Setup & Schema

The project is built on 9 separate tables. The full schema is defined in the `CREATE TABLE` statements within the project files.

### Schema Highlights:

| Table | Primary Key (PK) | Key Columns |
| :--- | :--- | :--- |
| `orders` | `order_id` | `order_purchase_timestamp`, `order_approved_at`, `order_delivered_customer_date` |
| `order_items` | `(order_id, order_item_id)` | `product_id`, `seller_id`, `price`, `freight_value` |
| `customers` | `customer_id` | `customer_unique_id`, `customer_state` |
| `products` | `product_id` | `product_category_name` |

### How to Run the SQL:

1.  **Setup Tables:** Run the `CREATE TABLE` statements found in the SQL file against your PostgreSQL database.
2.  **Load Data:** Use the PostgreSQL `\copy` command to import the data from the respective CSV files.
    ```bash
    # Example for loading data
    \copy customers FROM 'olist_customers_dataset.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
    # Repeat for all 9 tables.
    ```
3.  **Execute Queries:** Run the analytical queries to extract the required metrics and insights.

---

## ⏭️ Future Enhancements

To take this project to the next level:

1.  **Data Integrity:** Implement **Foreign Key (FK) constraints** in the `CREATE TABLE` statements to enforce data relationships.
2.  **Geospatial Analysis:** Utilize the **`geolocation`** table to calculate actual shipping distances and correlate distance with freight cost and delivery speed.
3.  **Visualization:** Integrate a **Python/Jupyter Notebook** to visualize the time series and top category results, transforming the raw data into an easily digestible report.
