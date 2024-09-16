![Çalışan analizi](https://github.com/Kubra1s1kbozkurt/Northwind-SQL/blob/main/image/%C3%87al%C4%B1%C5%9Fan%20analizi.png)

Çalışan Analizi
```sql
Hangi çalışan ne kadar satış yaptı ve ne kadar gelir getirdi

SELECT 
    e.employee_id, 
    e.first_name, 
    e.last_name, 
    COUNT(o.order_id) AS order_count,
    TO_CHAR(SUM(od.unit_price * od.quantity * (1 - od.discount)), 'FM$999,999,999.00') AS total_revenue
FROM 
    employees e
LEFT JOIN 
    orders o ON e.employee_id = o.employee_id
LEFT JOIN 
    order_details od ON o.order_id = od.order_id
GROUP BY 
    e.employee_id, 
    e.first_name, 
    e.last_name
ORDER BY 
    total_revenue asc;


