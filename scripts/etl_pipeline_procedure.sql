CREATE Schema Analytics;

CREATE TABLE Analytics.Fact_Sales_Performance (
	orders_id VARCHAR(50),
	customer_id VARCHAR(50),
	customer_state VARCHAR(10),
	product_id VARCHAR(50),
	product_category_english VARCHAR(100),
	order_purchase_timestamp DATETIME,
	actual_delivery_days INT,
	is_delayed INT,
	payment_value FLOAT,
	revenue FLOAT
); 

SELECT 
	o.order_id AS orders_id,
	o.customer_id,
	c.customer_state,
	i.product_id,
	ct.product_category_name_english,
	o.order_purchase_timestamp,
	DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date) AS actual_delivery_days,
	CASE 
		WHEN DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date) > DATEDIFF(DAY, o.order_purchase_timestamp, o.order_estimated_delivery_date) THEN 1
		ELSE 0
	END AS is_delayed,
	pay.payment_value,
	pay.payment_value - i.freight_value AS revenue
FROM Orders o
JOIN Items i ON o.order_id = i.order_id
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Products p ON i.product_id = p.product_id
LEFT JOIN [Category Translate] ct ON p.product_category_name = ct.product_category_name
LEFT JOIN Payments pay ON o.order_id = pay.order_id
WHERE o.order_status IN ('delivered', 'shipped');



DROP TABLE IF EXISTS Analytics.Fact_Sales_Performance;
GO


CREATE TABLE Analytics.Fact_Sales_Performance (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    customer_state VARCHAR(10),
    product_id VARCHAR(50),
    product_category_english NVARCHAR(100),
    order_purchase_timestamp DATETIME,
    actual_delivery_days INT,
    is_delayed INT,
    payment_value DECIMAL(10, 2),
    revenue DECIMAL(10, 2)    
);
GO



CREATE PROCEDURE Analytics.sp_Refresh_Sales_Pipeline
AS
BEGIN
    SET NOCOUNT ON;

    -- Clean table data
    TRUNCATE TABLE Analytics.Fact_Sales_Performance;

    -- Transform and Load data
    INSERT INTO Analytics.Fact_Sales_Performance (
        order_id, customer_id, customer_state, product_id, 
        product_category_english, order_purchase_timestamp, 
        actual_delivery_days, is_delayed, payment_value, revenue
    )
    SELECT 
        o.order_id,
        o.customer_id,
        c.customer_state,
        i.product_id,
        ISNULL(t.product_category_name_english, 'unknown'),
        o.order_purchase_timestamp,
        DATEDIFF(day, o.order_purchase_timestamp, o.order_delivered_customer_date),
        CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END,
        ROUND(p.payment_value, 2),
        ROUND(i.price, 2)
    FROM dbo.Orders o
    INNER JOIN dbo.Items i ON o.order_id = i.order_id
    INNER JOIN dbo.Customers c ON o.customer_id = c.customer_id
    INNER JOIN dbo.Products prod ON i.product_id = prod.product_id
    LEFT JOIN dbo.[Category Translate] t ON prod.product_category_name = t.product_category_name
    LEFT JOIN dbo.Payments p ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'; 

    PRINT 'ETL Pipeline executed and data cleaned successfully!';
END;
GO


-- execute procedure
EXEC Analytics.sp_Refresh_Sales_Pipeline;
GO

-- checking data
SELECT TOP 100 * FROM Analytics.Fact_Sales_Performance;
GO






