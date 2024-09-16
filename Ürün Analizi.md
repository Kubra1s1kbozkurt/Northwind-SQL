
![](https://github.com/Kubra1s1kbozkurt/Northwind-SQL/blob/main/image/%C3%9Cr%C3%BCn%20Analizi.png)

Ürün analizi-Yeniden satın alınan ürünleri listeleme
```sql
SELECT 
    p.product_id,
    p.product_name,
    COUNT(DISTINCT o.order_id) AS number_of_orders
FROM 
    order_details AS od
INNER JOIN 
    products AS p ON od.product_id = p.product_id
INNER JOIN 
    orders AS o ON od.order_id = o.order_id
GROUP BY 
    p.product_id, p.product_name
HAVING 
    COUNT(DISTINCT o.order_id ) > 1
ORDER BY 
    number_of_orders DESC;

