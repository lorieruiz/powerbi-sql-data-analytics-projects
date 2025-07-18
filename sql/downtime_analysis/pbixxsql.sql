CREATE DATABASE	manufacturing_db;  -- creates the database
USE manufacturing_db;

SELECT 
    *
FROM
    line_downtime
    WHERE Value is not NULL;    -- sample of how to filter table with null

CREATE TABLE line_downtime (   --  sample how to create a table
    Batch INT,
    Attribute INT,
    Value INT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dbManufacturing/line_downtime.csv'   -- sample how to load the file
	INTO TABLE line_downtime
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES terminated by '\r\n'
    IGNORE 1 ROWS
    (Batch, Attribute, Value);
    
    
CREATE TABLE line_productivity_staging (
    Date_raw VARCHAR(20),
    Product VARCHAR(20),
    Batch INT,
    Operator VARCHAR(50),
    StartTime_raw VARCHAR(20),
    EndTime_raw VARCHAR(20)
);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dbManufacturing/line_productivity.csv'   -- sample how to load and do staging to handle inconsistent data(e.g date/time)
	INTO TABLE line_productivity_staging
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES terminated by '\r\n'
    IGNORE 1 ROWS;

CREATE TABLE line_productivity (   -- creates the final db for Downtime Logs
	LogDate Date,
    Product VARCHAR(20),
    Batch INT,
    Operator varchar(50),
    StartTime TIME,
    EndTime TIME
);

Insert Into line_productivity (LogDate, Product, Batch, Operator, StartTime, EndTime)
 select
	str_to_date(Date_raw, '%m/%d/%Y'),   -- delimiter depends on how the string of date was stored! (',','/','-', etc...)
    Product,
    Batch,
    Operator,
    str_to_date(StartTime_raw, '%H:%i:%s'),
    str_to_date(EndTime_raw, '%H:%i:%s')
from
	line_productivity_staging;

SELECT
	*
FROM
	line_productivity;
