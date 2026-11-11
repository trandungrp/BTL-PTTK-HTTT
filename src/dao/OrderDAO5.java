package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import model.Customer5;
import model.Order5;
import model.OrderDetail5;
import model.Shipper5;
import model.WarehouseStaff5;

public class OrderDAO5 extends DAO5 {
    public OrderDAO5() { super(); }
    public OrderDAO5(Connection c) { super(c); }

    private static final String SELECT_ORDER =
        "SELECT o.id, o.orderDate, o.deliveryAddress, o.status, o.tblCustomer5id, o.tblEmployee5id, o.tblShipper5id, "
      + "(SELECT COALESCE(SUM(d.quantity * d.unitPrice), 0) FROM tblOrderDetail5 d WHERE d.tblOrder5id = o.id) AS total, "
      + "cu.fullName AS cuName, cu.phone AS cuPhone, ap.fullName AS apName, sh.fullName AS shName, sh.phone AS shPhone "
      + "FROM tblOrder5 o JOIN tblMember5 cu ON cu.id = o.tblCustomer5id "
      + "LEFT JOIN tblMember5 ap ON ap.id = o.tblEmployee5id "
      + "LEFT JOIN tblShipper5 sh ON sh.id = o.tblShipper5id ";

    private static Order5 map(ResultSet rs) throws SQLException {
        Order5 o = new Order5();
        o.setId(rs.getInt("id"));
        o.setOrderDate(rs.getTimestamp("orderDate"));
        o.setDeliveryAddress(rs.getString("deliveryAddress"));
        o.setStatus(rs.getString("status"));
        o.setTotalAmount(rs.getDouble("total"));
        Customer5 c = new Customer5();
        c.setId(rs.getInt("tblCustomer5id"));
        c.setFullName(rs.getString("cuName"));
        c.setPhone(rs.getString("cuPhone"));
        o.setCustomer(c);
        int apId = rs.getInt("tblEmployee5id");
        if (!rs.wasNull()) {
            WarehouseStaff5 w = new WarehouseStaff5();
            w.setId(apId);
            w.setFullName(rs.getString("apName"));
            o.setApprovedBy(w);
        }
        int shId = rs.getInt("tblShipper5id");
        if (!rs.wasNull()) {
            Shipper5 s = new Shipper5();
            s.setId(shId);
            s.setFullName(rs.getString("shName"));
            s.setPhone(rs.getString("shPhone"));
            o.setShipper(s);
        }
        return o;
    }

    /**
     * Luu ban ghi don hang vao tblOrder5, roi goi OrderDetailDAO5.saveOrderDetail() luu cac dong chi tiet
     * (dung chung ket noi, cung mot transaction). Thanh cong thi gan ma don vua tao vao order.id.
     */
    public boolean saveOrder(Order5 order) {
        try {
            begin();
            int id;
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO tblOrder5 (orderDate, deliveryAddress, status, tblCustomer5id) VALUES (?,?,?,?)",
                    PreparedStatement.RETURN_GENERATED_KEYS)) {
                ps.setTimestamp(1, ts(order.getOrderDate()));
                ps.setString(2, order.getDeliveryAddress());
                ps.setString(3, order.getStatus());
                ps.setInt(4, order.getCustomer().getId());
                ps.executeUpdate();
                try (ResultSet k = ps.getGeneratedKeys()) {
                    k.next();
                    id = k.getInt(1);
                }
            }
            if (!new OrderDetailDAO5(con).saveOrderDetail(id, order.getListDetail())) {
                rollback();
                return false;
            }
            commit();
            order.setId(id);
            return true;
        } catch (SQLException | RuntimeException e) {
            rollback();
            if (e instanceof RuntimeException) throw (RuntimeException) e;
            throw new DataAccessException5("Loi luu don hang", e);
        }
    }

    public List<Order5> getOrdersByStatus(String status) {
        return query(SELECT_ORDER + "WHERE o.status = ? ORDER BY o.orderDate", ps -> ps.setString(1, status));
    }

    /** Don da hoan thanh trong khoang [from, toExclusive) - dung cho thong ke doanh thu. */
    public List<Order5> getCompletedOrdersBetween(Date from, Date toExclusive) {
        return query(SELECT_ORDER + "WHERE o.status = 'COMPLETED' AND o.orderDate >= ? AND o.orderDate < ? ORDER BY o.orderDate",
            ps -> { ps.setTimestamp(1, ts(from)); ps.setTimestamp(2, ts(toExclusive)); });
    }

    private interface Binder { void bind(PreparedStatement ps) throws SQLException; }

    private List<Order5> query(String sql, Binder b) {
        List<Order5> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            b.bind(ps);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            throw new DataAccessException5("Loi doc don hang", e);
        }
        return list;
    }

    /** Don hang day du (kem chi tiet) hoac null. */
    public Order5 getOrder(int id) {
        List<Order5> l = query(SELECT_ORDER + "WHERE o.id = ?", ps -> ps.setInt(1, id));
        if (l.isEmpty()) return null;
        Order5 o = l.get(0);
        o.setListDetail(new OrderDetailDAO5(con).getDetails(id));
        return o;
    }

    /**
     * Duyet don: kiem tra con o trang thai cho duyet, tru ton kho cac mat hang, chuyen sang da duyet
     * va xuat cho nhan vien giao hang. Tra ve null neu thanh cong, nguoc lai tra ve thong bao loi.
     */
    public String approveOrder(int orderId, int staffId, int shipperId) {
        try {
            begin();
            String status = lockStatus(orderId);
            if (status == null) { rollback(); return "Đơn hàng không tồn tại."; }
            if (!Order5.PENDING.equals(status)) { rollback(); return "Đơn hàng không còn ở trạng thái chờ duyệt."; }
            ProductDAO5 pdao = new ProductDAO5(con);
            for (OrderDetail5 d : new OrderDetailDAO5(con).getDetails(orderId)) {
                if (!pdao.decreaseStock(d.getProduct().getId(), d.getQuantity())) {
                    rollback();
                    return "Không đủ hàng trong kho: " + d.getProduct().getName()
                         + " (cần " + d.getQuantity() + ", tồn " + d.getProduct().getQuantityInStock() + ").";
                }
            }
            try (PreparedStatement ps = con.prepareStatement(
                    "UPDATE tblOrder5 SET status = 'APPROVED', tblEmployee5id = ?, tblShipper5id = ? WHERE id = ?")) {
                ps.setInt(1, staffId);
                ps.setInt(2, shipperId);
                ps.setInt(3, orderId);
                ps.executeUpdate();
            }
            commit();
            return null;
        } catch (SQLException e) {
            rollback();
            throw new DataAccessException5("Loi duyet don hang", e);
        }
    }

    /** Tu choi don dang cho duyet. */
    public boolean rejectOrder(int orderId, int staffId) {
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE tblOrder5 SET status = 'REJECTED', tblEmployee5id = ? WHERE id = ? AND status = 'PENDING'")) {
            ps.setInt(1, staffId);
            ps.setInt(2, orderId);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new DataAccessException5("Loi tu choi don hang", e);
        }
    }

    /** Xac nhan da giao xong: da duyet -> hoan thanh (tinh vao doanh thu). */
    public boolean completeOrder(int orderId) {
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE tblOrder5 SET status = 'COMPLETED' WHERE id = ? AND status = 'APPROVED'")) {
            ps.setInt(1, orderId);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new DataAccessException5("Loi cap nhat don hang", e);
        }
    }

    private String lockStatus(int orderId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement("SELECT status FROM tblOrder5 WHERE id = ? FOR UPDATE")) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString(1) : null;
            }
        }
    }
}
