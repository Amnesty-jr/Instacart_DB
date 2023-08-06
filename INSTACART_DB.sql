-- I want to Import my data into my DB, The data is in denormalized form

CREATE TABLE denormalized_table (
    product_id INT,
    product_name TEXT,
    aisle_id INT,
    department_id BIGINT,
    aisle TEXT,
    order_id BIGINT,
    user_id INT,
    order_dow INT,
    order_hour_of_day INT,
    days_since_prior_order INT,
    department TEXT,
	unit_price NUMERIC(5,2),
	unit_cost NUMERIC(5,2),
	order_date DATE,
	order_status VARCHAR(25),
	quantity INT
);

-- I am importing the denormalized data into my Table

COPY denormalized_table
FROM 'C:\Users\HP\Desktop\Bootcamp\All SQL asss/Instacart_DB.csv'
WITH (FORMAT csv, HEADER True);

-- Trying to view Denormalized Datasets.

SELECT *
FROM denormalized_table
LIMIT 25;

-- Creating Views to inorder to normalize the above Datasets.
--Product View

CREATE VIEW product_view AS SELECT DISTINCT(Product_id), product_name,unit_cost,
											unit_price, aisle_id,department_id
FROM denormalized_table
ORDER BY Product_id;

-- aisle view

CREATE VIEW aisle_view AS SELECT DISTINCT (aisle_id), aisle
FROM denormalized_table
ORDER BY aisle_id;

-- Order View

CREATE VIEW order_view AS SELECT DISTINCT(order_id), user_id, order_dow, 
										  order_hour_of_day, days_since_prior_order,
										  order_date, order_status, quantity, product_id										  
FROM denormalized_table
ORDER BY order_id;

-- Department View

CREATE VIEW Dept_View AS SELECT DISTINCT (department_id), department
FROM denormalized_table
ORDER BY department_id

-- Creating Tables, So as to import our views into it and create a relationships between those tables.

-- Creating aisle_table

CREATE TABLE aisle_table(
			aisle_id INT PRIMARY KEY,
			aisle TEXT
);

--Creating department_table

CREATE TABLE department_table(
			department_id INT PRIMARY KEY,
			department TEXT
);

--Creating product table

CREATE TABLE product_table(
			product_id INT PRIMARY KEY,
			product_name TEXT,
			unit_cost NUMERIC(5,2),
			unit_price NUMERIC(5,2),
			aisle_id INT,
			department_id INT,
	
			FOREIGN KEY(aisle_id) REFERENCES aisle_table(aisle_id),
			FOREIGN KEY(department_id) REFERENCES department_table(department_id)
);

--Creating order_table

CREATE TABLE order_table(
			order_id INT PRIMARY KEY,
			user_id INT,
			order_dow INT,
			order_hour_of_day INT,
			days_since_prior_order INT,
			order_date DATE,
			order_status VARCHAR (25),
			quantity INT,
			product_id INT,
	
			FOREIGN KEY(product_id) REFERENCES product_table(product_id)
);


--Inserting the datasets into the tables created.

--Inserting into aisle_table

INSERT INTO aisle_table(aisle_id, aisle)
SELECT aisle_id, aisle
FROM aisle_view
ORDER BY aisle_id

--Inserting into department_table

INSERT INTO department_table(department_id, department)
SELECT department_id,department
FROM dept_view
ORDER BY department_id

--Inserting into order_table

INSERT INTO order_table(order_id,user_id, order_dow, 
						order_hour_of_day, days_since_prior_order, order_date,
						order_status, quantity, product_id)
SELECT order_id,user_id,order_dow, order_hour_of_day, days_since_prior_order,
	   order_date, order_status, quantity, product_id
FROM order_view
ORDER BY order_id

--Inserting into product_table

INSERT INTO product_table(product_id, product_name, unit_cost, 
						  unit_price, aisle_id, department_id)
SELECT product_id, product_name, unit_cost,
	   unit_price, aisle_id, department_id
FROM product_view
ORDER BY product_id


--After nomalizing the database, we need to answer business questions

--BUSINESS QUESTIONS

-- 1. On which day(s) of the week are condoms mostly sold?

SELECT CASE WHEN o.order_dow = 0 THEN 'Sunday'
			WHEN o.order_dow = 1 THEN 'Monday'
			WHEN o.order_dow = 2 THEN 'Tuesday'
			WHEN o.order_dow = 3 THEN 'Wednesday'
			WHEN o.order_dow = 4 THEN 'Thursday'
			WHEN o.order_dow = 5 THEN 'Friday'
			ELSE 'Saturday'
			END AS Days_of_Week,
		COUNT(*) AS Mostly_sold
FROM order_table o
JOIN product_table pr
USING(product_id)
WHERE pr.product_name ILIKE '%Condoms%'
	  OR pr.product_name ILIKE '%condom%'
GROUP BY Days_of_Week
ORDER BY Mostly_sold DESC;

/* INSIGHTS; Based on the data, the days condoms are mostly sold is on monday with a summation of 122 on monday,
			 this maybe as a result of the weekend that just ended & people try to restock after their 
			 working hours for the following weekend. */
			 
			 
-- 2. At what time of the day is condom mostly sold.

SELECT order_hour_of_day,
	   COUNT(*) AS Mostly_sold
FROM order_table o
JOIN product_table pr
USING(product_id)
WHERE pr.product_name ILIKE '%Condoms%'
	  OR pr.product_name ILIKE '%condom%'
GROUP BY order_hour_of_day
ORDER BY Mostly_sold DESC
LIMIT 1;

/* INSIGHTS: It was observed that condoms were mostly sold in the 4pm in the evening,
			 this is the time people leave their workplace for their respective homes. */


-- 3. Which aisle/s can I find all Non-Alcholic drinks?

SELECT a.aisle,
	   string_agg(product_name, ', ') AS product_name,
	   COUNT(*) AS num_non_Alcoholic
FROM aisle_table a
JOIN product_table pr
ON a.aisle_id = pr.aisle_id
WHERE pr.product_name ILIKE '%Non Alcoholic'
	  OR pr.product_name ILIKE '%No Alcohol%'
	  OR pr.product_name ILIKE '%Non-Alcoholic%'
	  OR pr.product_name ILIKE '%No-Alcohol'
GROUP BY a.aisle
ORDER BY 3 DESC;

/*INSIGHTS: The aisle with the names frozen juice, beers coolers, cream, milk, red wines,
			and soft drinks is where non-alcoholic beverages can be found. */


--4 What is the top-selling product by revenue, and how much revenue have they generated?

--To get revenue; revenue = unit_price * quantity

SELECT pr.product_name,
	   '$' || (SUM(pr.unit_price * o.quantity)) AS Total_Revenue
FROM product_table pr
JOIN order_table o
USING(product_id)
GROUP BY 1
ORDER BY (SUM(pr.unit_price * o.quantity)) DESC
LIMIT 1;

/* INSIGHTS: According to the money it generated, the best-selling item was "Apple Cinnamon Cheerios Cereal,"
			 which brought in a total of $1555.00. */


--5. which department has the highest average spend per customer?

SELECT department,
	   ROUND(AVG(unit_price),2) AS average
FROM department_table d
JOIN product_table pr
ON d.department_id = pr.product_id
JOIN order_table o
ON o.order_id = pr.product_id
GROUP BY 1
ORDER BY 2 DESC;

/* INSIGHTS: International has an average spend per customer of $37.00, which is the highest department. */


--6. Which product generated more profit?

SELECT pr.product_name,
	   '$' || SUM((pr.unit_price - pr.unit_cost) * o.quantity) AS total_profit
FROM product_table AS pr
JOIN order_table AS o
USING(product_id)
GROUP BY pr.product_name, (pr.unit_price - pr.unit_cost) * o.quantity
ORDER BY SUM((pr.unit_price - pr.unit_cost) * o.quantity) DESC

/* INSIGHTS: Nesquik Double Chocolate, which had a total profit of $573.30, brought in more money. */


---7 What are the 3 aisles with the most orders, and which departments do these orders belong to

SELECT a.aisle,
	   dpt.department,
	   COUNT(order_id) AS Most_orders
FROM aisle_table a
JOIN product_table pr
ON a.aisle_id = pr.aisle_id
JOIN order_table o
ON pr.product_id = o.product_id
JOIN department_table dpt
ON dpt.department_id = pr.department_id
GROUP BY a.aisle,dpt.department
ORDER BY Most_orders DESC
LIMIT 3;

/* INSIGHTS: The aisles with the most orders are missing, candy chocolate, & ice cream ice asile */


--8. Which 3 users generated the highest revenue and how many aisles did they order from?

SELECT o.user_id,
	   a.aisle,
	   (SUM(pr.unit_price * o.quantity)) AS total_revenue
FROM order_table o
JOIN product_table pr
ON o.product_id = pr.product_id
JOIN aisle_table a
ON a.aisle_id = pr.aisle_id
GROUP BY o.user_id,a.aisle
ORDER BY (SUM(pr.unit_price * o.quantity)) DESC
LIMIT 3;

/* INSGHTS: The customers who bought from the candy chocolate aisles and the hair care
			aisles correspondingly brought in the most money for the business. */
			
			
--9. What is the average number of orders placed by days of the week?
WITH Aver AS (
			  SELECT COUNT(*) AS  no_of_orders,
			  order_dow
			  FROM order_table
			  GROUP BY 2
	)
	
SELECT CASE WHEN order_dow = 0 THEN 'Sunday'
		    WHEN order_dow = 1 THEN 'Monday'
			WHEN order_dow = 2 THEN 'Tuesday'
			WHEN order_dow = 3 THEN 'Wednesday'
			WHEN order_dow = 4 THEN 'Thursday'
			WHEN order_dow = 5 THEN 'Friday'
			ELSE 'Saturday'
			END AS Days_of_Week,
			ROUND(AVG(no_of_orders),2) AS Avg_orders
FROM Aver
GROUP BY Days_of_week
ORDER BY ROUND(AVG(no_of_orders),2) DESC

/* INSIGHTS: Due to Sunday being a weekend day and the fact that most individuals try to equip their 
			 homes for the coming week, Sunday has the highest average amount of orders placed by day 
			 of the week (183939.00). */
			 

--10. WHAT IS THE HOUR OF THE DAY WITH THE HIGHEST NUMBER OF ORDERS?

SELECT order_hour_of_day, 
		COUNT(*) as Total_orders
FROM order_table
GROUP BY order_hour_of_day
ORDER BY Total_orders DESC
LIMIT 1

/* INSIGHTS: With "88228" total orders generated by 10 am, this is the busiest moment of the day. */


