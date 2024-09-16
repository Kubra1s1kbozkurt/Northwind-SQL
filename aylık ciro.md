![Gelir analizi](https://github.com/Kubra1s1kbozkurt/Northwind-SQL/blob/main/image/Ciro%20analizi.png)

Aylık gelir analizi (Discount oranı dahilinde gelir hesaplanmıştır.)
```sql
SELECT 
    DATE_PART('year', o."order_date") AS year,
    DATE_PART('month', o."order_date") AS month,
    TO_CHAR(SUM(od.quantity * od.unit_price * (1 - od.discount)), '$999,999,999.99') AS monthly_income
FROM 
    "orders" o
JOIN 
    "order_details" od ON o."order_id" = od."order_id"
GROUP BY 
    DATE_PART('year', o."order_date"),
    DATE_PART('month', o."order_date")
ORDER BY 
    year,
    month;

