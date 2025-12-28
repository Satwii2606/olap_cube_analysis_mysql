-- ================================
-- OLAP Cube Analysis with MySQL
-- Database: olap
-- ================================

USE olap_coffee_sales;

-- ================================
-- FACT TABLE
-- ================================
DROP TABLE IF EXISTS fact_sales;

CREATE TABLE fact_sales AS
SELECT
    transaction_id,
    transaction_date,
    store_id,
    product_id,
    CAST(transaction_qty AS DECIMAL(10,2)) AS transaction_qty,
    CAST(unit_price AS DECIMAL(10,2)) AS unit_price,
    CAST(transaction_qty AS DECIMAL(10,2)) 
      * CAST(unit_price AS DECIMAL(10,2)) AS total_bill
FROM coffee_sales_raw;

-- ================================
-- DIMENSION TABLES
-- ================================

-- Product Dimension
DROP TABLE IF EXISTS dim_product;
CREATE TABLE dim_product AS
SELECT DISTINCT
    product_id,
    product_category,
    product_type,
    product_detail,
    Size
FROM coffee_sales_raw;

-- Store Dimension
DROP TABLE IF EXISTS dim_store;
CREATE TABLE dim_store AS
SELECT DISTINCT
    store_id,
    store_location
FROM coffee_sales_raw;

-- Date Dimension
DROP TABLE IF EXISTS dim_date;
CREATE TABLE dim_date AS
SELECT DISTINCT
    transaction_date,
    `Day Name`,
    `Day of Week`,
    `Month Name`,
    Month
FROM coffee_sales_raw;

-- ================================
-- AGGREGATE TABLES (OLAP CUBE)
-- ================================

-- Sales by Day
DROP TABLE IF EXISTS agg_sales_by_day;
CREATE TABLE agg_sales_by_day AS
SELECT
    transaction_date,
    SUM(total_bill) AS total_sales,
    SUM(transaction_qty) AS total_quantity
FROM fact_sales
GROUP BY transaction_date;

-- Sales by Product
DROP TABLE IF EXISTS agg_sales_by_product;
CREATE TABLE agg_sales_by_product AS
SELECT
    product_id,
    SUM(total_bill) AS total_sales,
    SUM(transaction_qty) AS total_quantity
FROM fact_sales
GROUP BY product_id;

-- Sales by Store
DROP TABLE IF EXISTS agg_sales_by_store;
CREATE TABLE agg_sales_by_store AS
SELECT
    store_id,
    SUM(total_bill) AS total_sales,
    SUM(transaction_qty) AS total_quantity
FROM fact_sales
GROUP BY store_id;

-- ================================
-- BENCHMARK QUERIES
-- ================================

-- WITHOUT aggregates
SELECT transaction_date, SUM(total_bill)
FROM fact_sales
GROUP BY transaction_date;

-- WITH aggregates
SELECT * FROM agg_sales_by_day;

-- ================================
-- SLICE & DICE
-- ================================

-- Slice
SELECT * FROM agg_sales_by_product WHERE product_id = 45;

-- Dice
SELECT
    transaction_date,
    product_id,
    store_id,
    SUM(total_bill) AS sales
FROM fact_sales
GROUP BY transaction_date, product_id, store_id;
