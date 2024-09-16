![Teslimat süresi](https://github.com/Kubra1s1kbozkurt/Northwind-SQL/blob/main/image/Teslimat%20s%C3%BCresi.png)

Teslimat süresi-
Öncelikle müşterinin istediği tarih ve sipariş tarihi arasında geçen zamana bakıldı. Daha sonra sevk tarihi ve sipariş tarihi arasında ki fark incelendi ve istenen tarih ve sevk tarihi arasındaki fark incelendi. Teslim tarihi veri setinde yoktu.
```sql
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


