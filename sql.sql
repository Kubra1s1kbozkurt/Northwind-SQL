--1.Ürün Analizi
 --Yeniden satın alınan ürünler
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

--Output doğruluğuna bakmak için 59 id’li ürünün sipariş sayısına bakıldı.
select*from order_details
where product_id = 59
 
--2.Müşteri Analizi
--Bu müşterileri belirleyerek, onları sadık müşteri olarak tanımlayabilir ve özel kampanyalar düzenleyebiliriz.
--En çok sipariş veren firmalar, sipariş sayısı ve ülkeleri 

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


--Output doğruluğunu kontrol için Savea firmasının orders sayılarına bakıldı.
select*from orders where customer_id='SAVEA'

--Toplam firma harcamaları 
--50.000 ve üzeri high value- 30.000/50.000 arası medium- 30.000 altı low value

	
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


--3.Order Analizi
--Haftanın günleri bazlı order sayısı

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

-Yıllara göre aylık order sayısı

SELECT
    TO_CHAR(o.order_date, 'YYYY-MM') AS order_month,
    COUNT(o.order_id) AS number_of_orders
FROM
    orders AS o
GROUP BY
    TO_CHAR(o.order_date, 'YYYY-MM')
ORDER BY
    order_month;

-Aylık order sayısı
SELECT
    TO_CHAR(o.order_date, 'Month') AS order_month,
    COUNT(o.order_id) AS number_of_orders
FROM
    orders AS o
GROUP BY
    TO_CHAR(o.order_date, 'Month'),
    EXTRACT(MONTH FROM o.order_date)
ORDER BY
    EXTRACT(MONTH FROM o.order_date);

--Teslimat süresi *******
--Öncelikle müşterinin istediği tarih ve sipariş tarihi arasında geçen zamana bakıldı. Daha sonra sevk tarihi ve sipariş tarihi arasında ki fark incelendi ve istenen tarih ve sevk tarihi arasındaki fark incelendi. Teslim tarihi veri setinde yoktu.

SELECT 
    s."supplier_id",
    ROUND(AVG(o."required_date" - o."order_date")) AS average_last_day,
    ROUND(AVG(o."shipped_date" - o."order_date")) AS average_processing_days,
    ROUND(AVG(o."required_date" - o."shipped_date")) AS average_delivery_days
FROM 
    "orders" o
JOIN 
    "order_details" od ON o."order_id" = od."order_id"
JOIN 
    "products" p ON od."product_id" = p."product_id"
JOIN 
    "suppliers" s ON p."supplier_id" = s."supplier_id"
GROUP BY 
    s."supplier_id"
ORDER BY 
    average_processing_days, average_delivery_days;

4.Gelir analizi
-Aylık gelir analizi
(Discount oranı dahilinde gelir hesaplanmıştır.)

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

--Kategori bazlı aylık gelir analizi


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

--Yıl bazlı gelir analizi

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

--Kategori bazlı yıllık gelir analizi


SELECT 
    c."category_name" AS category,
    DATE_PART('year', o."order_date") AS year,
    TO_CHAR(SUM(od.quantity * od.unit_price * (1 - od.discount)), '$999,999,999.99') AS yearly_income
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
    DATE_PART('year', o."order_date")
ORDER BY 
    year,
    category;

--Yeniden satın alınan ürünlerde ilk 15 i getirip yıllık gelirini hesapladım.


WITH ReorderedProducts AS (
    SELECT 
        od."product_id",
        p."product_name",
        DATE_PART('year', o."order_date") AS year,
        SUM(od."quantity") AS total_quantity
    FROM 
        "orders" o
    JOIN 
        "order_details" od ON o."order_id" = od."order_id"
    JOIN 
        "products" p ON od."product_id" = p."product_id"
    WHERE 
        EXISTS (
            SELECT 1
            FROM "order_details" od2
            WHERE od2."product_id" = od."product_id"
              AND od2."order_id" <> od."order_id"
        )
    GROUP BY 
        od."product_id",
        p."product_name",
        DATE_PART('year', o."order_date")
),
RankedProducts AS (
    SELECT
        product_id,
        product_name,
        year,
        total_quantity,
        RANK() OVER (PARTITION BY year ORDER BY total_quantity DESC) AS rnk
    FROM
        ReorderedProducts
)
, Top5ReorderedProducts AS (
    SELECT
        product_id,
        product_name,
        year
    FROM
        RankedProducts
    WHERE
        rnk <= 5
)
SELECT 
    p."product_name",
    tp.year,
    TO_CHAR(SUM(od."quantity" * od."unit_price" * (1 - od."discount")), '$999,999,999.99') AS yearly_income
FROM 
    "order_details" od
JOIN 
    "products" p ON od."product_id" = p."product_id"
JOIN 
    Top5ReorderedProducts tp ON p."product_id" = tp."product_id"
GROUP BY 
    p."product_name",
    tp.year
ORDER BY 
    tp.year,
    yearly_income DESC;

--5.RFM Analizi

--"1998-05-05" en son alışveriş yapılan tarih 5 gün sonrası olan "1998-05-10" tarihini aldım
WITH max_o_d AS (
    SELECT customer_id,
           MAX(order_date) AS max_order_date
    FROM orders
    GROUP BY customer_id
),
recency AS (
    SELECT customer_id,
           max_order_date,
           ('1998-05-10'::date - max_order_date::date) AS recency
    FROM max_o_d
    
),
frequency AS (
    SELECT customer_id,
           COUNT(*) AS frequency
    FROM orders
    GROUP BY customer_id
),
monetary AS (
    SELECT o.customer_id,	
           ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 0) AS monetary
    FROM order_details od
    JOIN orders o ON od.order_id = o.order_id
    GROUP BY o.customer_id
),
scores AS (
    SELECT
        r.customer_id,
        r.recency,
        NTILE(5) OVER(ORDER BY r.recency DESC) AS recency_score,
        f.frequency,
        NTILE(5) OVER(ORDER BY f.frequency DESC) AS frequency_score, 
        m.monetary,
        NTILE(5) OVER(ORDER BY m.monetary ASC) AS monetary_score
    FROM recency r	
    LEFT JOIN frequency f ON r.customer_id = f.customer_id
    LEFT JOIN monetary m ON f.customer_id = m.customer_id
),
monetary_frequency AS (
    SELECT customer_id,
           recency_score,
           frequency_score + monetary_score AS mon_fre_score
    FROM scores
),
rfm_score AS (
    SELECT customer_id,
           recency_score,	
           NTILE(5) OVER(ORDER BY mon_fre_score) AS mon_fre_score
    FROM monetary_frequency
)
SELECT 
    customer_id,
    recency_score,
    frequency_score,
    monetary_score,
    (recency_score + frequency_score + monetary_score) AS total_score,
    ((recency_score + frequency_score + monetary_score) / 3) AS average_score
FROM 
   scores;

--6.Kohort Analizi


-- Müşterilerin ilk sipariş verdikleri ayı belirleme
WITH first_order AS (
    SELECT customer_id,
           MIN(DATE_TRUNC('month', order_date)) AS first_order_month
    FROM orders
    GROUP BY customer_id
),

-- Her sipariş için ilgili dönemi belirleme
orders_with_period AS (
    SELECT o.customer_id,
           o.order_id,
           DATE_TRUNC('month', o.order_date) AS order_month,
           fo.first_order_month,
           EXTRACT(YEAR FROM age(DATE_TRUNC('month', o.order_date), fo.first_order_month)) * 12 + 
           EXTRACT(MONTH FROM age(DATE_TRUNC('month', o.order_date), fo.first_order_month)) AS period
    FROM orders o
    JOIN first_order fo ON o.customer_id = fo.customer_id
)

-- Kohort analizi
SELECT 
    TO_CHAR(first_order_month, 'YYYY-MM') AS cohort_month,
    period,
    COUNT(DISTINCT owp.customer_id) AS num_customers,
    TO_CHAR(ROUND(SUM(od.quantity * od.unit_price * (1 - od.discount))::numeric, 2), 'FM$999,999,999.00') AS total_revenue
FROM 
    orders_with_period owp
JOIN
    order_details od ON owp.order_id = od.order_id
GROUP BY 
    first_order_month, period
ORDER BY 
    first_order_month, period;

--7.Çalışan Analizi
--Hangi çalışan ne kadar satış yaptı ve ne kadar gelir getirdi
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


