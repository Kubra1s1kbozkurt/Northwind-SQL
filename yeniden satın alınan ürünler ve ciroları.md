![Gelir analizi](https://github.com/Kubra1s1kbozkurt/Northwind-SQL/blob/main/image/Yeniden%20sat%C4%B1n%20al%C4%B1nan%20%C3%BCr%C3%BCnlerin%20ciro%20analizi.png)

Yeniden satın alınan ürünler  ve yıllık gelirleri

```sql
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


