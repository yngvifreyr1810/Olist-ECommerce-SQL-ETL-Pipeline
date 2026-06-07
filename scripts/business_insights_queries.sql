--Tinh Tong Doanh Thu va So Luong Don Hang theo Danh Muc San Pham
SELECT product_category_english, COUNT(DISTINCT order_id) AS SoLuongDonHang,SUM(revenue) AS TongDoanhThu
FROM Analytics.Fact_Sales_Performance
GROUP BY product_category_english
ORDER BY TongDoanhThu DESC;
--Giao hang tre theo Bang
SELECT customer_state AS Bang,COUNT(order_id) AS TongDonHAng,AVG(actual_delivery_days) AS TBSoNgayCho, SUM(is_delayed) AS SoLuongGiaoTre
FROM Analytics.Fact_Sales_Performance
GROUP BY customer_state
ORDER BY SoLuongGiaoTre DESC;