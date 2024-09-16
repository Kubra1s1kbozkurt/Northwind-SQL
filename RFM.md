![RFM](https://github.com/Kubra1s1kbozkurt/Northwind-SQL/blob/main/image/RFM.png)

RFM Analizi

--"1998-05-05" en son alışveriş yapılan tarih 5 gün sonrası olan "1998-05-10" tarihini alındı
```sql
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

