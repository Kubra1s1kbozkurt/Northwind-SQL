![Sipariş analizi](https://github.com/Kubra1s1kbozkurt/Northwind-SQL/blob/main/image/Y%C4%B1llara%20g%C3%B6re%20sipari%C5%9F%20analizi.png)

Yıllara göre aylık order sayısı
```sql
SELECT
    TO_CHAR(o.order_date, 'YYYY-MM') AS order_month,
    COUNT(o.order_id) AS number_of_orders
FROM
    orders AS o
GROUP BY
    TO_CHAR(o.order_date, 'YYYY-MM')
ORDER BY
    order_month;
    
