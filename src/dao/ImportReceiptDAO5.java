package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import model.ImportDetail5;
import model.ImportReceipt5;
import model.Supplier5;
import model.WarehouseStaff5;

public class ImportReceiptDAO5 extends DAO5 {
    public ImportReceiptDAO5() { super(); }
    public ImportReceiptDAO5(Connection c) { super(c); }

    /**
     * Luu phieu nhap + chi tiet, cong ton kho cac mat hang va ghi nhan nha cung cap cung cap mat hang
     * (tblSupplierProduct5) - tat ca trong cung mot transaction. Tra ve ma phieu.
     */
    public int saveReceipt(ImportReceipt5 r) {
        try {
            begin();
            int id;
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO tblImportReceipt5 (importDate, tblSupplier5id, tblEmployee5id) VALUES (?,?,?)",
                    PreparedStatement.RETURN_GENERATED_KEYS)) {
                ps.setTimestamp(1, ts(r.getImportDate()));
                ps.setInt(2, r.getSupplier().getId());
                ps.setInt(3, r.getWarehouseStaff().getId());
                ps.executeUpdate();
                try (ResultSet k = ps.getGeneratedKeys()) {
                    k.next();
                    id = k.getInt(1);
                }
            }
            new ImportDetailDAO5(con).saveImportDetail(id, r.getListDetail());
            ProductDAO5 pdao = new ProductDAO5(con);
            SupplierProductDAO5 spdao = new SupplierProductDAO5(con);
            for (ImportDetail5 d : r.getListDetail()) {
                pdao.increaseStock(d.getProduct().getId(), d.getQuantity());
                spdao.saveOrUpdate(r.getSupplier().getId(), d.getProduct().getId(), d.getUnitPrice());
            }
            commit();
            r.setId(id);
            return id;
        } catch (SQLException | RuntimeException e) {
            rollback();
            if (e instanceof RuntimeException) throw (RuntimeException) e;
            throw new DataAccessException5("Loi luu phieu nhap", e);
        }
    }

    public ImportReceipt5 getReceipt(int id) {
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT r.id, r.importDate, r.tblSupplier5id, r.tblEmployee5id, s.fullName AS staffName "
              + "FROM tblImportReceipt5 r JOIN tblMember5 s ON s.id = r.tblEmployee5id WHERE r.id = ?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                ImportReceipt5 r = new ImportReceipt5();
                r.setId(rs.getInt("id"));
                r.setImportDate(rs.getTimestamp("importDate"));
                WarehouseStaff5 w = new WarehouseStaff5();
                w.setId(rs.getInt("tblEmployee5id"));
                w.setFullName(rs.getString("staffName"));
                r.setWarehouseStaff(w);
                Supplier5 s = new SupplierDAO5(con).getSupplier(rs.getInt("tblSupplier5id"));
                r.setSupplier(s);
                r.setListDetail(new ImportDetailDAO5(con).getDetails(id));
                r.calculateTotal();
                return r;
            }
        } catch (SQLException e) {
            throw new DataAccessException5("Loi doc phieu nhap", e);
        }
    }
}
