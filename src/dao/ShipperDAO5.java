package dao;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import model.Shipper5;

public class ShipperDAO5 extends DAO5 {
    public ShipperDAO5() { super(); }
    public ShipperDAO5(Connection c) { super(c); }

    public List<Shipper5> getAllShippers() {
        List<Shipper5> list = new ArrayList<>();
        try (Statement st = con.createStatement();
             ResultSet rs = st.executeQuery("SELECT id, fullName, phone FROM tblShipper5 ORDER BY id")) {
            while (rs.next()) {
                Shipper5 s = new Shipper5();
                s.setId(rs.getInt("id"));
                s.setFullName(rs.getString("fullName"));
                s.setPhone(rs.getString("phone"));
                list.add(s);
            }
        } catch (SQLException e) {
            throw new DataAccessException5("Loi doc nhan vien giao hang", e);
        }
        return list;
    }
}
