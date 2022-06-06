CREATE DATABASE dannys_dinner;
USE dannys_dinner;
CREATE TABLE sales(customer_id VARCHAR(1), order_date DATE, product_id INTEGER)

INSERT INTO sales ("customer_id", "order_date", "product_id")
VALUES
('A', '2021-01-01', '1'),
('A', '2021-01-01', '2'),
('A', '2021-01-07', '2'),
('A', '2021-01-10', '3'),
('A', '2021-01-11', '3'),
('A', '2021-01-11', '3'),
('B', '2021-01-01', '2'),
('B', '2021-01-02', '2'),
('B', '2021-01-04', '1'),
('B', '2021-01-11', '1'),
('B', '2021-01-16', '3'),
('B', '2021-02-01', '3'),
('C', '2021-01-01', '3'),
('C', '2021-01-01', '3'),
('C', '2021-01-07', '3');

CREATE TABLE menu (
"product_id" INTEGER,
"product_name" VARCHAR(5),
"price" INTEGER
);
INSERT INTO menu ("product_id", "product_name", "price")
VALUES
('1', 'sushi', '10'),
('2', 'curry', '15'),
('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members ("customer_id", "join_date")
VALUES
('A', '2021-01-07'),
('B', '2021-01-09');

--- case study questions 
--- Q1. what is the total amount each customer spent at the restaurant?

SELECT * FROM sales;
SELECT * FROM menu;
SELECT * FROM members;

SELECT customer_id, SUM(price) AS each_customer_sales FROM sales JOIN menu ON sales.product_id = menu.product_id
GROUP BY customer_id;

--- Q2. how many days has each customer visited the restaurant?
SELECT customer_id, COUNT(DISTINCT(order_date)) AS days_visited FROM sales GROUP BY customer_id;

--- Q3. what was the first item from the menu each customer purchased?

WITH first_item_cte AS 
(
SELECT customer_id, order_date, product_name,
DENSE_RANK() OVER( PARTITION BY s.customer_id ORDER BY order_date) AS rank 
FROM sales AS s JOIN  menu AS m ON s.product_id = m.product_id
)
SELECT customer_id, product_name, rank FROM first_item_cte WHERE rank=1;
--- Q4. what was the most purchased item on the menu and how many times was it purchased by all customers?

SELECT TOP 1 product_name, sales.product_id, COUNT(sales.product_id) as most_purchased 
FROM sales JOIN menu 
ON menu.product_id = sales.product_id 
GROUP BY sales.product_id, product_name ORDER BY product_id DESC;

--- Q5. which item is the most popular for each customer?
WITH most_popular_cte AS (
SELECT customer_id, product_name, COUNT(sales.product_id) AS most_popular_item, 
DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(customer_id) DESC) AS rank
FROM sales JOIN menu ON sales.product_id = menu.product_id 
GROUP BY sales.customer_id, product_name
)
SELECT customer_id, product_name, most_popular_item, rank 
FROM most_popular_cte
WHERE rank=1;

--- Q6	which item was first purchased by the customer after they became a member?
WITH first_item_cte AS (
SELECT s.customer_id, join_date, order_date, product_id, 
DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) as rank 
FROM sales AS s JOIN members AS m ON s.customer_id = m.customer_id
WHERE order_date >= join_date
)
SELECT customer_id, join_date, order_date, product_id, rank
FROM first_item_cte
WHERE rank = 1;
--- Q7. which item was purchased just before the customer became a member?
WITH first_item_cte AS (
SELECT s.customer_id, join_date, order_date, product_id, 
DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) as rank 
FROM sales AS s JOIN members AS m ON s.customer_id = m.customer_id
WHERE order_date < join_date
)
SELECT customer_id, join_date, order_date, product_name 
FROM first_item_cte  AS f JOIN menu m ON f.product_id = M.product_id
--WHERE rank = 1;

---Q8 which is the total items and amounts spent by each member before they became a member?
SELECT s.customer_id, COUNT(s.product_id) as total_items, SUM(mu.price) as total_amt
FROM 
sales s JOIN members m ON s.customer_id = m.customer_id
JOIN menu mu ON s.product_id = mu.product_id
WHERE s.order_date < m.join_date
GROUP BY s.customer_id
;

--- Q9  If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?
WITH item_pts_cte AS (
SELECT * , 
CASE 
WHEN product_id = 1 THEN price*20
ELSE price*10
END AS points
FROM menu)

SELECT  s.customer_id, SUM(i.points) AS total_pts 
FROM item_pts_cte as i JOIN sales as s ON i.product_id = s.product_id
GROUP BY s.customer_id;

/* Q10. In the first week after a customer joins the program (including their join date) 
they earn 2x points on all items, 
not just sushi — how many points do customer A and B have at the end of January?

sushi = 2x 
first week after joining = 2x
else = 1x */

WITH dates_cte AS (
SELECT *, 
DATEADD(DAY, 6, join_date) as valid_until_date, 
EOMONTH('2021-01-07') AS end_date
FROM members
)
SELECT s.customer_id, s.order_date, d.join_date, d.valid_until_date, d.end_date, m.product_name, m.price,
CASE WHEN 
     m.product_name = 'sushi' THEN m.price*20
	 WHEN 
	 s.order_date BETWEEN d.join_date AND d.valid_until_date THEN m.price*20
	 ELSE
	 price*10
	 END  AS points
FROM 
dates_cte as d JOIN sales AS s ON s.customer_id = d.customer_id
JOIN menu m ON s.product_id = m.product_id 
WHERE s.order_date < d.end_date

/*Bonus Questions
Join All The Things
Recreate the table with: customer_id, order_date, product_name, price, member (Y/N) */

SELECT s.customer_id, s.order_date, m.product_name, m.price, 
CASE WHEN s.order_date < mm.join_date THEN 'N'
     WHEN s.order_date >= mm.join_date THEN 'Y'
END AS member
FROM sales as s JOIN menu as m ON s.product_id = m.product_id
JOIN members as mm ON s.customer_id = mm.customer_id

--- RANK ALL THE THINGS

WITH ranking_cte AS (
SELECT s.customer_id, s.order_date, m.product_name, m.price, 
CASE WHEN s.order_date < mm.join_date THEN 'N'
     WHEN s.order_date >= mm.join_date THEN 'Y'
END AS member
FROM sales as s JOIN menu as m ON s.product_id = m.product_id
JOIN members as mm ON s.customer_id = mm.customer_id
)
SELECT *, CASE
WHEN member = 'N' THEN NULL
ELSE 
RANK() OVER(PARTITION BY customer_id, member ORDER BY order_date)
END AS ranking
FROM ranking_cte;