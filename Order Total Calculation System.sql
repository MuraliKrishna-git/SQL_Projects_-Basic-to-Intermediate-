DROP DATABASE IF EXISTS ORDERS;
CREATE DATABASE ORDERS;
USE ORDERS;

-- Create Tables
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(10,2)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    order_date DATE
);

CREATE TABLE order_items (
    item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Sample Data
INSERT INTO products VALUES (1, 'Laptop', 50000), (2, 'Mouse', 500), (3, 'Keyboard', 1000);
INSERT INTO orders VALUES (101, 'Alice', '2024-04-17');
INSERT INTO order_items VALUES (1, 101, 1, 1), (2, 101, 2, 2);

-- Stored Procedure
DELIMITER //

CREATE PROCEDURE CalculateOrderTotal(IN order_id INT, OUT total DECIMAL(10,2))
BEGIN
    SELECT SUM(oi.quantity * p.price) INTO total
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    WHERE oi.order_id = order_id;
END //

DELIMITER ;

-- Example Call
CALL CalculateOrderTotal(101, @total);
SELECT @total AS total_amount;
