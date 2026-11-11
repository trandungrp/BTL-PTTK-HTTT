package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.InvoiceDetail5;

public class InvoiceDetailDAO5 extends DAO5 {
    public InvoiceDetailDAO5() { super(); }
    public InvoiceDetailDAO5(Connection c) { super(c); }

    public void saveInvoiceDetail(int invoiceId, List<InvoiceDetail5> listDetail) {
        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO tblInvoiceDetail5 (quantity, unitPrice, tblInvoice5id, tblProduct5id) VALUES (?,?,?,?)")) {
            for (InvoiceDetail5 d : listDetail) {
                ps.setInt(1, d.getQuantity());
                ps.setDouble(2, d.getUnitPrice());
                ps.setInt(3, invoiceId);
                ps.setInt(4, d.getProduct().getId());
                ps.addBatch();
            }
            ps.executeBatch();
        } catch (SQLException e) {
            throw new DataAccessException5("Loi luu chi tiet hoa don", e);
        }
    }

    public List<InvoiceDetail5> getDetails(int invoiceId) {
        List<InvoiceDetail5> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT d.id AS did, d.quantity AS dquantity, d.unitPrice AS dprice, p.* FROM tblInvoiceDetail5 d "
              + "JOIN tblProduct5 p ON p.id = d.tblProduct5id WHERE d.tblInvoice5id = ? ORDER BY d.id")) {
            ps.setInt(1, invoiceId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    InvoiceDetail5 d = new InvoiceDetail5();
                    d.setId(rs.getInt("did"));
                    d.setQuantity(rs.getInt("dquantity"));
                    d.setUnitPrice(rs.getDouble("dprice"));
                    d.setProduct(ProductDAO5.mapProduct(rs));
                    list.add(d);
                }
            }
        } catch (SQLException e) {
            throw new DataAccessException5("Loi doc chi tiet hoa don", e);
        }
        return list;
    }
}
