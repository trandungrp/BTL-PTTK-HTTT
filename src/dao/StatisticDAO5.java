package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import model.Invoice5;
import model.Order5;
import model.ProductStatistic5;
import model.RevenueStatistic5;
import model.SupplierStatistic5;
import util.Util5;

/**
 * Cac thong ke la du lieu dan xuat: tong hop tu phieu nhap, hoa don va don hang, khong luu bang rieng.
 * Moi khoang thoi gian la [from, toExclusive).
 */
public class StatisticDAO5 extends DAO5 {
    public StatisticDAO5() { super(); }
    public StatisticDAO5(Connection c) { super(c); }

    /** Thong ke mat hang: nhap - ban - ton. "Ban" gom hoa don tai quay va don online da duyet/hoan thanh. */
    public List<ProductStatistic5> getProductStatistics(Date from, Date toExclusive) {
        String sql =
            "SELECT p.*, "
          + "COALESCE((SELECT SUM(d.quantity) FROM tblImportDetail5 d JOIN tblImportReceipt5 r ON r.id = d.tblImportReceipt5id "
          + "  WHERE d.tblProduct5id = p.id AND r.importDate >= ? AND r.importDate < ?), 0) AS imported, "
          + "COALESCE((SELECT SUM(d.quantity) FROM tblInvoiceDetail5 d JOIN tblInvoice5 i ON i.id = d.tblInvoice5id "
          + "  WHERE d.tblProduct5id = p.id AND i.saleDate >= ? AND i.saleDate < ?), 0) "
          + "+ COALESCE((SELECT SUM(d.quantity) FROM tblOrderDetail5 d JOIN tblOrder5 o ON o.id = d.tblOrder5id "
          + "  WHERE d.tblProduct5id = p.id AND o.status IN ('APPROVED','COMPLETED') AND o.orderDate >= ? AND o.orderDate < ?), 0) AS sold "
          + "FROM tblProduct5 p ORDER BY p.id";
        List<ProductStatistic5> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            for (int i = 0; i < 3; i++) {
                ps.setTimestamp(i * 2 + 1, ts(from));
                ps.setTimestamp(i * 2 + 2, ts(toExclusive));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductStatistic5 s = new ProductStatistic5();
                    s.setId(rs.getInt("id"));
                    s.setName(rs.getString("name"));
                    s.setBrand(rs.getString("brand"));
                    s.setUnit(rs.getString("unit"));
                    s.setSalePrice(rs.getDouble("salePrice"));
                    s.setImportPrice(rs.getDouble("importPrice"));
                    s.setQuantityInStock(rs.getInt("quantityInStock"));
                    s.setImportedQuantity(rs.getInt("imported"));
                    s.setSoldQuantity(rs.getInt("sold"));
                    s.setRemainQuantity(rs.getInt("quantityInStock"));
                    list.add(s);
                }
            }
        } catch (SQLException e) {
            throw new DataAccessException5("Loi thong ke mat hang", e);
        }
        return list;
    }

    /** Thong ke nha cung cap: so phieu nhap va tong gia tri nhap trong khoang. */
    public List<SupplierStatistic5> getSupplierStatistics(Date from, Date toExclusive) {
        String sql =
            "SELECT s.*, "
          + "(SELECT COUNT(*) FROM tblImportReceipt5 r WHERE r.tblSupplier5id = s.id AND r.importDate >= ? AND r.importDate < ?) AS cnt, "
          + "(SELECT COALESCE(SUM(d.quantity * d.unitPrice), 0) FROM tblImportDetail5 d JOIN tblImportReceipt5 r ON r.id = d.tblImportReceipt5id "
          + "  WHERE r.tblSupplier5id = s.id AND r.importDate >= ? AND r.importDate < ?) AS val "
          + "FROM tblSupplier5 s ORDER BY s.id";
        List<SupplierStatistic5> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            for (int i = 0; i < 2; i++) {
                ps.setTimestamp(i * 2 + 1, ts(from));
                ps.setTimestamp(i * 2 + 2, ts(toExclusive));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    SupplierStatistic5 s = new SupplierStatistic5();
                    SupplierDAO5.fill(s, rs);
                    s.setReceiptCount(rs.getInt("cnt"));
                    s.setTotalImportValue(rs.getDouble("val"));
                    list.add(s);
                }
            }
        } catch (SQLException e) {
            throw new DataAccessException5("Loi thong ke nha cung cap", e);
        }
        return list;
    }

    /**
     * Thong ke doanh thu theo ngay ("day") hoac thang ("month") tu hoa don tai quay va don online da hoan thanh.
     * Moi dong la mot RevenueStatistic5 (period, invoiceCount, orderCount, revenue), sap theo ki tang dan.
     */
    public List<RevenueStatistic5> getRevenueStatistics(Date from, Date toExclusive, String mode) {
        String fmt = "month".equals(mode) ? "%Y-%m" : "%Y-%m-%d";
        Map<String, RevenueStatistic5> map = new TreeMap<>();
        String invSql =
            "SELECT DATE_FORMAT(x.saleDate, ?) AS p, COUNT(*) AS c, SUM(x.t) AS r FROM ("
          + "SELECT i.saleDate, (SELECT COALESCE(SUM(d.quantity * d.unitPrice), 0) FROM tblInvoiceDetail5 d WHERE d.tblInvoice5id = i.id) AS t "
          + "FROM tblInvoice5 i WHERE i.saleDate >= ? AND i.saleDate < ?) x GROUP BY p";
        String ordSql =
            "SELECT DATE_FORMAT(x.orderDate, ?) AS p, COUNT(*) AS c, SUM(x.t) AS r FROM ("
          + "SELECT o.orderDate, (SELECT COALESCE(SUM(d.quantity * d.unitPrice), 0) FROM tblOrderDetail5 d WHERE d.tblOrder5id = o.id) AS t "
          + "FROM tblOrder5 o WHERE o.status = 'COMPLETED' AND o.orderDate >= ? AND o.orderDate < ?) x GROUP BY p";
        try {
            for (int pass = 0; pass < 2; pass++) {
                try (PreparedStatement ps = con.prepareStatement(pass == 0 ? invSql : ordSql)) {
                    ps.setString(1, fmt);
                    ps.setTimestamp(2, ts(from));
                    ps.setTimestamp(3, ts(toExclusive));
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            String p = rs.getString("p");
                            RevenueStatistic5 s = map.get(p);
                            if (s == null) {
                                s = new RevenueStatistic5();
                                s.setPeriod(p);
                                map.put(p, s);
                            }
                            if (pass == 0) s.setInvoiceCount(rs.getInt("c")); else s.setOrderCount(rs.getInt("c"));
                            s.setRevenue(s.getRevenue() + rs.getDouble("r"));
                        }
                    }
                }
            }
        } catch (SQLException e) {
            throw new DataAccessException5("Loi thong ke doanh thu", e);
        }
        return new ArrayList<>(map.values());
    }

    /** Chi tiet mot ki (ngay hoac thang): danh sach hoa don va don hang thuoc ki do. */
    public RevenueStatistic5 getRevenueDetail(String period, String mode) {
        try {
            boolean month = "month".equals(mode);
            Date start = new SimpleDateFormat(month ? "yyyy-MM" : "yyyy-MM-dd").parse(period);
            Calendar c = Calendar.getInstance();
            c.setTime(start);
            c.add(month ? Calendar.MONTH : Calendar.DAY_OF_MONTH, 1);
            Date end = c.getTime();
            RevenueStatistic5 s = new RevenueStatistic5();
            s.setPeriod(period);
            s.setListInvoice(new InvoiceDAO5(con).getInvoicesBetween(start, end));
            s.setListOrder(new OrderDAO5(con).getCompletedOrdersBetween(start, end));
            s.setInvoiceCount(s.getListInvoice().size());
            s.setOrderCount(s.getListOrder().size());
            double rev = 0;
            for (Invoice5 i : s.getListInvoice()) rev += i.getTotalAmount();
            for (Order5 o : s.getListOrder()) rev += o.getTotalAmount();
            s.setRevenue(rev);
            return s;
        } catch (java.text.ParseException e) {
            throw new DataAccessException5("Ki thong ke khong hop le: " + Util5.esc(period), e);
        }
    }
}
