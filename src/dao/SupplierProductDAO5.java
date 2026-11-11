package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.SupplierProduct5;

/** Mat hang do tung nha cung cap cung cap (bang trung gian tblSupplierProduct5). */
public class SupplierProductDAO5 extends DAO5 {
    public SupplierProductDAO5() { super(); }
    public SupplierProductDAO5(Connection c) { super(c); }

    public List<SupplierProduct5> getBySupplier(int supplierId) {
        List<SupplierProduct5> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT sp.id AS spid, sp.supplyPrice, p.* FROM tblSupplierProduct5 sp "
              + "JOIN tblProduct5 p ON p.id = sp.tblProduct5id WHERE sp.tblSupplier5id = ? ORDER BY p.id")) {
            ps.setInt(1, supplierId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    SupplierProduct5 sp = new SupplierProduct5();
                    sp.setId(rs.getInt("spid"));
                    sp.setSupplyPrice(rs.getDouble("supplyPrice"));
                    sp.setProduct(ProductDAO5.mapProduct(rs));
                    list.add(sp);
                }
            }
        } catch (SQLException e) {
            throw new DataAccessException5("Loi doc mat hang cua nha cung cap", e);
        }
        return list;
    }

    /** Ghi nhan nha cung cap cung cap mat hang voi gia nay (them moi hoac cap nhat gia). */
    public void saveOrUpdate(int supplierId, int productId, double supplyPrice) {
        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO tblSupplierProduct5 (supplyPrice, tblSupplier5id, tblProduct5id) VALUES (?,?,?) "
              + "ON DUPLICATE KEY UPDATE supplyPrice = ?")) {
            ps.setDouble(1, supplyPrice);
            ps.setInt(2, supplierId);
            ps.setInt(3, productId);
            ps.setDouble(4, supplyPrice);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataAccessException5("Loi luu mat hang nha cung cap", e);
        }
    }
}
