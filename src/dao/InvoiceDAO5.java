package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import model.Customer5;
import model.Invoice5;
import model.InvoiceDetail5;
import model.Salesperson5;

public class InvoiceDAO5 extends DAO5 {
    public InvoiceDAO5() { super(); }
    public InvoiceDAO5(Connection c) { super(c); }

    private static final String SELECT_INVOICE =
        "SELECT i.id, i.saleDate, i.tblEmployee5id, i.tblCustomer5id, "
      + "(SELECT COALESCE(SUM(d.quantity * d.unitPrice), 0) FROM tblInvoiceDetail5 d WHERE d.tblInvoice5id = i.id) AS total, "
      + "s.fullName AS sName, c.fullName AS cName, c.phone AS cPhone "
      + "FROM tblInvoice5 i JOIN tblMember5 s ON s.id = i.tblEmployee5id "
      + "LEFT JOIN tblMember5 c ON c.id = i.tblCustomer5id ";

    private static Invoice5 map(ResultSet rs) throws SQLException {
        Invoice5 inv = new Invoice5();
        inv.setId(rs.getInt("id"));
        inv.setSaleDate(rs.getTimestamp("saleDate"));
        inv.setTotalAmount(rs.getDouble("total"));
        Salesperson5 sp = new Salesperson5();
        sp.setId(rs.getInt("tblEmployee5id"));
        sp.setFullName(rs.getString("sName"));
        inv.setSalesperson(sp);
        int cid = rs.getInt("tblCustomer5id");
        if (!rs.wasNull()) {
            Customer5 c = new Customer5();
            c.setId(cid);
            c.setFullName(rs.getString("cName"));
            c.setPhone(rs.getString("cPhone"));
            inv.setCustomer(c);
        }
        return inv;
    }

    /**
     * Luu hoa don + chi tiet va tru ton kho trong cung mot transaction.
     * Nem DataAccessException5 (va rollback) neu mat hang nao khong du ton kho.
     */
    public int saveInvoice(Invoice5 inv) {
        try {
            begin();
            int id;
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO tblInvoice5 (saleDate, tblEmployee5id, tblCustomer5id) VALUES (?,?,?)",
                    PreparedStatement.RETURN_GENERATED_KEYS)) {
                ps.setTimestamp(1, ts(inv.getSaleDate()));
                ps.setInt(2, inv.getSalesperson().getId());
                if (inv.getCustomer() == null) ps.setNull(3, java.sql.Types.INTEGER);
                else ps.setInt(3, inv.getCustomer().getId());
                ps.executeUpdate();
                try (ResultSet k = ps.getGeneratedKeys()) {
                    k.next();
                    id = k.getInt(1);
                }
            }
            new InvoiceDetailDAO5(con).saveInvoiceDetail(id, inv.getListDetail());
            ProductDAO5 pdao = new ProductDAO5(con);
            for (InvoiceDetail5 d : inv.getListDetail()) {
                if (!pdao.decreaseStock(d.getProduct().getId(), d.getQuantity())) {
                    throw new DataAccessException5("Không đủ hàng trong kho: " + d.getProduct().getName());
                }
            }
            commit();
            inv.setId(id);
            return id;
        } catch (SQLException | RuntimeException e) {
            rollback();
            if (e instanceof RuntimeException) throw (RuntimeException) e;
            throw new DataAccessException5("Loi luu hoa don", e);
        }
    }

    /** Hoa don day du (kem chi tiet) hoac null. */
    public Invoice5 getInvoice(int id) {
        try (PreparedStatement ps = con.prepareStatement(SELECT_INVOICE + "WHERE i.id = ?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                Invoice5 inv = map(rs);
                inv.setListDetail(new InvoiceDetailDAO5(con).getDetails(id));
                return inv;
            }
        } catch (SQLException e) {
            throw new DataAccessException5("Loi doc hoa don", e);
        }
    }

    /** Hoa don trong khoang [from, toExclusive). */
    public List<Invoice5> getInvoicesBetween(Date from, Date toExclusive) {
        List<Invoice5> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(
                SELECT_INVOICE + "WHERE i.saleDate >= ? AND i.saleDate < ? ORDER BY i.saleDate")) {
            ps.setTimestamp(1, ts(from));
            ps.setTimestamp(2, ts(toExclusive));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            throw new DataAccessException5("Loi doc hoa don", e);
        }
        return list;
    }
}
