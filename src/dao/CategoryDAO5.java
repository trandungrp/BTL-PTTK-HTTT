package dao;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import model.Category5;
import model.Product5;

public class CategoryDAO5 extends DAO5 {
    public CategoryDAO5() { super(); }
    public CategoryDAO5(Connection c) { super(c); }

    /** Lay moi loai hang, moi Category5 dong goi kem listProduct cua no. */
    public List<Category5> getAllCategories() {
        Map<Integer, Category5> map = new LinkedHashMap<>();
        try (Statement st = con.createStatement()) {
            try (ResultSet rs = st.executeQuery("SELECT id, name, description FROM tblCategory5 ORDER BY id")) {
                while (rs.next()) {
                    Category5 c = new Category5();
                    c.setId(rs.getInt("id"));
                    c.setName(rs.getString("name"));
                    c.setDescription(rs.getString("description"));
                    map.put(c.getId(), c);
                }
            }
            try (ResultSet rs = st.executeQuery("SELECT * FROM tblProduct5 ORDER BY id")) {
                while (rs.next()) {
                    Product5 p = ProductDAO5.mapProduct(rs);
                    Category5 c = map.get(rs.getInt("tblCategory5id"));
                    if (c != null) c.getListProduct().add(p);
                }
            }
        } catch (SQLException e) {
            throw new DataAccessException5("Loi doc loai hang", e);
        }
        return new ArrayList<>(map.values());
    }
}
