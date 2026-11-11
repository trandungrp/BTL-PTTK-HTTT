package dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import model.Customer5;
import model.Employee5;
import model.Manager5;
import model.Member5;
import model.Salesperson5;
import model.WarehouseStaff5;
import util.Util5;

/** Truy xuat thanh vien: dang nhap, dang ki, doi mat khau. */
public class MemberDAO5 extends DAO5 {
    public MemberDAO5() { super(); }
    public MemberDAO5(Connection c) { super(c); }

    private static final String SELECT_MEMBER =
        "SELECT m.*, e.position AS position, c.registerDate AS registerDate "
      + "FROM tblMember5 m LEFT JOIN tblEmployee5 e ON e.tblMember5id = m.id "
      + "LEFT JOIN tblCustomer5 c ON c.tblMember5id = m.id ";

    /** Tra ve thanh vien (dung lop con theo vai tro) hoac null neu sai tai khoan/mat khau. */
    public Member5 login(String username, String password) {
        String sql = SELECT_MEMBER + "WHERE m.username = ? AND m.password = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, Util5.sha256(password));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        } catch (SQLException e) {
            throw new DataAccessException5("Loi dang nhap", e);
        }
    }

    public Member5 getMember(int id) {
        try (PreparedStatement ps = con.prepareStatement(SELECT_MEMBER + "WHERE m.id = ?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        } catch (SQLException e) {
            throw new DataAccessException5("Loi doc thanh vien", e);
        }
    }

    /** Tim khach hang theo ten dang nhap (dung khi ban hang tai quay). */
    public Customer5 getCustomerByUsername(String username) {
        try (PreparedStatement ps = con.prepareStatement(SELECT_MEMBER + "WHERE m.username = ? AND m.role = 'CUSTOMER'")) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? (Customer5) map(rs) : null;
            }
        } catch (SQLException e) {
            throw new DataAccessException5("Loi tim khach hang", e);
        }
    }

    public boolean usernameExists(String username) {
        try (PreparedStatement ps = con.prepareStatement("SELECT 1 FROM tblMember5 WHERE username = ?")) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            throw new DataAccessException5("Loi kiem tra ten dang nhap", e);
        }
    }

    /** Dang ki khach hang moi (tblMember5 + tblCustomer5 trong mot transaction). */
    public int registerCustomer(Customer5 c) {
        try {
            begin();
            int id;
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO tblMember5 (username, password, fullName, birthday, address, email, phone, role, note) "
                  + "VALUES (?,?,?,?,?,?,?, 'CUSTOMER', ?)", PreparedStatement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, c.getUsername());
                ps.setString(2, Util5.sha256(c.getPassword()));
                ps.setString(3, c.getFullName());
                ps.setDate(4, c.getBirthday() == null ? null : new Date(c.getBirthday().getTime()));
                ps.setString(5, c.getAddress());
                ps.setString(6, c.getEmail());
                ps.setString(7, c.getPhone());
                ps.setString(8, c.getNote());
                ps.executeUpdate();
                try (ResultSet k = ps.getGeneratedKeys()) {
                    k.next();
                    id = k.getInt(1);
                }
            }
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO tblCustomer5 (tblMember5id, registerDate) VALUES (?, CURDATE())")) {
                ps.setInt(1, id);
                ps.executeUpdate();
            }
            commit();
            c.setId(id);
            return id;
        } catch (SQLException e) {
            rollback();
            throw new DataAccessException5("Loi dang ki thanh vien", e);
        }
    }

    /** Doi mat khau: tra ve false neu mat khau cu sai. */
    public boolean changePassword(int memberId, String oldPassword, String newPassword) {
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE tblMember5 SET password = ? WHERE id = ? AND password = ?")) {
            ps.setString(1, Util5.sha256(newPassword));
            ps.setInt(2, memberId);
            ps.setString(3, Util5.sha256(oldPassword));
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new DataAccessException5("Loi doi mat khau", e);
        }
    }

    private static Member5 map(ResultSet rs) throws SQLException {
        String role = rs.getString("role");
        Member5 m;
        switch (role) {
            case Member5.ROLE_MANAGER: m = new Manager5(); break;
            case Member5.ROLE_WAREHOUSE: m = new WarehouseStaff5(); break;
            case Member5.ROLE_SALES: m = new Salesperson5(); break;
            default: m = new Customer5();
        }
        m.setId(rs.getInt("id"));
        m.setUsername(rs.getString("username"));
        m.setPassword(null); // khong giu mat khau trong session
        m.setFullName(rs.getString("fullName"));
        m.setBirthday(rs.getDate("birthday"));
        m.setAddress(rs.getString("address"));
        m.setEmail(rs.getString("email"));
        m.setPhone(rs.getString("phone"));
        m.setRole(role);
        m.setNote(rs.getString("note"));
        if (m instanceof Employee5) ((Employee5) m).setPosition(rs.getString("position"));
        if (m instanceof Customer5) ((Customer5) m).setRegisterDate(rs.getDate("registerDate"));
        return m;
    }
}
