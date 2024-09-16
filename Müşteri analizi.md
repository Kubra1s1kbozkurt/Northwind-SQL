![Müşteri analizi](https://github.com/Kubra1s1kbozkurt/Northwind-SQL/blob/main/image/M%C3%BC%C5%9Fteri%20Analizi2.png)

Müşteri Analizi
50.000 ve üzeri high value- 30.000/50.000 arası medium- 30.000 altı low value

```sql
WITH CustomerPurchases AS (
    SELECT 
        c.customer_id,
        c.company_name,
        COUNT(o.order_id) AS number_of_orders,
        SUM(od.quantity * od.unit_price) AS total_spent
    FROM 
        customers AS c
    INNER JOIN 
        orders AS o ON c.customer_id = o.customer_id
    INNER JOIN 
        order_details AS od ON o.order_id = od.order_id
    GROUP BY 
        c.customer_id, c.company_name
)
SELECT 
    customer_id,
    company_name,
    number_of_orders,
    to_char(total_spent, 'FM$999,999,999.00') AS total_spent_formatted,
    CASE
        WHEN total_spent > 50000 THEN 'High Value'
        WHEN total_spent BETWEEN 30000 AND 50000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM 
    CustomerPurchases
ORDER BY 
    total_spent DESC;




