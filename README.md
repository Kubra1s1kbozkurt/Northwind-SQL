Ürün analizi-Yeniden satın alınan ürünleri listeleme
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

![Ürün analizi-Yeniden satın alınan ürünleri listeleme](https://github.com/Kubra1s1kbozkurt/Northwind-SQL/blob/main/image/%C3%9Cr%C3%BCn%20Analizi.png)

En çok sipariş veren firmalar, sipariş sayısı ve ülkeleri 
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

![Müşteri analizi](https://github.com/Kubra1s1kbozkurt/Northwind-SQL/blob/main/image/M%C3%BC%C5%9Fteri%20Analizi.png)

Müşteri Analizi
 
50.000 ve üzeri high value- 30.000/50.000 arası medium- 30.000 altı low value

	
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

![Müşteri Analizi](https://github.com/Kubra1s1kbozkurt/Northwind-SQL/blob/main/image/M%C3%BC%C5%9Fteri%20Analizi2.png)

Order Analizi
Haftanın günleri bazlı order sayısı

WITH WeekDays AS (
    SELECT 'Monday' AS day_name, 1 AS day_number
    UNION SELECT 'Tuesday', 2
    UNION SELECT 'Wednesday', 3
    UNION SELECT 'Thursday', 4
    UNION SELECT 'Friday', 5
    UNION SELECT 'Saturday', 6
    UNION SELECT 'Sunday', 7
),
OrderCounts AS (
    SELECT
        TO_CHAR(o.order_date, 'Day') AS order_day,
        TO_CHAR(o.order_date, 'D')::int AS day_number,
        COUNT(o.order_id) AS number_of_orders
    FROM
        orders AS o
    GROUP BY
        TO_CHAR(o.order_date, 'Day'),
        TO_CHAR(o.order_date, 'D')
)
SELECT
    wd.day_name AS order_day,
    wd.day_number,
    COALESCE(oc.number_of_orders, 0) AS number_of_orders
FROM
    WeekDays AS wd
LEFT JOIN
    OrderCounts AS oc ON wd.day_number = oc.day_number
ORDER BY
    wd.day_number;

![Sipariş analizi](https://github.com/Kubra1s1kbozkurt/Northwind-SQL/blob/main/image/Sipari%C5%9F%20Analizi.png)


