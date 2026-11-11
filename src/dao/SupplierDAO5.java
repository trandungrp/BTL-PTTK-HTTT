package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Supplier5;
import util.Util5;

public class SupplierDAO5 extends DAO5 {
    public SupplierDAO5() { super(); }
    public SupplierDAO5(Connection c) { super(c); }

    static Supplier5 mapSupplier(ResultSet rs) throws SQLException {
        Supplier5 s = new Supplier5();
        fill(s, rs);
        return s;
    }

    static void fill(Supplier5 s, ResultSet rs) throws SQLException {
        s.setId(rs.getInt("id"));
        s.setName(rs.getString("name"));
        s.setAddress(rs.getString("address"));
        s.setPhone(rs.getString("phone"));
        s.setEmail(rs.getString("email"));
        s.setContactPerson(rs.getString("contactPerson"));
    }

    public List<Supplier5> getSuppliersByName(String name) {
        List<Supplier5> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement("SELECT * FROM tblSupplier5 WHERE name LIKE ? ORDER BY id")) {
            ps.setString(1, "%" + Util5.trim(name) + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapSupplier(rs));
            }
        } catch (SQLException e) {
            throw new DataAccessException5("Loi doc nha cung cap", e);
        }
        return list;
    }

    public List<Supplier5> getAllSuppliers() { return getSuppliersByName(""); }

    public Supplier5 getSupplier(int id) {
        try (PreparedStatement ps = con.prepareStatement("SELECT * FROM tblSupplier5 WHERE id = ?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapSupplier(rs) : null;
            }
        } catch (SQLException e) {
            throw new DataAccessException5("Loi doc nha cung cap", e);
        }
    }

    public int addSupplier(Supplier5 s) {
        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO tblSupplier5 (name, address, phone, email, contactPerson) VALUES (?,?,?,?,?)",
                PreparedStatement.RETURN_GENERATED_KEYS)) {
            bind(ps, s);
            ps.executeUpdate();
            try (ResultSet k = ps.getGeneratedKeys()) {
                k.next();
                s.setId(k.getInt(1));
                return s.getId();
            }
        } catch (SQLException e) {
            throw new DataAccessException5("Loi them nha cung cap", e);
        }
    }

    public boolean updateSupplier(Supplier5 s) {
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE tblSupplier5 SET name=?, address=?, phone=?, email=?, contactPerson=? WHERE id=?")) {
            bind(ps, s);
            ps.setInt(6, s.getId());
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new DataAccessException5("Loi cap nhat nha cung cap", e);
        }
    }

    private static void bind(PreparedStatement ps, Supplier5 s) throws SQLException {
        ps.setString(1, s.getName());
        ps.setString(2, s.getAddress());
        ps.setString(3, s.getPhone());
        ps.setString(4, s.getEmail());
        ps.setString(5, s.getContactPerson());
    }

    /** Xoa nha cung cap; false neu da co phieu nhap tham chieu. */
    public boolean deleteSupplier(int id) {
        try (PreparedStatement ps = con.prepareStatement("DELETE FROM tblSupplier5 WHERE id = ?")) {
            ps.setInt(1, id);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            if (e.getSQLState() != null && e.getSQLState().startsWith("23")) return false;
            throw new DataAccessException5("Loi xoa nha cung cap", e);
        }
    }
}
