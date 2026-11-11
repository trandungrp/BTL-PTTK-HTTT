# QLST5 – Hệ thống quản lí siêu thị điện máy

Ứng dụng web **JSP + Servlet + JDBC + MySQL**, chạy trên **Tomcat 9**, build bằng **Maven**.
Triển khai theo tài liệu phân tích & thiết kế (mã đề 8 – B23DCCN215).

Toàn bộ dự án chạy bằng **lệnh terminal (PowerShell)**, không dùng Docker.

---

## 1. Cấu trúc thư mục

```
pttk httt/
├── README.md                     ← file hướng dẫn này
├── mysql-root-credentials.txt    ← mật khẩu MySQL root (bí mật, không chia sẻ)
├── .setup-downloads/             ← bản sao biến môi trường trước khi cài đặt (để khôi phục nếu cần)
├── phan tich/                    ← tài liệu phân tích (.docx)
├── thiet ke/                     ← tài liệu thiết kế (.docx)
├── docs j2ee/                    ← tài liệu LAB
└── trien khai/                   ← MÃ NGUỒN
    ├── pom.xml                   cấu hình Maven (sourceDirectory=src, warSourceDirectory=WebContent)
    ├── sql/
    │   ├── 01_schema.sql         tạo CSDL qlst5_db + 16 bảng
    │   └── 02_seed.sql           dữ liệu mẫu
    ├── src/
    │   ├── model/                lớp thực thể (Member5, Customer5, Product5, Order5, …)
    │   ├── dao/                  DAO5 (kết nối chung) + ProductDAO5, OrderDAO5, CartDAO5, …
    │   ├── filter/AuthFilter5.java   UTF-8 + phân quyền theo gói view
    │   ├── util/Util5.java
    │   └── db.properties         cấu hình kết nối JDBC
    └── WebContent/
        ├── META-INF/MANIFEST.MF
        ├── WEB-INF/              web.xml, *.jspf, lib/mysql-connector-j-8.3.0.jar
        ├── Error.jsp, index.jsp, assets/style.css
        └── view/                 member/ customer/ warehouse/ sales/ manager/
```

---

## 2. Yêu cầu phần mềm

| Phần mềm | Phiên bản | Đường dẫn trên máy này |
|---|---|---|
| JDK | 17 trở lên (đang dùng 21) | `C:\Program Files\Java\jdk-21.0.12.1` |
| Apache Maven | 3.x | `C:\Users\dungp\Tools\apache-maven-3.10.0` |
| Apache Tomcat | **9.x** (không dùng 10+ vì code dùng `javax.servlet`) | `C:\Users\dungp\Tools\apache-tomcat-9.0.123` |
| MySQL Server | 8.0 (dịch vụ Windows `MySQL80`) | `C:\Program Files\MySQL\MySQL Server 8.0` |

Các biến môi trường người dùng **đã được cấu hình sẵn**:

- `JAVA_HOME`   = `C:\Program Files\Java\jdk-21.0.12.1`
- `MAVEN_HOME`  = `C:\Users\dungp\Tools\apache-maven-3.10.0`
- `CATALINA_HOME` = `C:\Users\dungp\Tools\apache-tomcat-9.0.123`
- `Path` có thêm `...\apache-maven-3.10.0\bin` và `...\jdk-21.0.12.1\bin`

Kiểm tra (mở **PowerShell mới** để nhận biến môi trường):

```powershell
java -version
mvn -version
echo $env:CATALINA_HOME
Get-Service MySQL80
```

> Cài trên máy khác: cài JDK 17+, MySQL 8.0; tải và giải nén Maven và Tomcat 9 (bản zip);
> rồi đặt các biến môi trường như trên (Settings → System → About → Advanced system settings → Environment Variables).

---

## 3. Chuẩn bị CSDL (chỉ làm lần đầu, hoặc khi muốn reset dữ liệu)

CSDL `qlst5_db` (16 bảng) **đã được tạo sẵn** trên máy này. Chỉ chạy lại bước này nếu muốn tạo mới/reset.

> ⚠️ `01_schema.sql` sẽ **xoá toàn bộ bảng cũ** rồi tạo lại → mất dữ liệu đang có.

### 3.1 Bật MySQL

```powershell
Get-Service MySQL80          # Status phải là Running
Start-Service MySQL80        # nếu đang Stopped (cần PowerShell quyền Administrator)
```

### 3.2 Nạp schema + dữ liệu mẫu bằng terminal

```powershell
cd "C:\Users\dungp\Downloads\pttk httt\trien khai"
$mysql = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"

& $mysql -u root -p --default-character-set=utf8mb4 -e "source sql/01_schema.sql"
& $mysql -u root -p --default-character-set=utf8mb4 -e "source sql/02_seed.sql"
```

Nhập mật khẩu root khi được hỏi (xem file `mysql-root-credentials.txt`, dòng `Password:`).

Kiểm tra:

```powershell
& $mysql -u root -p -e "SELECT COUNT(*) AS so_bang FROM information_schema.tables WHERE table_schema='qlst5_db';"
# Kết quả mong đợi: 16
```

*(Cách khác: mở MySQL Workbench → File → Open SQL Script → chạy lần lượt 2 file trên bằng nút ⚡.)*

---

## 4. Cấu hình kết nối CSDL

File [trien khai/src/db.properties](trien%20khai/src/db.properties):

```properties
db.url=jdbc:mysql://localhost:3306/qlst5_db?useUnicode=true&characterEncoding=UTF-8&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Ho_Chi_Minh
db.user=root
db.password=<mật khẩu root MySQL>
```

Trên máy này `db.password` **đã điền sẵn** đúng mật khẩu trong `mysql-root-credentials.txt`.
Nếu đổi mật khẩu MySQL thì sửa file này rồi **build lại** (mục 5).

Có thể ghi đè tạm thời bằng biến môi trường (không cần build lại), đặt **trước khi** khởi động Tomcat:

```powershell
$env:DB_URL  = "jdbc:mysql://localhost:3306/qlst5_db?useUnicode=true&characterEncoding=UTF-8&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Ho_Chi_Minh"
$env:DB_USER = "root"
$env:DB_PASS = "mat_khau"
```

---

## 5. Chạy dự án bằng terminal

Mở **PowerShell** và chạy lần lượt:

### Bước 1 – Build file WAR

```powershell
cd "C:\Users\dungp\Downloads\pttk httt\trien khai"
mvn clean package
```

Kết quả: `trien khai\target\qlst5.war` (`BUILD SUCCESS`).

### Bước 2 – Triển khai WAR vào Tomcat

```powershell
Remove-Item "$env:CATALINA_HOME\webapps\qlst5" -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item target\qlst5.war "$env:CATALINA_HOME\webapps\" -Force
```

(Dòng đầu xoá bản giải nén cũ để Tomcat chắc chắn dùng bản mới.)

### Bước 3 – Khởi động Tomcat

```powershell
$env:CATALINA_OPTS = "-Dfile.encoding=UTF-8 -Duser.timezone=Asia/Ho_Chi_Minh"
& "$env:CATALINA_HOME\bin\catalina.bat" run
```

Tomcat chạy ngay trong cửa sổ terminal (log hiện trực tiếp). Khi thấy dòng
`Server startup in [...] milliseconds` là xong.

### Bước 4 – Mở trình duyệt

👉 **http://localhost:8080/qlst5/**

### Dừng dự án

Bấm **Ctrl + C** trong cửa sổ terminal đang chạy Tomcat.

### Cách chạy nền (tuỳ chọn)

Thay Bước 3 bằng:

```powershell
$env:CATALINA_OPTS = "-Dfile.encoding=UTF-8 -Duser.timezone=Asia/Ho_Chi_Minh"
& "$env:CATALINA_HOME\bin\startup.bat"     # mở Tomcat ở cửa sổ riêng
```

Dừng bằng:

```powershell
& "$env:CATALINA_HOME\bin\shutdown.bat"
```

### Tóm tắt – chạy nhanh (copy cả khối)

```powershell
cd "C:\Users\dungp\Downloads\pttk httt\trien khai"
mvn clean package
Remove-Item "$env:CATALINA_HOME\webapps\qlst5" -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item target\qlst5.war "$env:CATALINA_HOME\webapps\" -Force
$env:CATALINA_OPTS = "-Dfile.encoding=UTF-8 -Duser.timezone=Asia/Ho_Chi_Minh"
& "$env:CATALINA_HOME\bin\catalina.bat" run
```

Sau khi sửa code (Java hoặc JSP): `Ctrl + C` để dừng → chạy lại cả khối trên.

---

## 6. Tài khoản mẫu

Mật khẩu tất cả: **`123456`**

| Tên đăng nhập | Vai trò |
|---|---|
| `khach1`, `khach2` | Khách hàng |
| `kho1` | Nhân viên kho |
| `banhang1` | Nhân viên bán hàng |
| `quanly1` | Nhân viên quản lí |

---

## 7. Xử lí lỗi thường gặp

| Hiện tượng | Nguyên nhân / cách xử lí |
|---|---|
| `mvn` / `java` is not recognized | Mở **cửa sổ PowerShell mới** để nạp biến môi trường; kiểm tra `Path` (mục 2). |
| `Address already in use` / cổng 8080 bận | Có Tomcat khác đang chạy. Chạy `& "$env:CATALINA_HOME\bin\shutdown.bat"` hoặc tìm tiến trình: `Get-NetTCPConnection -LocalPort 8080 -State Listen \| Select OwningProcess` rồi `Stop-Process -Id <PID>`. |
| Trang báo *Khong ket noi duoc CSDL qlst5_db* | MySQL chưa chạy (`Start-Service MySQL80`), sai mật khẩu trong `db.properties`, hoặc chưa tạo CSDL (mục 3). |
| 404 tại `/qlst5/` | Chưa copy `qlst5.war` vào `webapps`, hoặc Tomcat chưa deploy xong – xem log trong terminal hoặc `$env:CATALINA_HOME\logs\catalina.<ngày>.log`. |
| Lỗi tiếng Việt bị vỡ font | Thiếu `CATALINA_OPTS` ở Bước 3; khi nạp SQL nhớ có `--default-character-set=utf8mb4`. |
| Lỗi `jakarta.servlet` / ClassNotFound servlet | Đang dùng Tomcat 10+. Phải dùng **Tomcat 9**. |

Log Tomcat: thư mục `C:\Users\dungp\Tools\apache-tomcat-9.0.123\logs\`.

---

## 8. Chạy bằng IDE (tuỳ chọn)

Eclipse / NetBeans / IntelliJ: mở thư mục `trien khai` như **dự án Maven** (hoặc Dynamic Web Project với source `src`, web content `WebContent`),
thêm server **Tomcat 9**, Run. Context path `/qlst5`.

---

## 9. Chức năng và trang tương ứng

| Tác nhân | Chức năng | Trang (`WebContent/view/...`) |
|---|---|---|
| Thành viên | Đăng nhập, đăng xuất, đổi mật khẩu | `member/LoginGUI5`, `doLogin5`, `doLogout5`, `ChangePasswordGUI5` |
| Khách hàng | Đăng kí thành viên | `member/RegisterGUI5` |
| | Tìm kiếm mặt hàng | `customer/SearchProductGUI5` |
| | **Đặt hàng trực tuyến** (module chi tiết) | `CustomerMainGUI5 → OrderGUI5 → AddToCartGUI5 → doAddToCart5 → CartGUI5 → doSubmitOrder5` |
| Nhân viên kho | **Sửa thông tin mặt hàng** (module chi tiết) | `WarehouseMainGUI5 → ProductManagementGUI5 → SearchProductGUI5 → UpdateProductGUI5 → doUpdateProduct5` |
| | Thêm / xóa mặt hàng | `AddProductGUI5`, `doAddProduct5`, `doDeleteProduct5` |
| | Cập nhật nhà cung cấp | `SupplierManagementGUI5`, `EditSupplierGUI5`, `doSaveSupplier5`, `doDeleteSupplier5` |
| | Nhập hàng | `ImportGoodsGUI5` |
| | Duyệt đơn online, xuất giao hàng | `ApproveOrderGUI5`, `doApproveOrder5`, `DeliveryNoteGUI5` |
| Nhân viên bán hàng | Bán hàng tại quầy | `sales/SalesMainGUI5`, `SellAtCounterGUI5`, `InvoiceGUI5` |
| Nhân viên quản lí | Thống kê mặt hàng / nhà cung cấp / doanh thu | `manager/ManagerMainGUI5`, `ViewStatisticsGUI5`, `ProductStatisticGUI5`, `SupplierStatisticGUI5`, `RevenueStatisticGUI5`, `RevenueDetailGUI5` |

Các trang JSP được Tomcat biên dịch thành Servlet; `AuthFilter5` (Servlet Filter) chặn truy cập theo vai trò.

---

## 10. Ánh xạ với thiết kế

- **Thực thể** (Hình 1): `src/model` – kế thừa `Member5 → Customer5 / Employee5 → Manager5, WarehouseStaff5, Salesperson5`; composition `Order5 ◆ OrderDetail5`, `Cart5 ◆ CartItem5`…; thống kê `ProductStatistic5`, `SupplierStatistic5`, `RevenueStatistic5`.
- **DAO**: `src/dao`, mọi DAO kế thừa `DAO5` (thuộc tính `con : Connection`). `OrderDAO5.saveOrder()` gọi `OrderDetailDAO5.saveOrderDetail()` trên **cùng kết nối** trong một transaction. Chữ kí phương thức đúng Hình 4, Hình 6 (`X[]` trong biểu đồ ↔ `List<X>` trong Java):
  - `ProductDAO5`: `getProductsByName(name) : List<Product5>`, `getProductDetail(id) : Product5`, `updateProduct(product, categoryId) : boolean`, `checkStock(listItem) : boolean`
  - `CategoryDAO5`: `getAllCategories() : List<Category5>` (mỗi `Category5` đóng gói kèm `listProduct`)
  - `CartDAO5`: `getCartOfCustomer(customerId) : Cart5`, `addItem(cartId, item) : boolean`, `getItems(cartId) : List<CartItem5>`, `clearCart(cartId) : boolean`
  - `OrderDAO5`: `saveOrder(order) : boolean` (gán mã đơn vào `order.id`); `OrderDetailDAO5`: `saveOrderDetail(orderId, listDetail) : boolean`
  - `Cart5.calculateTotal() : double` giữ ở lớp thực thể.
- **Trang JSP** của 2 module: tên biến / tên control đúng thuộc tính trong Hình 4, Hình 6 (`inProductName`, `subSearch`, `outsubListProduct`, `listProduct`, `inoutName`…`inoutImage : file`, `subUpdate`, `subCancel`, `product`, `listCategory`, `outCartCount`, `subViewCart`, `cart`, `outProduct`, `inQuantity`, `subAddToCart`, `cartItem`, `inoutListItem`, `outTotal`, `inDeliveryAddress`, `subSubmit`, `subCancelCart`, `outOrder`, `order`, `staff`, `customer`). `doUpdateProduct5.jsp`, `doAddToCart5.jsp` hiện trang thông báo có nút OK như Hình 3, Hình 5. Ảnh mặt hàng upload vào `WebContent/assets/images/`.
- **CSDL 16 bảng** (Hình 2): `sql/01_schema.sql`.
- **Gói view** (Hình 11) và **triển khai J2EE** (Hình 12: Tomcat 9 + MySQL 8, `qlst5.war`).

## 11. Quy tắc nghiệp vụ

- `unitPrice` trong các bảng chi tiết là giá tại thời điểm giao dịch; `totalAmount` và thống kê là dữ liệu dẫn xuất, tính từ chi tiết.
- Luồng đơn online: `Chờ duyệt → Đã duyệt (xuất giao) → Hoàn thành` hoặc `Từ chối`. Tồn kho trừ khi kho **duyệt** đơn (kiểm tra nguyên tử). Doanh thu = hóa đơn tại quầy + đơn **Hoàn thành**.
- Mật khẩu lưu SHA-256. `tblManager5`, `tblWarehouseStaff5`, `tblSalesperson5` đã bị loại (bước 5 thiết kế CSDL); vai trò phân biệt bằng `tblMember5.role` và `tblEmployee5.position`.
- Tên loại hàng của một mặt hàng được tra qua `Category5.listProduct` (quan hệ aggregation Hình 1), không thêm thuộc tính vào `Product5`.
- Bổ sung nhỏ ngoài tài liệu (các chức năng không có thiết kế chi tiết): trang thêm/xóa mặt hàng, `DeliveryNoteGUI5`, `InvoiceGUI5`.
