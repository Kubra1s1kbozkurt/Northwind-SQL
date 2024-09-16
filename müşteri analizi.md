![Müşteri analizi](https://github.com/Kubra1s1kbozkurt/Northwind-SQL/blob/main/image/M%C3%BC%C5%9Fteri%20Analizi.png)

En çok sipariş veren firmalar, sipariş sayısı ve ülkeleri 
```sql
WITH CustomerOrderCounts AS (
    SELECT 
        c.customer_id,
        c.company_name,
        COUNT(o.order_id) AS total_orders
    FROM 
        customers AS c
    LEFT JOIN 
        orders AS o ON c.customer_id = o.customer_id
    GROUP BY 
        c.customer_id, c.company_name
),
TopCustomers AS (
    SELECT 
        customer_id,
        company_name,
        total_orders
    FROM 
        CustomerOrderCounts
    ORDER BY 
        total_orders DESC
)
SELECT 
    tc.customer_id,
    tc.company_name,
    tc.total_orders,
    c.country AS customer_country
FROM 
    TopCustomers AS tc
INNER JOIN 
    customers AS c ON tc.customer_id = c.customer_id
ORDER BY 
    tc.total_orders DESC;

