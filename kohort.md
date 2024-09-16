![Kohort analizi](https://github.com/Kubra1s1kbozkurt/Northwind-SQL/blob/main/image/Kohort%20Analizi.png)

Kohort Analizi

-- Müşterilerin ilk sipariş verdikleri ayı belirleme
```sql
WITH first_order AS (
    SELECT customer_id,
           MIN(DATE_TRUNC('month', order_date)) AS first_order_month
    FROM orders
    GROUP BY customer_id
),

-- Her sipariş için ilgili dönemi belirleme
orders_with_period AS (
    SELECT o.customer_id,
           o.order_id,
           DATE_TRUNC('month', o.order_date) AS order_month,
           fo.first_order_month,
           EXTRACT(YEAR FROM age(DATE_TRUNC('month', o.order_date), fo.first_order_month)) * 12 + 
           EXTRACT(MONTH FROM age(DATE_TRUNC('month', o.order_date), fo.first_order_month)) AS period
    FROM orders o
    JOIN first_order fo ON o.customer_id = fo.customer_id
)

-- Kohort analizi

SELECT 
    TO_CHAR(first_order_month, 'YYYY-MM') AS cohort_month,
    period,
    COUNT(DISTINCT owp.customer_id) AS num_customers,
    TO_CHAR(ROUND(SUM(od.quantity * od.unit_price * (1 - od.discount))::numeric, 2), 'FM$999,999,999.00') AS total_revenue
FROM 
    orders_with_period owp
JOIN
    order_details od ON owp.order_id = od.order_id
GROUP BY 
    first_order_month, period
ORDER BY 
    first_order_month, period;

