package dao;

/** Loi truy xuat du lieu (unchecked) de cac trang JSP khong phai bat SQLException. */
public class DataAccessException5 extends RuntimeException {
    public DataAccessException5(String message, Throwable cause) { super(message, cause); }
    public DataAccessException5(String message) { super(message); }
}
