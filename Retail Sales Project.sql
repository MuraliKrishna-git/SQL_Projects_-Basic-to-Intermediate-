DROP DATABASE IF EXISTS sales;
CREATE DATABASE sales;
USE sales;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    signup_date DATE
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    brand VARCHAR(50)
);

CREATE TABLE stores (
    store_id INT PRIMARY KEY,
    location VARCHAR(100),
    region VARCHAR(50)
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    product_id INT,
    store_id INT,
    customer_id INT,
    quantity INT,
    discount DECIMAL(5,2),
    sale_date DATE,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE product_history (
    product_id INT,
    name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    brand VARCHAR(50),
    start_date DATE,
    end_date DATE,
    is_current BOOLEAN,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO customers VALUES
(1, 'Anita', 'Chennai', 'TN', '2022-01-01'),
(2, 'Ravi', 'Bangalore', 'KA', '2022-05-21');

INSERT INTO products VALUES
(101, 'Laptop', 'Electronics', 55000, 'Dell'),
(102, 'Phone', 'Electronics', 30000, 'Samsung');

INSERT INTO stores VALUES
(10, 'Chennai Store', 'South'),
(20, 'Bangalore Store', 'South');

INSERT INTO sales VALUES
(1001, 101, 10, 1, 1, 5.00, '2023-03-15'),
(1002, 102, 20, 2, 2, 0.00, '2023-03-20');

INSERT INTO product_history
VALUES (101, 'Laptop', 'Electronics', 50000, 'Dell', '2022-01-01', '2023-02-28', FALSE);

INSERT INTO product_history
VALUES (101, 'Laptop', 'Electronics', 55000, 'Dell', '2023-03-01', NULL, TRUE);

SELECT s.sale_id, c.name AS customer, p.name AS product, s.sale_date, s.quantity
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN products p ON s.product_id = p.product_id;

SELECT p.name AS product, SUM(s.quantity) AS total_units
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.name;

SELECT
    customer_id,
    sale_id,
    sale_date,
    RANK() OVER (PARTITION BY customer_id ORDER BY sale_date DESC) AS sale_rank
FROM sales;

SELECT
    product_id,
    sale_date,
    SUM(quantity) OVER (PARTITION BY product_id ORDER BY sale_date) AS running_total
FROM sales;

BEGIN;
UPDATE products SET price = 60000 WHERE product_id = 101;
COMMIT;

CREATE INDEX idx_sales_product_date ON sales(product_id, sale_date);
