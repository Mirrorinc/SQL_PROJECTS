CREATE SCHEMA PIZZA_RUNNER;
USE PIZZA_RUNNER;
CREATE TABLE runner_orders (
order_id int,
runner_id int,
pickup_time  VARCHAR(20) NULL DEFAULT NULL,
distance VARCHAR(10),
duration VARCHAR(10),
cancellation VARCHAR(30));

INSERT INTO runner_orders VALUES ('1', '1', '2021-01-01 18:15:34', '20KM', '32 MINUTES', ' '),
 ('2', '1', '2021-01-01 19:10:35', '20KM', '27 MINUTES', ' '),
 ('3', '1', '2021-01-03 00:12:37', '13.4KM', '20 MINUTES', ' '),
 ('4', '2', '2021-01-04 13:53:03', '23.4', '40', ' '),
 ('5', '3', '2021-01-08 21:10:57', '10', '15', ' '),
 ('6', '3', 'null', 'NULL', 'NULL', 'RESTAURANT CANCELLATION'),
 ('7', '2', '2021-01-08 21:30:45', '25KM', '25 MINS', 'NULL '),
 ('8', '2', '2021-01-10 00:15:02', '23.4KM', '15 MINUTES', 'NULL '),
 ('9', '2', 'NULL', 'NULL', 'NULL', 'CUSTOMER CANCELLATION'),
 ('10', '1', '2021-01-11 18:50:20', '10KM', '10 MINUTES', 'NULL');
 
 CREATE TABLE customer_orders (
 order_id int,
 customer_id int,
 pizza_id int,
 exclusions VARCHAR(10),
 extras VARCHAR(10),
 order_time TIMESTAMP);
 
 INSERT INTO customer_orders VALUES ('1', '101', '1', ' ', ' ', '2021-01-01 18:05:02'),
 ('2', '101', '1', ' ', ' ', '2021-01-01 19:00:52'),
 ('3', '102', '1', ' ', ' ', '2021-01-02 23:51:23'),
 ('3', '102', '2', ' ', ' ', '2021-01-02 23:51:23'),
 ('4', '103', '1', '4', ' ', '2021-01-04 13:23:46'),
 ('4', '103', '1', '4', ' ', '2021-01-04 13:23:46'),
 ('4', '103', '2', '4', ' ', '2021-01-04 13:23:46'),
 ('5', '104', '1', 'null', '1', '2021-01-08 21:00:29'),
 ('6', '101', '2', 'null', 'null', '2021-01-08 21:03:13'),
 ('7', '105', '2', 'null', '1', '2021-01-08 21:20:29'),
 ('8', '102', '1', 'null', 'null', '2021-01-09 23:54:33'),
 ('9', '103', '1', '4', '1,5', '2021-01-10 11:22:59'),
 ('10', '104', '1', 'null', 'null', '2021-01-11 18:34:49'),
 ('10', '104', '1', '2,6', '1,4', '2021-01-11 18:34:49');
 
 CREATE TABLE runners (
 runner_id int,
 registration_date DATE);
 
 INSERT INTO runners VALUES ('1', '2021-01-01'), ('2', '2021-01-03'),
 ('3', '2021-01-08'), ('4', '2021-01-15');
 
 CREATE TABLE pizza_names (
 pizza_id int,
 pizza_name VARCHAR(15));
 
 INSERT INTO pizza_names VALUES ('1', 'meat lovers'), ('2', 'vegetarian');
 
 
 CREATE TABLE pizza_recipes (
 pizza_id int,
 toppings text);
 
 INSERT INTO pizza_recipes VALUES ('1', '1,2,3,4,5,6,8,10'), ('2', '4,6,7,9,11,12');
 
 CREATE TABLE pizza_toppings (
 topping_id int,
 topping_name VARCHAR(20));
 
 INSERT INTO pizza_toppings VALUES ('1', 'Bacon'), ('2', 'BBQ Sauce'), ('3', 'Beef'), ('4', 'Cheese'),
 ('5', 'Chicken'), ('6', 'Mushrooms'), ('7', 'Onions'), ('8', 'Pepperoni'), ('9', 'Peppers'),
 ('10', 'Salami'), ('11', 'Tomatoes'), ('12', 'Tomato_Sauce');
 
 -- DATA CLEANING
 -- Creating temporary table to clean the data
 
 DROP TEMPORARY TABLE IF EXISTS temp_runner_orders;
 CREATE TEMPORARY TABLE temp_runner_orders (
 SELECT 
	order_id, runner_id,
    CASE 
		WHEN pickup_time LIKE 'null' THEN NULL
        WHEN pickup_time LIKE '%NULL' THEN NULL
		ELSE pickup_time
		END AS pickup_time,
    CASE 
		WHEN distance LIKE 'NULL' THEN NULL
		WHEN distance LIKE '%KM' THEN TRIM('KM' FROM distance)
		ELSE distance
		END AS distance,
    CASE
    WHEN duration LIKE 'NULL' THEN NULL
    WHEN duration LIKE '%MINS' THEN TRIM('MINS' FROM duration)
    WHEN duration LIKE '%MINUTE' THEN TRIM('MINUTE' FROM duration)
    WHEN duration LIKE '%MINUTES' THEN TRIM('MINUTES' FROM duration)
    ELSE duration
    END AS duration,
    CASE
    WHEN cancellation LIKE '%NULL%' THEN NULL
    WHEN cancellation IS NULL THEN NULL
    ELSE cancellation
    END AS cancellation
    FROM runner_orders);
    ALTER TABLE temp_runner_orders
    MODIFY pickup_time DATETIME,
    MODIFY distance FLOAT,
    MODIFY duration INT;
    
    select * from temp_runner_orders;
    -- CUSTOMER ORDERS TEMPORARY TABLE
    DROP TABLE IF EXISTS TEMP_CUSTOMER_ORDERS;
    CREATE TEMPORARY TABLE TEMP_CUSTOMER_ORDERS (
    SELECT
		ORDER_ID, CUSTOMER_ID, PIZZA_ID,
        CASE 
        WHEN EXCLUSIONS LIKE '%NULL%' THEN ''
        ELSE EXCLUSIONS 
        END AS EXCLUSIONS,
        CASE 
        WHEN EXTRAS LIKE '%NULL%' THEN ''
        WHEN EXTRAS IS NULL THEN ''
        ELSE EXTRAS
        END AS EXTRAS,
        ORDER_TIME
        FROM CUSTOMER_ORDERS);
	
 select * from temp_customer_orders;

 -- PIZZA METRICS
 -- HOW MANY PIZZAS WERE ORDERED?
 SELECT COUNT(PIZZA_ID) AS ORDER_COUNT FROM TEMP_CUSTOMER_ORDERS;



DROP TABLE IF EXISTS temp_pizza_recipes;
CREATE TEMPORARY TABLE temp_pizza_recipes (
pizza_id VARCHAR(1),
topping int );

INSERT INTO temp_pizza_recipes VALUES (1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(1,8),(1,10),(2,4),
(2,7),(2,9),(2,11),(2,12); 
SELECT * FROM temp_pizza_recipes;
 -- HOW MANY UNIQUE CUSTOMER ORDERS WERE MADE?
 SELECT COUNT(DISTINCT (order_id)) AS unique_cust_order FROM temp_customer_orders;
 
 
 -- HOW MANY SUCCESSFUL ORDERS WERE DELIVERED BY EACH RUNNER?
 SELECT runner_id, COUNT(order_id) AS successful_orders FROM temp_runner_orders
 WHERE cancellation = ' '
 GROUP BY runner_id;
 
 
 
 -- HOW MANY OF EACH TYPE OF PIZZA WAS DELIVERED?
 SELECT pizza_names.pizza_name, COUNT(temp_customer_orders.pizza_id) AS  pizza_delivered 
 FROM temp_customer_orders JOIN pizza_names ON temp_customer_orders.pizza_id = pizza_names.pizza_id
 JOIN temp_runner_orders ON temp_runner_orders.order_id = temp_customer_orders.order_id
 WHERE cancellation = ' ' 
 GROUP BY pizza_names.pizza_name;
 
 
 
 -- HOW MANY VEGETARIAN AND MEATLOVERS WERE ORDERED BY EACH CUSTOMER?
 SELECT customer_id,
 SUM(if(pizza_id = 1,1,0)) AS meat_lovers,
 SUM(if(pizza_id = 2,1,0)) AS vegetarians
 FROM temp_customer_orders
 GROUP BY customer_id;
 
 
 
 
 -- WHAT WAS THE MAXIMUM NUMBER OF PIZZAS DELIVERED IN A SINGLE ORDER?
 WITH cte_pizza AS (
 SELECT temp_customer_orders.order_id,
 COUNT(temp_customer_orders.pizza_id) AS count_pizza
 FROM temp_customer_orders
 JOIN temp_runner_orders ON temp_customer_orders.order_id = temp_runner_orders.order_id
 WHERE temp_runner_orders.cancellation = ' '
 GROUP BY order_id)
 
 SELECT MAX(count_pizza) AS max_num_pizza FROM cte_pizza;
 
 
 
 -- FOR EACH CUSTOMER, HOW MANY DELIVERED PIZZAS HAD AT LEAST ONE CHANGE AND HOW MANY HAD NO CHANGES?
SELECT customer_id, 
SUM(CASE 
WHEN tco.exclusions != ' ' OR tco.extras != ' ' THEN 1
ELSE 0
END) AS changes,
SUM(CASE 
WHEN tco.exclusions = ' ' AND tco.extras = ' ' THEN 1
ELSE 0
END) AS no_changes
FROM temp_customer_orders tco 
JOIN temp_runner_orders tro ON tco.order_id = tro.order_id
WHERE tro.distance != 0
GROUP BY tco.customer_id; 
 
 
 
 
 -- HOW MANY PIZZAS WERE DELIVERED THAT HAD BOTH EXCLUSIONS AND EXTRAS?
SELECT COUNT(tco.order_id) AS count_pizza
FROM temp_customer_orders tco cross
JOIN temp_runner_orders tro ON tco.order_id = tro.order_id
WHERE tco.exclusions != ' ' AND tco.extras != ' ' AND tro.cancellation = ' '
GROUP BY tco.customer_id; 
 
 
 
 -- WHAT WAS THE TOTAL VOLUME OF PIZZAS ORDERED FOR EACH HOUR OF THE DAY?
 SELECT 
 HOUR(order_time) AS hour_of_day,
 COUNT(order_id) AS pizza_volume
 FROM temp_customer_orders
 GROUP by hour_of_day
 ORDER BY hour_of_day;
 
 
 
 -- WHAT WAS THE VOLUME OF ORDERS FOR EACH DAY OF THE WEEK?
SELECT DAYNAME(order_time) AS day_of_week, COUNT(*) AS pizza_volume
FROM temp_customer_orders
GROUP BY day_of_week
ORDER BY day_of_week;

-- RUNNER AND CUSTOMER EXPERIENCE
-- HOW MANY RUNNERS SIGNED UP FOR EACH 1 WEEK PERIOD? (i.e. WEEK STARTS 2021-01-01)
WITH signedup_runner AS (
SELECT  
runner_id, registration_date,
registration_date - ((registration_date - DATE('2021-01-01'))%7) AS one_week
FROM runners)
SELECT 
one_week, COUNT(RUNNER_ID) AS NUM_RUNNER
FROM signedup_runner
GROUP BY one_week
ORDER BY one_week;

-- WHAT WAS THE AVERAGE TIME IN MINUTES IT TOOK FOR EACH RUNNER TO ARRIVE AT THE PIZZA RUNNER HQ TO PICKUP THE ORDER?
WITH cte_duration AS (
SELECT a.runner_id, b.order_time, a.pickup_time, 
TIME(b.order_time) - TIME(a.pickup_time) AS duration
FROM temp_runner_orders a
JOIN temp_customer_orders b ON a.order_id = b.order_id
WHERE cancellation = ' ' or cancellation is null)
SELECT
runner_id, ROUND(AVG(MINUTE(duration)),0) AS avg_time
FROM cte_duration
GROUP BY runner_id
ORDER BY runner_id;

-- IS THERE ANY RELATIONSHIP BETWEEN THE NUMBER OF PIZZAA AND HOW LONG THE ORDER TAKES TO PREPARE?
WITH cte_pizza AS (
SELECT 
tco.order_id, count(tco.order_id) AS num_pizza, tco.order_time, tro.pickup_time,
TIMEDIFF(tro.pickup_time, tco.order_time) AS duration
FROM temp_runner_orders tro
JOIN temp_customer_orders tco ON tco.order_id = tro.order_id
WHERE tro.distance != 0
GROUP BY tco.order_id, tco.order_time, tro.pickup_time)
SELECT 
num_pizza, MINUTE(AVG(duration)) AS avg_prepare_time
FROM cte_pizza
GROUP BY num_pizza;

-- WHAT WAS THE AVERAGE DISTANCE TRAVELLED FOR EACH CUSTOMER?
SELECT runner_id, round(avg(distance)) AS avg_distance
FROM temp_runner_orders
GROUP BY runner_id;

-- WHAT WAS THE DIFFERENCE BETWEEN THE LONGEST AND SHORTEST DELIVERY TIMES FOR ALL ORDERS?
WITH cte_times AS (
SELECT tro.order_id, timediff(tco.order_time, tro.pickup_time) AS times 
FROM temp_runner_orders tro
JOIN temp_customer_orders tco ON tro.order_id = tco.order_id
WHERE tro.duration != ' ' 
GROUP BY tro.order_id, tco.order_time, tro.pickup_time)

SELECT 
	MAX(minute(times)) - MIN(minute(times)) AS diff_times
    FROM cte_times;

-- WHAT WAS THE AVERAGE SPEED FOR EACH RUNNER FOR EACH DELIVERY AND DO YO NOTICE ANY TREND FOR THESE VALUES?
WITH cte_order AS (
SELECT 
order_id, COUNT(pizza_id) AS total_pizza
FROM temp_customer_orders
GROUP BY order_id)
SELECT
tro.runner_id, 
tro.order_id,
tro.distance,
tro.duration,
co.total_pizza,
round((60*distance/duration),1) AS SpeedKMH
FROM temp_runner_orders tro
JOIN cte_order co ON co.order_id = tro.order_id
WHERE distance != ' '
GROUP BY tro.runner_id, tro.order_id, tro.distance, tro.duration, co.total_pizza
ORDER BY tro.order_id;

-- WHAT IS THE SUCCESSFUL DELIVERY PERCENTAGE FOR EACH RUNNER?
SELECT 
runner_id, 
COUNT(pickup_time) AS success_delivery,
COUNT(order_id) AS total_order,
ROUND(COUNT(pickup_time)/COUNT(order_id)*100) AS perc_delivery
FROM temp_runner_orders
GROUP BY runner_id
ORDER BY runner_id;

-- INGREDIENTS OPTIMIZATION
-- WHAT ARE THE STANDARD INGREDIENTS FOR EACH PIZZA?
with cte_toppings AS (
select pt.topping_name, tpr.pizza_id, pn.pizza_name
FROM temp_pizza_recipes tpr
JOIN pizza_toppings pt ON pt.topping_id = tpr.topping
JOIN pizza_names pn ON pn.pizza_id = tpr.pizza_id
ORDER BY pn.pizza_name)
SELECT
ct.pizza_name, ct.topping_name
FROM cte_toppings ct;

-- WHAT WAS THE MOST COMMONLY ADDED EXTRA?
SELECT
    T.TOPPING_NAME,
    COUNT(T.TOPPING_NAME) AS NUM_TIMES_ADDED
FROM (
    SELECT
        ORDER_ID,
        CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(EXTRAS, ',', n), ',', -1) AS SIGNED) AS TOPPING_ID
    FROM
        TEMP_CUSTOMER_ORDERS
        JOIN (
            SELECT 1 AS n UNION ALL
            SELECT 2 AS n UNION ALL
            SELECT 3 AS n  UNION ALL
            SELECT 4 AS n UNION ALL
             SELECT 5 AS n UNION ALL
            SELECT 6 AS n UNION ALL
            SELECT 7 AS n  UNION ALL
            SELECT 8 AS n UNION ALL
             SELECT 9 AS n UNION ALL
            SELECT 10 AS n UNION ALL
            SELECT 11 AS n  UNION ALL
            SELECT 12
        ) numbers
        WHERE
            EXTRAS IS NOT NULL
            AND LENGTH(EXTRAS) - LENGTH(REPLACE(EXTRAS, ',', '')) >= n - 1
) AS EXTRAS
INNER JOIN PIZZA_TOPPINGS T ON T.TOPPING_ID = EXTRAS.TOPPING_ID
GROUP BY
    T.TOPPING_NAME
ORDER BY
    NUM_TIMES_ADDED DESC;


-- WHAT WAS THE MOST COMMON EXCLUSION?
SELECT
    T.TOPPING_NAME,
    COUNT(T.TOPPING_NAME) AS NUM_TIMES_ADDED
FROM (
    SELECT
        ORDER_ID,
        CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(EXCLUSIONS, ',', n), ',', -1) AS SIGNED) AS TOPPING_ID
    FROM
        TEMP_CUSTOMER_ORDERS
        JOIN (
            SELECT 1 AS n UNION ALL
            SELECT 2 AS n UNION ALL
            SELECT 3 AS n  UNION ALL
            SELECT 4 AS n UNION ALL
             SELECT 5 AS n UNION ALL
            SELECT 6 AS n UNION ALL
            SELECT 7 AS n  UNION ALL
            SELECT 8 AS n UNION ALL
             SELECT 9 AS n UNION ALL
            SELECT 10 AS n UNION ALL
            SELECT 11 AS n  UNION ALL
            SELECT 12
        ) numbers
        WHERE
            EXCLUSIONS IS NOT NULL
            AND LENGTH(EXTRAS) - LENGTH(REPLACE(EXCLUSIONS, ',', '')) >= n - 1
) AS EXCLUSIONS
INNER JOIN PIZZA_TOPPINGS T ON T.TOPPING_ID = EXCLUSIONS.TOPPING_ID
GROUP BY
    T.TOPPING_NAME
ORDER BY
    NUM_TIMES_ADDED DESC;

-- GENERATE AN ORDER ITEM FOR EACH RECORD IN THE CUSTOMER ORDERS TABLE IN THE FORMAT OF ONE OF THE FOLLOWING:
-- -- MEAT LOVERS
-- -- MEAT LOVERS - EXCLUDE BEEF
-- -- MEAT LOVERS - EXTRA BACON
-- -- MEAT LOVERS - EXCLUDE CHEESE, BACON - EXTRA MUSHROOM, PEPPER

SELECT 
TCO.ORDER_ID, TCO.PIZZA_ID, PN.PIZZA_NAME, TCO.EXCLUSIONS, TCO.EXTRAS, 
CASE
WHEN TCO.PIZZA_ID = 1 AND TCO.EXCLUSIONS = ' ' AND TCO.EXTRAS = ' ' THEN 'MEAT LOVERS'
WHEN TCO.PIZZA_ID = 2 AND TCO.EXCLUSIONS = ' ' AND TCO.EXTRAS = ' ' THEN 'VEGETARIAN'
WHEN TCO.PIZZA_ID = 1 AND TCO.EXCLUSIONS = '4' AND TCO.EXTRAS = ' ' THEN 'MEAT LOVERS - EXCLUDE CHEESE'
WHEN TCO.PIZZA_ID = 2 AND TCO.EXCLUSIONS = '4' AND TCO.EXTRAS = ' ' THEN 'VEGETARIAN - EXCLUDE CHEESE'
WHEN TCO.PIZZA_ID = 1 AND TCO.EXCLUSIONS = ' ' AND TCO.EXTRAS = '1' THEN 'MEAT LOVERS - EXTRA BACON'
WHEN TCO.PIZZA_ID = 2 AND TCO.EXCLUSIONS = ' ' AND TCO.EXTRAS = '1' THEN 'VEGETARIAN - EXTRA BACON'
WHEN TCO.PIZZA_ID = 1 AND TCO.EXCLUSIONS = '4' AND TCO.EXTRAS = '1,5' THEN 'MEAT LOVERS - EXCLUDE CHEESE - EXTRA BACON AND CHICKEN'
WHEN TCO.PIZZA_ID = 1 AND TCO.EXCLUSIONS = '2,6' AND TCO.EXTRAS = '1,4' THEN 'MEAT LOVERS - EXCLUDE BBQ SAUCE AND MUSHROOM - EXTRA BACON AND CHEESE'
END AS ORDER_ITEM
FROM TEMP_CUSTOMER_ORDERS TCO
JOIN PIZZA_NAMES PN ON TCO.PIZZA_ID = PN.PIZZA_ID;

-- GENERATE AN ALPHABETICALLY ORDERED COMMA SEPERATED INGREDIENT LIST FOR EACH PIZZA ORDER FROM THE CUSTOMER ORDERS
-- TABLE AND ADD A 2X IN FRONT OF ANY RELEVNAT INGREDIENTS. FOR EXAMPLE: MEAT LOVERS: 2X BACON, BEEF,..., SALAM
WITH TOPPINGS_TABLE AS (
    SELECT PR.PIZZA_ID, PT.TOPPING_ID, PT.TOPPING_NAME
    FROM PIZZA_RECIPES AS PR 
    INNER JOIN PIZZA_TOPPINGS AS PT ON PR.TOPPINGS = PT.TOPPING_ID
)

SELECT
    ORDER_ID,
    CUSTOMER_ID,
    ORDER_TIME,
    CONCAT(PIZZA_NAME, ':', '2X', GROUP_CONCAT(TOPPING_NAME ORDER BY TOPPING_NAME)) AS INGREDIENT_LIST
FROM TEMP_CUSTOMER_ORDERS AS TCO
INNER JOIN TOPPINGS_TABLE AS T USING (PIZZA_ID)
INNER JOIN PIZZA_NAMES AS PN ON TCO.PIZZA_ID = PN.PIZZA_ID
GROUP BY ORDER_ID, CUSTOMER_ID, ORDER_TIME, PIZZA_NAME;

-- WHAT IS THE TOTAL QUANTITY OF EACH INGREDIENT USED IN ALL DELIVERED PIZZAS SORETD BY MOST FREQUENT FIRST?
SELECT
    TPR.TOPPING,
    PT.TOPPING_NAME,
    COUNT(TPR.TOPPING) AS QUANTITY_INGREDIENT,
    PN.PIZZA_NAME
FROM
    TEMP_PIZZA_RECIPES TPR
JOIN
    TEMP_CUSTOMER_ORDERS TCO ON TPR.PIZZA_ID = TCO.PIZZA_ID
LEFT JOIN
    TEMP_RUNNER_ORDERS TRO ON TRO.ORDER_ID = TCO.ORDER_ID
JOIN
    PIZZA_TOPPINGS PT ON PT.TOPPING_ID = TPR.TOPPING
JOIN
    PIZZA_NAMES PN ON PN.PIZZA_ID = TCO.PIZZA_ID
WHERE
    TRO.CANCELLATION != ' '
GROUP BY
    TPR.TOPPING,
    PT.TOPPING_NAME,
    PN.PIZZA_NAME
ORDER BY
    QUANTITY_INGREDIENT DESC;



-- PRICING AND RATINGS

-- IF  MEAT LOVERS PIZZA COST $12 AND VEGETARIAN COST $10 AND THERE WERE NO CHNAGES FOR CHANGES - HOW MUCH MONEY HAS PIZZA RUNNER
-- MADE SO FAR IF THERE ARE NO DELIVERY FEES?
SELECT 
SUM(CASE
WHEN TCO.PIZZA_ID = 1 THEN 12
ELSE 10
END) AS TOTAL_PRICE
FROM TEMP_RUNNER_ORDERS TRO
JOIN TEMP_CUSTOMER_ORDERS TCO ON TCO.ORDER_ID = TRO.ORDER_ID
WHERE TRO.CANCELLATION = " " OR CANCELLATION IS NULL;
SELECT * FROM TEMP_RUNNER_ORDERS;

-- WHAT IF THERE WAS AN ADDITIONAL $1 CHANGE FOR ANY PIZZA EXTRAS? ADD CHEESE IS $1 EXTRA
CREATE TEMPORARY TABLE IF NOT EXISTS temp_prize AS (
  SELECT 
    TCO.PIZZA_ID,
    SUM(CASE WHEN TCO.PIZZA_ID = 1 THEN 12 ELSE 10 END) AS TOTAL_PRICE
  FROM TEMP_RUNNER_ORDERS TRO
  JOIN TEMP_CUSTOMER_ORDERS TCO ON TCO.ORDER_ID = TRO.ORDER_ID
  WHERE CANCELLATION = ' ' OR CANCELLATION IS NULL
  GROUP BY TCO.PIZZA_ID
);
SELECT (
  LENGTH(GROUP_CONCAT(TCO.EXTRAS)) - LENGTH(REPLACE(GROUP_CONCAT(TCO.EXTRAS), ', ', ' ')) + 1
) + SUM(CP.TOTAL_PRICE) AS TOTAL_PRICE_CHANGES
FROM TEMP_CUSTOMER_ORDERS TCO
JOIN temp_prize CP ON CP.PIZZA_ID = TCO.PIZZA_ID;

-- THE PIZZA RUNNER TEAM NOW WANTS TO ADD AN ADDITIONAL RATINGS SYSTEM THAT ALLOWS CUSTOMERS TO RATE THEIR RUNNER,
-- HOW WOULD YOU DESIGN AN ADDITIONLA TABLE FOR THIS NEW DATASET - GENERATE A SCHEMA FOR THIS NEW TABLE AND INSERT
-- YOUR OWN TABLE
DROP TABLE IF EXISTS ratings;
CREATE TABLE ratings (
order_id int,
rating int);
insert into ratings values (1,5), (2,3), (3,4), (4,2), (5,3), (7,3), (8,4), (10,5);

select * from ratings;

-- USING YOUT NEWLY GENERATED TABLE - CAN YOU JOIN ALL OF THE INFORMATION TOGETHER TO FORM A TABLE, WHIH HAS THE 
-- FOLLOWING INFORMATION FOR SUCCESSFUL DELIVERIES?
-- CUSTOMER_ID -- ORDER_ID -- RUNNER_ID -- RATING -- ORDER_TIME --PICKUP_TIME -- TIME BETWEEN ORDER AND PICKUP
-- DELIVERY INFORMATION -- AVERAGE SPEED -- TOTAL NO OF PIZZA

select 
tco.customer_id, tco.order_id, tro.runner_id, rt.rating, tco.order_time, tro.pickup_time,
MINUTE(timediff(tco.order_time, tro.pickup_time)) AS time_order_pickup, tro.duration,
round(avg(60*tro.distance/tro.duration),1) AS avg_speed, count(tco.pizza_id) AS num_pizza
from temp_customer_orders tco 
join temp_runner_orders tro on tco.order_id = tro.order_id
join ratings rt on tco.order_id = rt.order_id
group by tco.customer_id, tco.order_id, tro.runner_id, rt.rating,
tco.order_time, tro.pickup_time, time_order_pickup, tro.duration
order by tco.customer_id;


-- IF A MEAT LOVER PIZZA WAS $12 AND VEGETARIAN IS $10 FIXED PRIZES WITH NO COST OF EXTRAS AND EACH RUNNER IS PAID 
-- $0.30 PER KILOMETRE TRAVELLED, HOW MUCH MONEY DOES PIZZA RUNNER HAVE LEFT OVER AFTER THESE DELIVERIES?
SELECT ROUND(138 - SUM(duration) * 0.3, 0) AS final_price
FROM temp_runner_orders;




--