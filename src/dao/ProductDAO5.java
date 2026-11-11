package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.CartItem5;
import model.Product5;
import util.Util5;

/**
 * Lop truy xuat mat hang (Hinh 4, Hinh 6):
 * getProductsByName(name : String) : Product5[], getProductDetail(id : int) : Product5,
 * updateProduct(product : Product5, categoryId : int) : boolean, checkStock(listItem : CartItem5[]) : boolean.
 * Cac phuong thuc con lai phuc vu cac chuc nang khac (them/xoa mat hang, ban tai quay, duyet don).
 */
public class ProductDAO5 extends DAO5 {
    public ProductDAO5() { super(); }
    public ProductDAO5(Connection c) { super(c); }

    /** Dong goi cac cot cua tblProduct5 vao Product5. */
    static Product5 mapProduct(ResultSet rs) throws SQLException {
        Product5 product = new Product5();
        product.setId(rs.getInt("id"));
        product.setName(rs.getString("name"));
        product.setBrand(rs.getString("brand"));
        product.setUnit(rs.getString("unit"));
        product.setImportPrice(rs.getDouble("importPrice"));
        product.setSalePrice(rs.getDouble("salePrice"));
        product.setQuantityInStock(rs.getInt("quantityInStock"));
        product.setDescription(rs.getString("description"));
        product.setImage(rs.getString("image"));
        return product;
    }

    /** Tim mat hang theo ten (chua chuoi tim kiem). Chuoi rong -> tat ca mat hang. */
    public List<Product5> getProductsByName(String name) {
        List<Product5> listProduct = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement("SELECT * FROM tblProduct5 WHERE name LIKE ? ORDER BY id")) {
            ps.setString(1, "%" + Util5.trim(name) + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) listProduct.add(mapProduct(rs));
            }
        } catch (SQLException e) {
            throw new DataAccessException5("Loi tim mat hang", e);
        }
        return listProduct;
    }

    /** Tim theo ten hoac ma (vd MH001 hoac 1) - dung khi ban hang tai quay. */
    public List<Product5> searchByNameOrCode(String keyword) {
        String k = Util5.trim(keyword);
        String digits = k.toUpperCase().startsWith("MH") ? k.substring(2) : k;
        int id = Util5.parseInt(digits, -1);
        List<Product5> listProduct = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement("SELECT * FROM tblProduct5 WHERE name LIKE ? OR id = ? ORDER BY id")) {
            ps.setString(1, "%" + k + "%");
            ps.setInt(2, id);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) listProduct.add(mapProduct(rs));
            }
        } catch (SQLException e) {
            throw new DataAccessException5("Loi tim mat hang", e);
        }
        return listProduct;
    }

    public List<Product5> getAllProducts() { return getProductsByName(""); }

    /** Thong tin chi tiet mot mat hang, null neu khong ton tai. */
    public Product5 getProductDetail(int id) {
        try (PreparedStatement ps = con.prepareStatement("SELECT * FROM tblProduct5 WHERE id = ?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapProduct(rs) : null;
            }
        } catch (SQLException e) {
            throw new DataAccessException5("Loi doc chi tiet mat hang", e);
        }
    }

    /** Luu thong tin mat hang cung id loai hang duoc chon vao CSDL. */
    public boolean updateProduct(Product5 product, int categoryId) {
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE tblProduct5 SET name=?, brand=?, unit=?, importPrice=?, salePrice=?, quantityInStock=?, "
              + "description=?, image=?, tblCategory5id=? WHERE id=?")) {
            bind(ps, product, categoryId);
            ps.setInt(10, product.getId());
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            if (e.getSQLState() != null && e.getSQLState().startsWith("23")) return false; // loai hang khong ton tai
            throw new DataAccessException5("Loi cap nhat mat hang", e);
        }
    }

    public int addProduct(Product5 product, int categoryId) {
        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO tblProduct5 (name, brand, unit, importPrice, salePrice, quantityInStock, description, image, tblCategory5id) "
              + "VALUES (?,?,?,?,?,?,?,?,?)", PreparedStatement.RETURN_GENERATED_KEYS)) {
            bind(ps, product, categoryId);
            ps.executeUpdate();
            try (ResultSet k = ps.getGeneratedKeys()) {
                k.next();
                product.setId(k.getInt(1));
                return product.getId();
            }
        } catch (SQLException e) {
            throw new DataAccessException5("Loi them mat hang", e);
        }
    }

    private static void bind(PreparedStatement ps, Product5 product, int categoryId) throws SQLException {
        ps.setString(1, product.getName());
        ps.setString(2, product.getBrand());
        ps.setString(3, product.getUnit());
        ps.setDouble(4, product.getImportPrice());
        ps.setDouble(5, product.getSalePrice());
        ps.setInt(6, product.getQuantityInStock());
        ps.setString(7, product.getDescription());
        ps.setString(8, product.getImage());
        ps.setInt(9, categoryId);
    }

    /** Xoa mat hang; false neu mat hang da phat sinh giao dich (rang buoc khoa ngoai). */
    public boolean deleteProduct(int id) {
        try (PreparedStatement ps = con.prepareStatement("DELETE FROM tblProduct5 WHERE id = ?")) {
            ps.setInt(1, id);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            if (e.getSQLState() != null && e.getSQLState().startsWith("23")) return false;
            throw new DataAccessException5("Loi xoa mat hang", e);
        }
    }

    /**
     * Kiem tra lai so luong ton cua cac mat hang trong gio.
     * true neu moi mat hang deu con du hang, false neu co mat hang khong con ton tai hoac khong du hang.
     */
    public boolean checkStock(List<CartItem5> listItem) {
        try (PreparedStatement ps = con.prepareStatement("SELECT quantityInStock FROM tblProduct5 WHERE id = ?")) {
            for (CartItem5 item : listItem) {
                ps.setInt(1, item.getProduct().getId());
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next() || rs.getInt("quantityInStock") < item.getQuantity()) return false;
                }
            }
        } catch (SQLException e) {
            throw new DataAccessException5("Loi kiem tra ton kho", e);
        }
        return true;
    }

    /** Tru ton kho (nguyen tu): false neu khong du hang. */
    public boolean decreaseStock(int productId, int qty) {
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE tblProduct5 SET quantityInStock = quantityInStock - ? WHERE id = ? AND quantityInStock >= ?")) {
            ps.setInt(1, qty);
            ps.setInt(2, productId);
            ps.setInt(3, qty);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new DataAccessException5("Loi tru ton kho", e);
        }
    }

    public void increaseStock(int productId, int qty) {
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE tblProduct5 SET quantityInStock = quantityInStock + ? WHERE id = ?")) {
            ps.setInt(1, qty);
            ps.setInt(2, productId);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataAccessException5("Loi cong ton kho", e);
        }
    }
}
