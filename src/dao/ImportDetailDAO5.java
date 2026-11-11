package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.ImportDetail5;

public class ImportDetailDAO5 extends DAO5 {
    public ImportDetailDAO5() { super(); }
    public ImportDetailDAO5(Connection c) { super(c); }

    public void saveImportDetail(int receiptId, List<ImportDetail5> listDetail) {
        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO tblImportDetail5 (quantity, unitPrice, tblImportReceipt5id, tblProduct5id) VALUES (?,?,?,?)")) {
            for (ImportDetail5 d : listDetail) {
                ps.setInt(1, d.getQuantity());
                ps.setDouble(2, d.getUnitPrice());
                ps.setInt(3, receiptId);
                ps.setInt(4, d.getProduct().getId());
                ps.addBatch();
            }
            ps.executeBatch();
        } catch (SQLException e) {
            throw new DataAccessException5("Loi luu chi tiet phieu nhap", e);
        }
    }

    public List<ImportDetail5> getDetails(int receiptId) {
        List<ImportDetail5> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT d.id AS did, d.quantity AS dquantity, d.unitPrice AS dprice, p.* FROM tblImportDetail5 d "
              + "JOIN tblProduct5 p ON p.id = d.tblProduct5id WHERE d.tblImportReceipt5id = ? ORDER BY d.id")) {
            ps.setInt(1, receiptId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ImportDetail5 d = new ImportDetail5();
                    d.setId(rs.getInt("did"));
                    d.setQuantity(rs.getInt("dquantity"));
                    d.setUnitPrice(rs.getDouble("dprice"));
                    d.setProduct(ProductDAO5.mapProduct(rs));
                    list.add(d);
                }
            }
        } catch (SQLException e) {
            throw new DataAccessException5("Loi doc chi tiet phieu nhap", e);
        }
        return list;
    }
}
