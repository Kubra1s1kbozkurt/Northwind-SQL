![Sipariş analizi](https://github.com/Kubra1s1kbozkurt/Northwind-SQL/blob/main/image/Sipari%C5%9F%20Analizi.png)


Order Analizi
Haftanın günleri bazlı order sayısı
```sql
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

