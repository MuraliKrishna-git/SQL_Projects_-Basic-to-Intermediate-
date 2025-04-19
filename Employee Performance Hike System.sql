DROP DATABASE IF EXISTS Employee_Performance;
CREATE DATABASE Employee_Performance;
USE Employee_Performance;

CREATE TABLE Employees (
    emp_id INT PRIMARY KEY,
    name VARCHAR(100),
    salary DECIMAL(10,2),
    performance_rating INT
);

DELIMITER //

CREATE PROCEDURE GiveBonus()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE eid INT;
    DECLARE cur CURSOR FOR SELECT emp_id FROM Employees WHERE performance_rating > 8;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO eid;
        IF done THEN
            LEAVE read_loop;
        END IF;

        UPDATE Employees
        SET salary = salary * 1.10
        WHERE emp_id = eid;
    END LOOP;

    CLOSE cur;
END //

DELIMITER ;

CALL GiveBonus();
