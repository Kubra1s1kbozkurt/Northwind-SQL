![Gelir analizi](https://github.com/Kubra1s1kbozkurt/Northwind-SQL/blob/main/image/Kategori%20bazl%C4%B1%20ayl%C4%B1k%20ciro%20analizi.png)

Kategori bazlı aylık gelir analizi
```sql
SELECT 
    c."category_name" AS category,
    DATE_PART('year', o."order_date") AS year,
    DATE_PART('month', o."order_date") AS month,
    TO_CHAR(SUM(od.quantity * od.unit_price * (1 - od.discount)), '$999,999,999.99') AS monthly_income
FROM 
    "orders" o
JOIN 
    "order_details" od ON o."order_id" = od."order_id"
JOIN 
    "products" p ON od."product_id" = p."product_id"
JOIN 
    "categories" c ON p."category_id" = c."category_id"
GROUP BY 
    c."category_name",
    DATE_PART('year', o."order_date"),
    DATE_PART('month', o."order_date")
ORDER BY 
    year,
    month,
    category;


