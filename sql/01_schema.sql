-- =====================================================================
-- CSDL qlst5_db - He thong quan ly sieu thi dien may (QLST5)
-- Theo thiet ke CSDL (Hinh 2): 16 bang, MySQL 8.0
-- Da bo: tblManager5, tblWarehouseStaff5, tblSalesperson5 (chi con khoa ngoai),
--        cac bang thong ke (du lieu dan xuat), cot totalAmount (dan xuat).
-- Vai tro nhan vien phan biet bang tblMember5.role va tblEmployee5.position.
-- =====================================================================
CREATE DATABASE IF NOT EXISTS qlst5_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE qlst5_db;
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS tblInvoiceDetail5, tblInvoice5, tblOrderDetail5, tblOrder5,
  tblCartItem5, tblCart5, tblImportDetail5, tblImportReceipt5, tblSupplierProduct5,
  tblSupplier5, tblProduct5, tblCategory5, tblShipper5, tblEmployee5, tblCustomer5, tblMember5;

SET FOREIGN_KEY_CHECKS = 1;

-- ---------------- Nhom con nguoi ----------------
CREATE TABLE tblMember5 (
  id        INT          NOT NULL AUTO_INCREMENT,
  username  VARCHAR(255) NOT NULL,
  password  VARCHAR(255) NOT NULL COMMENT 'SHA-256 hex',
  fullName  VARCHAR(255) NOT NULL,
  birthday  DATE         NULL,
  address   VARCHAR(255) NULL,
  email     VARCHAR(255) NULL,
  phone     VARCHAR(20)  NULL,
  role      VARCHAR(50)   NOT NULL COMMENT 'CUSTOMER | MANAGER | WAREHOUSE | SALES',
  note      VARCHAR(255) NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_member_username (username)
) ENGINE=InnoDB;

CREATE TABLE tblCustomer5 (
  tblMember5id INT  NOT NULL,
  registerDate DATE NOT NULL,
  PRIMARY KEY (tblMember5id),
  CONSTRAINT fk_customer_member FOREIGN KEY (tblMember5id) REFERENCES tblMember5(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE tblEmployee5 (
  tblMember5id INT         NOT NULL,
  position     VARCHAR(50) NOT NULL,
  PRIMARY KEY (tblMember5id),
  CONSTRAINT fk_employee_member FOREIGN KEY (tblMember5id) REFERENCES tblMember5(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE tblShipper5 (
  id       INT          NOT NULL AUTO_INCREMENT,
  fullName VARCHAR(255) NOT NULL,
  phone    VARCHAR(20)  NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB;

-- ---------------- Nhom hang hoa ----------------
CREATE TABLE tblCategory5 (
  id          INT          NOT NULL AUTO_INCREMENT,
  name        VARCHAR(255) NOT NULL,
  description VARCHAR(255) NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB;

CREATE TABLE tblProduct5 (
  id              INT           NOT NULL AUTO_INCREMENT,
  name            VARCHAR(255)  NOT NULL,
  brand           VARCHAR(100)  NULL,
  unit            VARCHAR(20)   NULL,
  importPrice     DECIMAL(15,2) NOT NULL DEFAULT 0,
  salePrice       DECIMAL(15,2) NOT NULL DEFAULT 0,
  quantityInStock INT           NOT NULL DEFAULT 0,
  description     VARCHAR(1000) NULL,
  image           VARCHAR(255)  NULL,
  tblCategory5id  INT           NOT NULL,
  PRIMARY KEY (id),
  KEY idx_product_name (name),
  CONSTRAINT fk_product_category FOREIGN KEY (tblCategory5id) REFERENCES tblCategory5(id)
) ENGINE=InnoDB;

CREATE TABLE tblSupplier5 (
  id            INT          NOT NULL AUTO_INCREMENT,
  name          VARCHAR(255) NOT NULL,
  address       VARCHAR(255) NULL,
  phone         VARCHAR(20)  NULL,
  email         VARCHAR(255) NULL,
  contactPerson VARCHAR(255) NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB;

CREATE TABLE tblSupplierProduct5 (
  id             INT           NOT NULL AUTO_INCREMENT,
  supplyPrice    DECIMAL(15,2) NOT NULL DEFAULT 0,
  tblSupplier5id INT           NOT NULL,
  tblProduct5id  INT           NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_supplier_product (tblSupplier5id, tblProduct5id),
  CONSTRAINT fk_sp_supplier FOREIGN KEY (tblSupplier5id) REFERENCES tblSupplier5(id) ON DELETE CASCADE,
  CONSTRAINT fk_sp_product  FOREIGN KEY (tblProduct5id)  REFERENCES tblProduct5(id)
) ENGINE=InnoDB;

-- ---------------- Nhom giao dich ----------------
CREATE TABLE tblImportReceipt5 (
  id             INT      NOT NULL AUTO_INCREMENT,
  importDate     DATE     NOT NULL,
  tblSupplier5id INT      NOT NULL,
  tblEmployee5id INT      NOT NULL COMMENT 'nhan vien kho lap phieu',
  PRIMARY KEY (id),
  CONSTRAINT fk_ir_supplier FOREIGN KEY (tblSupplier5id) REFERENCES tblSupplier5(id),
  CONSTRAINT fk_ir_employee FOREIGN KEY (tblEmployee5id) REFERENCES tblEmployee5(tblMember5id)
) ENGINE=InnoDB;

CREATE TABLE tblImportDetail5 (
  id                  INT           NOT NULL AUTO_INCREMENT,
  quantity            INT           NOT NULL,
  unitPrice           DECIMAL(15,2) NOT NULL,
  tblImportReceipt5id INT           NOT NULL,
  tblProduct5id       INT           NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_id_receipt FOREIGN KEY (tblImportReceipt5id) REFERENCES tblImportReceipt5(id) ON DELETE CASCADE,
  CONSTRAINT fk_id_product FOREIGN KEY (tblProduct5id) REFERENCES tblProduct5(id)
) ENGINE=InnoDB;

CREATE TABLE tblCart5 (
  id             INT      NOT NULL AUTO_INCREMENT,
  createdDate    DATETIME NOT NULL,
  tblCustomer5id INT      NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_cart_customer (tblCustomer5id),
  CONSTRAINT fk_cart_customer FOREIGN KEY (tblCustomer5id) REFERENCES tblCustomer5(tblMember5id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE tblCartItem5 (
  id            INT NOT NULL AUTO_INCREMENT,
  quantity      INT NOT NULL,
  tblCart5id    INT NOT NULL,
  tblProduct5id INT NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_cart_product (tblCart5id, tblProduct5id),
  CONSTRAINT fk_ci_cart    FOREIGN KEY (tblCart5id)    REFERENCES tblCart5(id) ON DELETE CASCADE,
  CONSTRAINT fk_ci_product FOREIGN KEY (tblProduct5id) REFERENCES tblProduct5(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE tblOrder5 (
  id              INT          NOT NULL AUTO_INCREMENT,
  orderDate       DATETIME     NOT NULL,
  deliveryAddress VARCHAR(255) NOT NULL,
  status          VARCHAR(30)  NOT NULL COMMENT 'PENDING | APPROVED | COMPLETED | REJECTED',
  tblCustomer5id  INT          NOT NULL,
  tblEmployee5id  INT          NULL COMMENT 'nhan vien kho duyet - NULL khi cho duyet',
  tblShipper5id   INT          NULL COMMENT 'NULL khi chua xuat giao',
  PRIMARY KEY (id),
  CONSTRAINT fk_order_customer FOREIGN KEY (tblCustomer5id) REFERENCES tblCustomer5(tblMember5id),
  CONSTRAINT fk_order_employee FOREIGN KEY (tblEmployee5id) REFERENCES tblEmployee5(tblMember5id),
  CONSTRAINT fk_order_shipper  FOREIGN KEY (tblShipper5id)  REFERENCES tblShipper5(id)
) ENGINE=InnoDB;

CREATE TABLE tblOrderDetail5 (
  id            INT           NOT NULL AUTO_INCREMENT,
  quantity      INT           NOT NULL,
  unitPrice     DECIMAL(15,2) NOT NULL COMMENT 'gia tai thoi diem dat',
  tblOrder5id   INT           NOT NULL,
  tblProduct5id INT           NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_od_order   FOREIGN KEY (tblOrder5id)   REFERENCES tblOrder5(id) ON DELETE CASCADE,
  CONSTRAINT fk_od_product FOREIGN KEY (tblProduct5id) REFERENCES tblProduct5(id)
) ENGINE=InnoDB;

CREATE TABLE tblInvoice5 (
  id             INT      NOT NULL AUTO_INCREMENT,
  saleDate       DATETIME NOT NULL,
  tblEmployee5id INT      NOT NULL COMMENT 'nhan vien ban hang',
  tblCustomer5id INT      NULL COMMENT 'NULL voi khach vang lai',
  PRIMARY KEY (id),
  CONSTRAINT fk_inv_employee FOREIGN KEY (tblEmployee5id) REFERENCES tblEmployee5(tblMember5id),
  CONSTRAINT fk_inv_customer FOREIGN KEY (tblCustomer5id) REFERENCES tblCustomer5(tblMember5id)
) ENGINE=InnoDB;

CREATE TABLE tblInvoiceDetail5 (
  id            INT           NOT NULL AUTO_INCREMENT,
  quantity      INT           NOT NULL,
  unitPrice     DECIMAL(15,2) NOT NULL COMMENT 'gia tai thoi diem ban',
  tblInvoice5id INT           NOT NULL,
  tblProduct5id INT           NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_ivd_invoice FOREIGN KEY (tblInvoice5id) REFERENCES tblInvoice5(id) ON DELETE CASCADE,
  CONSTRAINT fk_ivd_product FOREIGN KEY (tblProduct5id) REFERENCES tblProduct5(id)
) ENGINE=InnoDB;
