-- Du lieu mau. Mat khau cua tat ca tai khoan: 123456 (luu dang SHA-256)
USE qlst5_db;
SET NAMES utf8mb4;

INSERT INTO tblMember5 (id, username, password, fullName, birthday, address, email, phone, role, note) VALUES
 (1, 'quanly1',  SHA2('123456',256), 'Lê Quốc Quản',  '1985-03-12', 'Cầu Giấy, Hà Nội',   'quanly1@qlst.vn',  '0901000001', 'MANAGER',   NULL),
 (2, 'kho1',     SHA2('123456',256), 'Phạm Văn Kho',   '1990-07-21', 'Thanh Xuân, Hà Nội', 'kho1@qlst.vn',     '0901000002', 'WAREHOUSE', NULL),
 (3, 'banhang1', SHA2('123456',256), 'Trần Thị Bán',   '1995-11-02', 'Hà Đông, Hà Nội',    'banhang1@qlst.vn', '0901000003', 'SALES',     NULL),
 (4, 'khach1',   SHA2('123456',256), 'Nguyễn Văn B',   '1998-05-15', 'Số 96 Trần Phú, Hà Đông, Hà Nội', 'khach1@mail.com', '0912000004', 'CUSTOMER', NULL),
 (5, 'khach2',   SHA2('123456',256), 'Hoàng Thị C',    '2000-01-30', 'Long Biên, Hà Nội',  'khach2@mail.com',  '0912000005', 'CUSTOMER', NULL);

INSERT INTO tblEmployee5 (tblMember5id, position) VALUES
 (1, 'Quản lí'), (2, 'Nhân viên kho'), (3, 'Nhân viên bán hàng');

INSERT INTO tblCustomer5 (tblMember5id, registerDate) VALUES (4, '2026-01-10'), (5, '2026-02-18');

INSERT INTO tblShipper5 (id, fullName, phone) VALUES
 (1, 'Đỗ Văn Giao', '0933000001'), (2, 'Vũ Minh Tốc', '0933000002'), (3, 'Bùi Hữu Nhanh', '0933000003');

INSERT INTO tblCategory5 (id, name, description) VALUES
 (1, 'Tủ lạnh',  'Tủ lạnh các loại'),
 (2, 'Máy giặt', 'Máy giặt, máy giặt sấy'),
 (3, 'Tivi',     'Tivi thông minh'),
 (4, 'Điều hòa', 'Điều hòa nhiệt độ'),
 (5, 'Gia dụng', 'Nồi chiên, nồi cơm, máy xay...');

INSERT INTO tblProduct5 (id, name, brand, unit, importPrice, salePrice, quantityInStock, description, image, tblCategory5id) VALUES
 (1,  'Tủ lạnh Inverter 250L',      'Panasonic',  'Chiếc', 7200000,  8900000,  12, 'Tủ lạnh 2 cánh, ngăn đá trên', NULL, 1),
 (2,  'Tủ lạnh 4 cánh 500L',        'Samsung',    'Chiếc', 20000000, 24500000, 5,  'Tủ lạnh side by side 4 cánh',  NULL, 1),
 (3,  'Tủ lạnh mini 90L',           'Aqua',       'Chiếc', 2500000,  3200000,  0,  'Tủ lạnh mini cho phòng trọ',   NULL, 1),
 (10, 'Máy giặt cửa trước 9kg',     'Electrolux', 'Chiếc', 8500000,  10500000, 8,  'Máy giặt lồng ngang inverter', NULL, 2),
 (11, 'Máy giặt cửa trên 8.5kg',    'LG',         'Chiếc', 5300000,  6800000,  10, 'Máy giặt lồng đứng',           NULL, 2),
 (12, 'Máy giặt sấy 10kg',          'Samsung',    'Chiếc', 14500000, 17900000, 0,  'Máy giặt kèm sấy',             NULL, 2),
 (20, 'Tivi Smart 55 inch',         'Sony',       'Chiếc', 9800000,  12200000, 15, 'Tivi 4K Google TV',            NULL, 3),
 (21, 'Tivi Smart 43 inch',         'TCL',        'Chiếc', 4600000,  5900000,  20, 'Tivi Full HD',                 NULL, 3),
 (30, 'Điều hòa Inverter 12000BTU', 'Daikin',     'Bộ',    9200000,  11500000, 9,  'Điều hòa 1 chiều inverter',    NULL, 4),
 (40, 'Nồi chiên không dầu 5L',     'Philips',    'Chiếc', 1700000,  2300000,  25, 'Nồi chiên không dầu',          NULL, 5);

INSERT INTO tblSupplier5 (id, name, address, phone, email, contactPerson) VALUES
 (1, 'Công ty Điện máy Việt Á',      'Quận 1, TP.HCM',  '02838000001', 'sales@vieta.vn',     'Nguyễn Văn An'),
 (2, 'Công ty Phân phối Hoàng Long', 'Đống Đa, Hà Nội', '02438000002', 'info@hoanglong.vn',  'Trần Thị Bình');

INSERT INTO tblSupplierProduct5 (supplyPrice, tblSupplier5id, tblProduct5id) VALUES
 (7200000, 1, 1), (20000000, 1, 2), (8500000, 1, 10), (9800000, 2, 20), (4600000, 2, 21), (9200000, 2, 30);

-- Phieu nhap mau
INSERT INTO tblImportReceipt5 (id, importDate, tblSupplier5id, tblEmployee5id) VALUES
 (1, '2026-08-05', 1, 2),
 (2, '2026-09-01', 2, 2);
INSERT INTO tblImportDetail5 (quantity, unitPrice, tblImportReceipt5id, tblProduct5id) VALUES
 (10, 7200000, 1, 1), (5, 20000000, 1, 2), (8, 8500000, 1, 10),
 (15, 9800000, 2, 20), (10, 9200000, 2, 30);

-- Hoa don ban tai quay mau
INSERT INTO tblInvoice5 (id, saleDate, tblEmployee5id, tblCustomer5id) VALUES
 (1, '2026-09-10 14:20:00', 3, 4),
 (2, '2026-09-12 16:45:00', 3, NULL);
INSERT INTO tblInvoiceDetail5 (quantity, unitPrice, tblInvoice5id, tblProduct5id) VALUES
 (1, 8900000, 1, 1), (2, 2300000, 1, 40),
 (1, 12200000, 2, 20);

-- Don dat hang truc tuyen mau (1 hoan thanh, 1 cho duyet)
INSERT INTO tblOrder5 (id, orderDate, deliveryAddress, status, tblCustomer5id, tblEmployee5id, tblShipper5id) VALUES
 (1, '2026-09-05 08:15:00', 'Long Biên, Hà Nội', 'COMPLETED', 5, 2, 1),
 (2, '2026-09-15 19:30:00', 'Số 96 Trần Phú, Hà Đông, Hà Nội', 'PENDING', 4, NULL, NULL);
INSERT INTO tblOrderDetail5 (quantity, unitPrice, tblOrder5id, tblProduct5id) VALUES
 (1, 6800000, 1, 11),
 (1, 10500000, 2, 10), (2, 12200000, 2, 20);
