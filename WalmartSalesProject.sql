-- Name: Singh Azorawar
-- DOB: 02/01/2001
-- Date: 06/07/2023
-- Project Name: Walmart Sales Data Analysis

CREATE TABLE IF NOT EXISTS sales(
          invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
          branch VARCHAR(5) NOT NULL,
          city VARCHAR(30) NOT NULL,
          customer_type VARCHAR(30) NOT NULL,
          gender VARCHAR(20) NOT NULL,
          product_line VARCHAR(100) NOT NULL,
          unit_price DECIMAL(10,2) NOT NULL,
          quantity INT NOT NULL,
          VAT FLOAT(6,4) NOT NULL,
          total DECIMAL(12,4) NOT NULL,
          date DATETIME NOT NULL,
          time TIME NOT NULL,
          payment_method VARCHAR(15) NOT NULL,
          cogs DECIMAL(10,2) NOT NULL,
          gross_margin_pct FLOAT(11,9),
          gross_income DECIMAL(12,4) NOT NULL,
          rating FLOAT(2,1)
          
);




-- ----------------------------- 1) Data Wrangling -----------------------------------------------------
-- When creating the 'sales' table i used 'NOT NULL' in every table query. 
-- So, there wont be any null values in the table.

-- ------------------------------------------------------------------------------------------------------
-- ------------------------------ Feature Engineering ---------------------------------------------------
 
-- Add a new column named time_of_day to give insight of sales in the Morning, Afternoon and Evening. 
-- This will help answer the question on which part of the day most sales are made.

-- Answer:  
SELECT time,
( CASE 
      WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN "Morning"
      WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN "Afternoon"
     ELSE "Evening"
      END 
) AS time_of_day
FROM sales;

ALTER TABLE sales 
ADD COLUMN time_of_day VARCHAR(20);
 
UPDATE sales
SET time_of_day = (
CASE 
    WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
    WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
    ELSE "Evening"
    
END
);


-- Add a new column named day_name that contains the extracted days of the week on which 
-- the given transaction took place (Mon, Tue, Wed, Thur, Fri). 
-- This will help answer the question on which week of the day each branch is busiest.

-- Answer: 
-- Here i will be using the function called 'DAYNAME'
SELECT date,
  DAYNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = (DAYNAME(date));

-- Add a new column named month_name that contains the extracted months of the year on which the given 
-- transaction took place (Jan, Feb, Mar). 
-- Help determine which month of the year has the most sales and profit.

-- Answer:
-- Here i am using the function 'MONTHNAME' in order to get the name of each month
SELECT date,
MONTHNAME(date) AS month_name
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(15);

UPDATE sales
SET month_name = MONTHNAME(date);


-- ------------------------------------------------------------------------------------------------------
--                                 Business Questions
-- ------------------------------------------------------------------------------------------------------

-- ----------------------------------- Generic ----------------------------------------------------------

-- How many unique cities does the data have?
-- Answer:  Here i will be using DISTINCT because it will remove all the Duplicates!
-- We have 3 unique cities
SELECT  DISTINCT city
FROM sales;

-- In which city is each branch?
-- Answer: 
SELECT DISTINCT branch, city
FROM sales;


-- ----------------------------------- Product ----------------------------------------------------------

-- How many unique product lines does the data have?
-- Answer: There are 6 unique product lines in our sales data
SELECT COUNT(DISTINCT product_line)
FROM sales;

-- What is the most common payment method?
-- Answer: 
SELECT  payment_method, COUNT(payment_method) AS most_common
FROM sales
GROUP BY payment_method;

-- What is the most selling product line?
-- Answer:
SELECT product_line, COUNT(product_line) AS most_selling
FROM sales
GROUP BY product_line
ORDER BY  most_selling DESC;

-- What is the total revenue by month?
-- Answer:
SELECT month_name, SUM(total) AS month_rev
FROM sales
GROUP BY month_name
ORDER BY month_rev DESC;

-- What month had the largest COGS?
-- Answer:
SELECT month_name, SUM(cogs) AS largest_cogs
FROM sales
GROUP BY month_name
ORDER BY largest_cogs DESC;

-- What product line had the largest revenue?
-- Answer:
SELECT product_line, SUM(total) AS largest_rev
FROM sales
GROUP BY product_line
ORDER BY largest_rev DESC;

-- What is the city with the largest revenue?
-- Answer:
SELECT city, SUM(total) AS largest_rev
FROM sales
GROUP BY city
ORDER BY largest_rev DESC;

-- What product line had the largest VAT?
-- Answer: 
SELECT product_line, AVG(vat) AS largest_vat
FROM sales
GROUP BY product_line
ORDER BY largest_vat DESC;

-- Fetch each product line and add a column to those product 
-- line showing "Good", "Bad". 
-- Good if its greater than average sales
-- Answer:
SELECT AVG(quantity) AS avg_quantity
FROM sales;

SELECT product_line,
 (
   CASE
       WHEN AVG(quantity) > 5.5 THEN "Good"
       ELSE "Bad"
   END 
) AS Rating
FROM sales
GROUP BY product_line;
    

-- Which branch sold more products than average product sold?
-- Answer:
SELECT branch, SUM(quantity) AS qty
FROM sales
GROUP BY branch
HAVING qty > (SELECT AVG(quantity) FROM sales);
 
-- What is the most common product line by gender?
-- Answer:
SELECT gender, product_line, COUNT(gender) AS total_gender
FROM sales
GROUP BY gender, product_line
ORDER BY total_gender DESC;
 
-- What is the average rating of each product line?
-- Answer: 
SELECT product_line, ROUND(AVG(rating),2) AS avg_rating
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;


-- ----------------------------------- Sales ----------------------------------------------------------
-- Number of sales made in each time of the day per weekday
-- Answer:
SELECT time_of_day, COUNT(*) AS total_sales
FROM sales
WHERE day_name = "Monday"
GROUP BY time_of_day
ORDER BY total_sales ASC;

-- Which of the customer types brings the most revenue?
-- Answer:
SELECT customer_type, ROUND(SUM(total),2) AS revenue
FROM sales
GROUP BY customer_type
ORDER BY revenue DESC;

-- Which city has the largest tax percent/ VAT (Value Added Tax)?
-- Answer:
SELECT city, AVG(VAT) AS largest_tax
FROM sales
GROUP BY city
ORDER BY largest_tax DESC;

-- Which customer type pays the most in VAT?
-- Answer:
SELECT customer_type, ROUND(AVG(VAT),3) AS most_vat
FROM sales
GROUP BY customer_type
ORDER BY most_vat DESC;


-- ----------------------------------- Customer ----------------------------------------------------------
-- How many unique customer types does the data have?
-- Answer:
SELECT DISTINCT customer_type
FROM sales;

-- How many unique payment methods does the data have?
-- Answer:
SELECT DISTINCT payment_method
FROM sales;


-- What is the most common customer type?
-- Answer:
SELECT customer_type, COUNT(customer_type) AS unique_cust
FROM sales
GROUP BY customer_type
ORDER BY unique_cust DESC;

-- Which customer type buys the most?
-- Answer:
SELECT customer_type, COUNT(*) AS total_cust
FROM sales
GROUP BY customer_type 
ORDER BY total_cust DESC;

-- What is the gender of most of the customers?
-- Answer:
 SELECT gender, COUNT(*) AS gender
 FROM sales
 GROUP BY gender
 ORDER BY gender DESC;
 
-- What is the gender distribution per branch?
-- Answer: 
SELECT gender, COUNT(*) AS gender
FROM sales
WHERE branch = "A"
GROUP BY gender
ORDER BY gender DESC;

-- Which time of the day do customers give most ratings?
-- Answer:
SELECT time_of_day, ROUND(AVG(rating),2) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Which time of the day do customers give most ratings per branch?
-- Answer:
SELECT time_of_day, ROUND(AVG(rating),2) AS sum_rating
FROM sales
WHERE branch = "B"
GROUP BY time_of_day
ORDER BY sum_rating DESC;
 
-- Which day of the week has the best avg ratings?
-- Answer:
SELECT day_name, ROUND(AVG(rating),1) AS avg_rating
FROM sales
GROUP BY day_name
ORDER BY avg_rating DESC;

-- Which day of the week has the best average ratings per branch?
-- Answer:
SELECT day_name, ROUND(AVG(rating),1) AS avg_rating
FROM sales
WHERE branch = "B"
GROUP BY day_name
ORDER BY avg_rating DESC;

