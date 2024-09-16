![Gelir analizi](https://github.com/Kubra1s1kbozkurt/Northwind-SQL/blob/main/image/Y%C4%B1l%20bazl%C4%B1%20gelir%20analizi.png)


Yıl bazlı gelir analizi
```sql
SELECT 
    DATE_PART('year', o."order_date") AS year,
    TO_CHAR(SUM(od.quantity * od.unit_price * (1 - od.discount)), '$999,999,999.99') AS yearly_income
FROM 
    "orders" o
JOIN 
    "order_details" od ON o."order_id" = od."order_id"
GROUP BY 
    DATE_PART('year', o."order_date")
ORDER BY 
    year;

