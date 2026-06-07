# E-Commerce Analytics Data Pipeline (MS SQL Server)

## 📌 Tổng quan dự án
Dự án này tập trung xây dựng một hệ thống đường ống dữ liệu phân tích (Analytics Data Pipeline) chuẩn quy trình **ETL (Extract - Transform - Load)** từ nguồn dữ liệu thô của chuỗi bán lẻ Olist E-Commerce (Brazil) với quy mô gần 100,000 bản ghi giao dịch. Mục tiêu là làm sạch, tái cấu trúc dữ liệu thô lộn xộn thành một mô hình dữ liệu tinh gọn, sẵn sàng phục vụ cho việc ra quyết định kinh doanh.

## 🛠 Công cụ sử dụng
* **Hệ quản trị CSDL:** Microsoft SQL Server (MS SQL Server)
* **Công cụ thao tác:** SQL Server Management Studio (SSMS)
* **Kỹ thuật SQL sử dụng:** Stored Procedure, Schema Segregation, JOINs, Window Functions, Truncate & Insert, Data Type Optimization (DECIMAL vs FLOAT).

## 🚀 Kiến trúc đường ống dữ liệu (ETL Pipeline)
Dự án được phân tách rạch ròi thành 2 tầng dữ liệu bằng cách sử dụng **Schema** để đảm bảo tính an toàn hệ thống:
1.  **Tầng Dữ liệu thô (Raw Layer - `dbo`):** Nơi lưu trữ 9 bảng dữ liệu gốc được import trực tiếp từ file CSV.
2.  **Tầng Phân tích (Analytics Layer - `Analytics`):** Nơi chứa bảng dữ liệu đích (`Fact_Sales_Performance`) đã được làm sạch hoàn toàn.

Toàn bộ logic làm sạch và gộp bảng được đóng gói vào một **Stored Procedure** tự động hóa (`Analytics.sp_Refresh_Sales_Pipeline`), hoạt động theo cơ chế **Truncate & Insert** giúp cập nhật dữ liệu sạch chỉ với 1 dòng lệnh.

## 🧼 Quá trình làm sạch dữ liệu (Data Quality & Cleaning)
Trong quá trình xử lý dữ liệu thực tế, tôi đã phát hiện và xử lý thành công 3 bài toán lớn về chất lượng dữ liệu:
* **Sửa lỗi mất dòng tiêu đề (Header):** Khắc phục tình trạng công cụ import nhận diện sai dòng tiêu đề thành dữ liệu ở bảng dịch thuật, tiến hành đổi tên cột mặc định (`column1`, `column2`) về đúng cấu trúc chuẩn.
* **Xử lý bất đồng bộ khóa ngoại (Foreign Key Conflict):** Phát hiện bảng sản phẩm chứa các mã danh mục không tồn tại ở bảng dịch thuật (gây lỗi 547). Đã xử lý bằng cách chuyển các giá trị lỗi về `NULL` để bảo toàn dữ liệu giao dịch.
* **Lỗi chính xác số thực (Floating-Point Precision):** Xử lý hiện tượng nhiễu đuôi thập phân dài do kiểu dữ liệu `FLOAT` thô gây ra, tối ưu hóa lại cấu trúc bảng đích sang kiểu `DECIMAL(10,2)` phối hợp hàm `ROUND()`.

## 📊 Kết quả Phân tích Kinh doanh (Key Insights)
Từ tầng dữ liệu sạch, hệ thống đã trích xuất được các thông tin chiến lược:
1.  **Mũi nhọn doanh thu:** Xác định chính xác các danh mục sản phẩm đóng góp tài chính lớn nhất cho doanh nghiệp để tối ưu ngân sách Marketing.
2.  **Khủng hoảng vận hành (Logistics):** Áp dụng tư duy trọng số phân tích, sắp xếp dữ liệu theo **Tổng số đơn hàng bị trễ hạn (`SUM(is_delayed)`)** thay vì số ngày chờ trung bình. Phát hiện ra bang São Paulo (SP) tuy có thời gian giao hàng nhanh nhưng lại là nơi tập trung "đám cháy" lớn nhất với lượng đơn trễ khổng lồ, giúp doanh nghiệp ưu tiên nguồn lực điều phối đối tác vận chuyển chặng cuối tại đây.
