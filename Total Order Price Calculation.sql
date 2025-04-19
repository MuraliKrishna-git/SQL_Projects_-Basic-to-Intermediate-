DROP DATABASE IF EXISTS Order_Price;
CREATE DATABASE Order_Price;
USE Order_Price;

CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    price_per_unit DECIMAL(10,2)
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    product_id INT,
    quantity INT,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

DELIMITER //

CREATE FUNCTION CalculateTotalPrice(p_id INT) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);

    SELECT SUM(P.price_per_unit * O.quantity)
    INTO total
    FROM Orders O
    JOIN Products P ON O.product_id = P.product_id
    WHERE O.order_id = p_id;

    RETURN total;
END //

DELIMITER ;

SELECT CalculateTotalPrice(101);
