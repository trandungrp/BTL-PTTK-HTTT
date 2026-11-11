package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.OrderDetail5;

public class OrderDetailDAO5 extends DAO5 {
    public OrderDetailDAO5() { super(); }
    public OrderDetailDAO5(Connection c) { super(c); }

    /** Luu cac dong chi tiet cua don (dung chung ket noi/transaction voi OrderDAO5.saveOrder). */
    public boolean saveOrderDetail(int orderId, List<OrderDetail5> listDetail) {
        if (listDetail == null || listDetail.isEmpty()) return false;
        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO tblOrderDetail5 (quantity, unitPrice, tblOrder5id, tblProduct5id) VALUES (?,?,?,?)")) {
            for (OrderDetail5 d : listDetail) {
                ps.setInt(1, d.getQuantity());
                ps.setDouble(2, d.getUnitPrice());
                ps.setInt(3, orderId);
                ps.setInt(4, d.getProduct().getId());
                ps.addBatch();
            }
            ps.executeBatch();
            return true;
        } catch (SQLException e) {
            throw new DataAccessException5("Loi luu chi tiet don hang", e);
        }
    }

    /** Chi tiet don kem Product5 (gom ton kho hien tai de nhan vien kho doi chieu khi duyet). */
    public List<OrderDetail5> getDetails(int orderId) {
        List<OrderDetail5> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT d.id AS did, d.quantity AS dquantity, d.unitPrice AS dprice, p.* FROM tblOrderDetail5 d "
              + "JOIN tblProduct5 p ON p.id = d.tblProduct5id WHERE d.tblOrder5id = ? ORDER BY d.id")) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderDetail5 d = new OrderDetail5();
                    d.setId(rs.getInt("did"));
                    d.setQuantity(rs.getInt("dquantity"));
                    d.setUnitPrice(rs.getDouble("dprice"));
                    d.setProduct(ProductDAO5.mapProduct(rs));
                    list.add(d);
                }
            }
        } catch (SQLException e) {
            throw new DataAccessException5("Loi doc chi tiet don hang", e);
        }
        return list;
    }
}
