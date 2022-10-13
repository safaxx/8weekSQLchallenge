CREATE DATABASE pizza_runner;
USE pizza_runner;

CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');
DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" DATETIME
);
INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');
DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(20),
  "distance" VARCHAR(7),
  "duration" VARCHAR(15),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');

DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');

------------------------------------------------------------------------------------------------------
/* Data cleaning and replacing NULL values with ''.
Creating a temp table FOR customer_orders 
(SELECT INTO statement is one of the easy ways to create a new table and 
then copy the source table data into this newly created table) */
DROP TABLE IF EXISTS #TEMP_customer_orders;
SELECT customer_id, order_id, pizza_id, 
CASE 
   WHEN exclusions IS null or exclusions LIKE 'null' THEN ' ' 
   ELSE exclusions END AS exculsions, 
CASE   
   WHEN extras IS NULL or extras LIKE 'NULL' THEN ' ' 
   ELSE extras END AS extras, 
   order_time
INTO #TEMP_customer_orders
FROM customer_orders; 

SELECT * FROM #TEMP_customer_orders;
----------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS #TEMP_runner_orders;
SELECT order_id, runner_id, 
CASE
   WHEN pickup_time IS NULL or pickup_time LIKE 'null' THEN ' ' ELSE pickup_time END AS pickup_time,
CASE
   WHEN distance IS NULL or distance LIKE 'null' THEN ' ' 
   WHEN distance LIKE '%km' THEN TRIM('km' from distance)
   ELSE distance END AS distance,
CASE
   WHEN duration IS NULL or duration LIKE 'null' THEN ' '
   WHEN duration LIKE '%minutes' OR duration LIKE '%mins' OR duration LIKE '%minute' THEN TRIM('minutes' from duration)
   ELSE duration END AS duration,
CASE 
   WHEN cancellation IS NULL or cancellation LIKE 'null' THEN ' '
   ELSE cancellation 
   END AS cancellation
INTO #TEMP_runner_orders
FROM runner_orders;
SELECT * FROM #TEMP_runner_orders

-- CORRECTING DATA TYPES
ALTER TABLE #TEMP_runner_orders
ALTER COLUMN pickup_time DATETIME;

ALTER TABLE #TEMP_runner_orders
ALTER COLUMN duration INT;

ALTER TABLE #TEMP_runner_orders
ALTER COLUMN distance FLOAT;
-------------------------------------------------------------------------------------------------------------
SELECT * FROM #TEMP_customer_orders
SELECT * FROM #TEMP_runner_orders
--PIZZA METRICS 
---Q1 How many pizzas were ordered?
SELECT COUNT(pizza_id) AS pizza_ordered FROM #TEMP_customer_orders

--- Q2 How many unique customer orders were made?
SELECT COUNT(DISTINCT(order_id)) as unique_orders FROM #TEMP_customer_orders;

--- Q3 How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(runner_id) as orders_delivered 
FROM #TEMP_runner_orders
WHERE cancellation = ' '
GROUP BY runner_id;

--- Q4 How many of each type of pizza was delivered?
WITH pizza_del_cte AS (SELECT c.pizza_id, COUNT(c.pizza_id) pizza_delivered 
FROM #TEMP_customer_orders AS c JOIN #TEMP_runner_orders as r ON r.order_id = c.order_id
WHERE cancellation=' '
GROUP BY c.pizza_id)
SELECT  p.pizza_name,pizza_del_cte.pizza_delivered 
FROM pizza_del_cte JOIN pizza_names as p ON pizza_del_cte.pizza_id = p.pizza_id;

--- Q5 How many Vegetarian and Meatlovers were ordered by each customer?
WITH order_cte AS (SELECT customer_id, pizza_id, COUNT(pizza_id) AS order_count
FROM #TEMP_customer_orders
GROUP BY customer_id, pizza_id
)
SELECT o.customer_id, p.pizza_name, o.order_count 
FROM order_cte AS o JOIN pizza_names as p ON p.pizza_id = o.pizza_id
ORDER BY o.customer_id

---Q6 What was the maximum number of pizzas delivered in a single order?
select top(1) c.order_id, count(c.order_id) as max_pizza_delivered 
from #TEMP_customer_orders as c join #TEMP_runner_orders as r on c.order_id = r.order_id
where r.cancellation = ' '
group by c.order_id
order by max_pizza_delivered desc;

---Q7 For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
/* no changes - null 
atleast 1 change -OR */

select count(order_id) as pizza_no_change
from #TEMP_customer_orders
where exculsions = ' ' and extras = ' ';


---Q8 How many pizzas were delivered that had both exclusions and extras?
select count(c.order_id) as both_changes
from #TEMP_customer_orders as c join #TEMP_runner_orders as r on r.order_id = c.order_id 
where exculsions != ' ' and extras != ' ' 
and cancellation = ' '
group by c.order_id;

---Q9 What was the total volume of pizzas ordered for each hour of the day?
select datepart(hour, order_time) as hour_of_the_day, count(order_id) as pizza_count
from #TEMP_customer_orders
group by datepart(hour, order_time);

---Q10. What was the volume of orders for each day of the week?
select format(dateadd(day, 4, order_time), 'dddd') as day_of_week, count(order_id)as pizza_count
from #TEMP_customer_orders
group by format(dateadd(day, 4, order_time), 'dddd')

/* RUNNER AND CUSTOMER EXPERIENCE 
Q1 - How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01) */

select * from #TEMP_runner_orders;
select DATEPART(week, registration_date) as registration_week, count(runner_id) as runners_signup
from runners
group by DATEPART(week, registration_date);

--- Q2 What was the average time in minutes it took 
---    for each runner to arrive at the Pizza Runner HQ to pickup the order?

with time_taken_cte as 
(
select c.order_id, c.order_time, r.pickup_time, datediff(MINUTE, c.order_time, r.pickup_time) as time_taken
from #TEMP_customer_orders as c join #TEMP_runner_orders as r 
on c.order_id = r.order_id
where cancellation = ' '
group by c.order_id, c.order_time, r.pickup_time)
select avg(time_taken) as avg_time from time_taken_cte;

--- Q3 Is there any relationship between the number of pizzas and how long the order takes to prepare? 
with pizza_order_cte as 
(select customer_id, count(c.order_id) as pizzas_ordered, datediff(MINUTE, c.order_time, r.pickup_time) as time_taken
from #TEMP_customer_orders as c join #TEMP_runner_orders as r 
on c.order_id = r.order_id
where cancellation = ' '
group by customer_id, c.order_time, r.pickup_time)
select pizzas_ordered, avg(time_taken) as avg_time_taken from pizza_order_cte
group by pizzas_ordered;

--- Q4 what was the avg distance travelled for each customer?
select c.customer_id, avg(r.distance) as avg_dist 
from #TEMP_customer_orders as c join #TEMP_runner_orders as r 
on c.order_id = r.order_id
where cancellation = ' ' 
group by customer_id;

--- Q5 what was the difference in duration between the longest and the shortest delivery time?
select (max(duration) - min(duration)) as diff_delivery
from #TEMP_runner_orders
where duration <> 0;

--- Q6 what was the average speed for each runner for each delivery and do you notice any trends
select runner_id, round(distance/duration * 60, 2) as avg_speed 
from #TEMP_runner_orders
where cancellation = ' ' 
group by runner_id, distance, duration;

--- Q7 what is the successful delivery rate for each customer?
with delivery_cte AS (select runner_id, count(runner_id) as orders, sum (case
when distance <> 0 then 1
else 0 
end) as success_delivery
from #TEMP_runner_orders
group by runner_id)

select round((success_delivery/orders * 100),0) delivery_per
from delivery_cte

/*  INGREDIENT OPTIMISATION 
Q8 - What are standard ingredients for each pizza ?
*/

--- altering the datatype for the next query 
alter table pizza_recipes 
alter column toppings nvarchar(30);

-- creating a temp table to normalize toppings column
select pizza_id, value as topping 
into #temp_pizza_recipes
from pizza_recipes cross apply string_split(toppings, ',');
select * from #temp_pizza_recipes;

--- aggregating all the pizza information 
select r.pizza_id, n.pizza_name, r.topping, t.topping_name
from #temp_pizza_recipes as r join pizza_names as n on r.pizza_id = n.pizza_id
join pizza_toppings as t on t.topping_id = r.topping --standard ingredients would be the toppings for each pizza

-- Q2 What was the most common exculsion?
--select * from customer_orders;

with most_exculsion_cte as (select customer_id, order_id, pizza_id, value as exculsions
from #TEMP_customer_orders cross apply string_split(exculsions, ','))
select max(exculsions) as most_common_exculsion from most_exculsion_cte;

--- Q3 What was the most commonly added extra?
with added_extra_cte as (select customer_id, order_id, pizza_id, value as extras
from #TEMP_customer_orders cross apply string_split(extras, ','))
select max(extras) as most_added_extra 
from added_extra_cte;

 /*
--- Q4 Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers */

select *, case 
when pizza_id = 1 and exculsions = ' ' and extras = ' ' then 'Meat Lovers'
when pizza_id = 2 and exculsions = ' ' and extras = ' ' then 'Vegetarians'
when pizza_id = 2 and exculsions = ' ' and extras = '1' then 'Vegetarians - Extra Bacon'
when pizza_id = 1 and exculsions = '4' and extras = ' ' then 'Meat Lovers - Exclude Cheese'
when pizza_id = 2 and exculsions = '4' and extras = ' ' then 'Meat Lovers - Exclude Cheese'
when pizza_id = 1 and exculsions = ' ' and extras = '1' then 'Meat Lovers - Exclude Cheese'
when pizza_id = 1 and exculsions = '4' and extras = '1, 5 ' then 'Meat Lovers - Exclude Cheese - Extra Baocn, Chicken'
when pizza_id = 1 and exculsions = '2, 6' and extras = '1, 4' then 'Meat Lovers - Exclude Cheese, Bacon - Extra Bacon, Cheese' 
end as order_items
from #TEMP_customer_orders


-- Q6 what is the total quantity of each ingredient used in all the delievered pizzas sorted by most frequent first?