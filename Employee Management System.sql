-- Create Database
DROP DATABASE IF EXISTS EmployeeDB;
CREATE DATABASE EmployeeDB;
USE EmployeeDB;

-- Create Tables
CREATE TABLE Departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(50) NOT NULL,
    location VARCHAR(50)
);

CREATE TABLE Employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    salary DECIMAL(10,2),
    hire_date DATE,
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
);

CREATE TABLE audit_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT,
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert Sample Data
INSERT INTO Departments (department_name, location) VALUES
('HR', 'New York'),
('IT', 'San Francisco'),
('Sales', 'Chicago');

INSERT INTO Employees (first_name, last_name, salary, hire_date, department_id) VALUES
('John', 'Doe', 60000, '2020-01-15', 1),
('Jane', 'Smith', 75000, '2019-05-20', 2),
('Bob', 'Johnson', 55000, '2021-11-01', 3);

-- ====================
-- Stored Procedures
-- ====================

-- 1. Add New Employee
DELIMITER //
CREATE PROCEDURE AddEmployee(
    IN p_first_name VARCHAR(50),
    IN p_last_name VARCHAR(50),
    IN p_salary DECIMAL(10,2),
    IN p_hire_date DATE,
    IN p_department_id INT
)
BEGIN
    INSERT INTO Employees (first_name, last_name, salary, hire_date, department_id)
    VALUES (p_first_name, p_last_name, p_salary, p_hire_date, p_department_id);
END //
DELIMITER ;

-- 2. Update Salary by Percentage (Using Cursor)
DELIMITER //
CREATE PROCEDURE UpdateDepartmentSalaries(
    IN dept_id INT,
    IN raise_percent DECIMAL(5,2)
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE emp_id INT;
    DECLARE cur CURSOR FOR 
        SELECT employee_id FROM Employees WHERE department_id = dept_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO emp_id;
        IF done THEN
            LEAVE read_loop;
        END IF;
        UPDATE Employees
        SET salary = salary * (1 + raise_percent / 100)
        WHERE employee_id = emp_id;
    END LOOP;

    CLOSE cur;
END //
DELIMITER ;

-- 3. Get Department Statistics
DELIMITER //
CREATE PROCEDURE GetDepartmentStats(
    IN dept_id INT,
    OUT total_employees INT,
    OUT avg_salary DECIMAL(10,2),
    OUT total_salary DECIMAL(10,2)
)
BEGIN
    SELECT COUNT(*), AVG(salary), SUM(salary)
    INTO total_employees, avg_salary, total_salary
    FROM Employees
    WHERE department_id = dept_id;
END //
DELIMITER ;

-- ====================
-- Functions
-- ====================

-- 1. Calculate Total Compensation
DELIMITER //
CREATE FUNCTION CalculateTotalCompensation(
    base_salary DECIMAL(10,2),
    bonus DECIMAL(10,2)
) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN base_salary + bonus;
END //
DELIMITER ;

-- 2. Format Employee Name
DELIMITER //
CREATE FUNCTION FormatEmployeeName(
    first_name VARCHAR(50),
    last_name VARCHAR(50)
)
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    RETURN CONCAT(UPPER(SUBSTRING(first_name, 1, 1)), LOWER(SUBSTRING(first_name, 2)), 
           ' ', 
           UPPER(SUBSTRING(last_name, 1, 1)), LOWER(SUBSTRING(last_name, 2)));
END //
DELIMITER ;

-- ====================
-- Triggers
-- ====================

-- Salary Change Audit Trigger
DELIMITER //
CREATE TRIGGER BeforeSalaryUpdate
BEFORE UPDATE ON Employees
FOR EACH ROW
BEGIN
    IF OLD.salary <> NEW.salary THEN
        INSERT INTO audit_log (employee_id, old_salary, new_salary)
        VALUES (OLD.employee_id, OLD.salary, NEW.salary);
    END IF;
END //
DELIMITER ;

-- ====================
-- Example Usage
-- ====================

-- Add new employee
CALL AddEmployee('Alice', 'Brown', 65000, '2024-01-01', 2);

-- Give 10% raise to IT department
CALL UpdateDepartmentSalaries(2, 10.00);

-- Get department statistics
CALL GetDepartmentStats(2, @total_emp, @avg_sal, @total_sal);
SELECT @total_emp AS TotalEmployees, @avg_sal AS AverageSalary, @total_sal AS TotalSalary;

-- Use functions in queries
SELECT 
    FormatEmployeeName(first_name, last_name) AS FormattedName,
    CalculateTotalCompensation(salary, 5000) AS TotalCompensation
FROM Employees;

-- View audit log
SELECT * FROM audit_log;
