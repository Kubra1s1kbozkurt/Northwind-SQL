![Sipariş analizi](https://github.com/Kubra1s1kbozkurt/Northwind-SQL/blob/main/image/Aylara%20g%C3%B6re%20sipari%C5%9F%20analizi.png)

Aylık order sayısı
```sql
SELECT
    TO_CHAR(o.order_date, 'Month') AS order_month,
    COUNT(o.order_id) AS number_of_orders
FROM
    orders AS o
GROUP BY
    TO_CHAR(o.order_date, 'Month'),
    EXTRACT(MONTH FROM o.order_date)
ORDER BY
    EXTRACT(MONTH FROM o.order_date);

