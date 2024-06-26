CREATE DATABASE PIZZA_SALE;
USE PIZZA_SALE;

-- total number of orders placed
SELECT SUM(QUANTITY) AS TOTAL_ORDERED_PIZZA
FROM ORDER_DETAILS;

-- total revenue generated from pizza sales
SELECT 
    ROUND(SUM(ORDER_DETAILS.QUANTITY * PIZZAS.PRICE), 2) AS REVENUE
FROM
    ORDER_DETAILS
        JOIN
    PIZZAS ON ORDER_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID;

--  highest-priced pizza
SELECT 
    PIZZA_TYPES.NAME, PIZZAS.PRICE
FROM
    PIZZA_TYPES
        JOIN
    PIZZAS ON PIZZA_TYPES.PIZZA_TYPE_ID = PIZZAS.PIZZA_TYPE_ID
ORDER BY PIZZAS.PRICE DESC
LIMIT 1;

-- the most common pizza size ordered
SELECT 
    PIZZAS.SIZE,
    COUNT(ORDER_DETAILS.ORDER_DETAILS_ID) AS ORDER_COUNT
FROM
    PIZZAS
        JOIN
    ORDER_DETAILS ON PIZZAS.PIZZA_ID = ORDER_DETAILS.PIZZA_ID
GROUP BY PIZZAS.SIZE
ORDER BY ORDER_COUNT DESC
LIMIT 1;

-- top 5 most ordered pizza types along with their quantities
SELECT 
    PIZZA_TYPES.NAME AS PIZZA_NAME,
    SUM(ORDER_DETAILS.QUANTITY) AS QUANTITY
FROM
    PIZZA_TYPES
        JOIN
    PIZZAS ON PIZZA_TYPES.PIZZA_TYPE_ID = PIZZAS.PIZZA_TYPE_ID
        JOIN
    ORDER_DETAILS ON ORDER_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID
GROUP BY PIZZA_NAME
ORDER BY QUANTITY DESC
LIMIT 5;



-- total quantity of each pizza category ordered
SELECT 
    PIZZA_TYPES.CATEGORY AS CATEGORY,
    SUM(ORDER_DETAILS.QUANTITY) AS QUANTITY
FROM
    PIZZA_TYPES
        JOIN
    PIZZAS ON PIZZA_TYPES.PIZZA_TYPE_ID = PIZZAS.PIZZA_TYPE_ID
        JOIN
    ORDER_DETAILS ON ORDER_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID
GROUP BY CATEGORY
ORDER BY QUANTITY DESC;

-- distribution of orders by hour of the day
SELECT 
    HOUR(TIME) AS HOUR, COUNT(ORDER_ID) AS ORDER_COUNT
FROM
    ORDERS
GROUP BY HOUR
ORDER BY HOUR;


-- category-wise distribution of pizzas
SELECT CATEGORY, COUNT(NAME) FROM PIZZA_TYPES
GROUP BY CATEGORY;

-- average number of pizzas ordered per day
SELECT 
    ROUND(AVG(QUANTITY), 0) AS AVERAGE_ORDER_PER_DAY
FROM
    (SELECT 
        ORDERS.DATE AS DAY, SUM(ORDER_DETAILS.QUANTITY) AS QUANTITY
    FROM
        ORDERS
    JOIN ORDER_DETAILS ON ORDERS.ORDER_ID = ORDER_DETAILS.ORDER_ID
    GROUP BY DAY) AS AVERAGE_ORDER;
    
    
    
    -- top 3 most ordered pizza types based on revenue
SELECT 
    PIZZA_TYPES.NAME AS NAME,
    SUM(ORDER_DETAILS.QUANTITY * PIZZAS.PRICE) AS REVENUE
FROM
    PIZZA_TYPES
        JOIN
    PIZZAS ON PIZZA_TYPES.PIZZA_TYPE_ID = PIZZAS.PIZZA_TYPE_ID
        JOIN
    ORDER_DETAILS ON ORDER_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID
GROUP BY NAME
ORDER BY REVENUE DESC
LIMIT 3;


-- contribution of each pizza category to total revenue
SELECT 
    PIZZA_TYPES.CATEGORY AS CATEGORY,
    CONCAT(
    ROUND(
    (SUM(ORDER_DETAILS.QUANTITY * PIZZAS.PRICE) / (SELECT 
            SUM(ORDER_DETAILS.QUANTITY * PIZZAS.PRICE)
        FROM
            ORDER_DETAILS
                JOIN
            PIZZAS ON ORDER_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID)) * 100), '%') AS REVENUE
FROM
    PIZZA_TYPES
        JOIN
    PIZZAS ON PIZZA_TYPES.PIZZA_TYPE_ID = PIZZAS.PIZZA_TYPE_ID
        JOIN
    ORDER_DETAILS ON ORDER_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID
GROUP BY CATEGORY
ORDER BY REVENUE DESC;


-- cumulative revenue generated over time
SELECT  DATE , 
CONCAT(
	ROUND(
		SUM(REVENUE) OVER(ORDER BY DATE),0), ' $') AS CUMULATIVE_REVENUE 
        FROM
			(SELECT ORDERS.DATE AS DATE, SUM(ORDER_DETAILS.QUANTITY * PIZZAS.PRICE) AS REVENUE
				FROM ORDERS 
			JOIN ORDER_DETAILS
					ON ORDERS.ORDER_ID = ORDER_DETAILS.ORDER_ID
			JOIN PIZZAS
					ON ORDER_DETAILS.PIZZA_ID  = PIZZAS.PIZZA_ID
GROUP BY DATE
ORDER BY DATE) AS REVENUE_OVER_TIME;


--  top 3 most ordered pizza types based on revenue for each pizza category
SELECT 
    CATEGORY, 
    NAME, 
    REVENUE
FROM 
    (SELECT 
        CATEGORY, 
        NAME, 
        REVENUE, 
        RANK() OVER(PARTITION BY CATEGORY ORDER BY REVENUE DESC) AS RN
     FROM
        (SELECT 
            PIZZA_TYPES.CATEGORY AS CATEGORY, 
            PIZZA_TYPES.NAME AS NAME,  
            SUM(ORDER_DETAILS.QUANTITY * PIZZAS.PRICE) AS REVENUE
         FROM 
            PIZZA_TYPES 
            JOIN PIZZAS ON PIZZA_TYPES.PIZZA_TYPE_ID = PIZZAS.PIZZA_TYPE_ID
            JOIN ORDER_DETAILS ON ORDER_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID
         GROUP BY 
            PIZZA_TYPES.CATEGORY, 
            PIZZA_TYPES.NAME
        ) AS A
    ) AS B
WHERE 
    RN <= 3;

