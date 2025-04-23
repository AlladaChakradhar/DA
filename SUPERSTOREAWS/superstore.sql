-- 1.  What is the monthly trend of total sales and profit?

SELECT
  extract(month FROM date_parse(order_date, '%c/%e/%Y')) AS month,
  round(SUM(sales),0) AS total_sales,
  round(SUM(profit),2) AS total_profit
FROM orders
GROUP BY 1
ORDER BY 1;



-- 2. Which product categories and sub-categories are most profitable?

SELECT
  category,sub_category,
  round(SUM(sales),0) AS total_sales,
  round(SUM(profit),2) AS total_profit
FROM orders
GROUP BY 1,2
ORDER BY total_profit desc;


-- 3. Which cities or regions are underperforming in terms of profit?

SELECT
  region,city,
  round(SUM(profit),2) AS total_profit
FROM orders
GROUP BY 1,2 having sum(profit)<0
ORDER BY total_profit;



-- 4.  What is the effect of discounts on profit?

SELECT
  ROUND(discount, 2)*100 AS discount_level,
  COUNT(*) AS order_count,
  round(SUM(sales),0) AS total_sales,
  round(SUM(profit),2) AS total_profit
FROM orders
GROUP BY 1
ORDER BY 1;



--5. Who are the top 10 most valuable customers?

select customer_id,customer_name, sum(sales) as total_sales,sum(profit) as total_profit from orders
group by 1,2
order by total_profit desc limit 10

