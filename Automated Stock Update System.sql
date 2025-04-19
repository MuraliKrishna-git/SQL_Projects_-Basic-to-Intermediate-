DROP DATABASE IF EXISTS Stock;
CREATE DATABASE Stock;
USE Stock;

CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    stock_quantity INT
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    product_id INT,
    quantity_ordered INT,
    order_date DATE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

DELIMITER //

CREATE PROCEDURE UpdateStock(IN p_product_id INT, IN p_qty INT)
BEGIN
    DECLARE current_stock INT;

    SELECT stock_quantity INTO current_stock FROM Products WHERE product_id = p_product_id;

    IF current_stock >= p_qty THEN
        UPDATE Products
        SET stock_quantity = stock_quantity - p_qty
        WHERE product_id = p_product_id;

        INSERT INTO Orders(product_id, quantity_ordered, order_date)
        VALUES (p_product_id, p_qty, CURDATE());
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Not enough stock!';
    END IF;
END //

DELIMITER ;

CALL UpdateStock(1, 5);
