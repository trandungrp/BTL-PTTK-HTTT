package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import model.Cart5;
import model.CartItem5;
import model.Customer5;

/**
 * Lop truy xuat gio hang (Hinh 6):
 * getCartOfCustomer(customerId : int) : Cart5, addItem(cartId : int, item : CartItem5) : boolean,
 * getItems(cartId : int) : CartItem5[], clearCart(cartId : int) : boolean.
 */
public class CartDAO5 extends DAO5 {
    public CartDAO5() { super(); }
    public CartDAO5(Connection c) { super(c); }

    /** Lay gio hang hien tai cua khach hang (tao gio trong neu khach chua co gio), kem cac dong listItem. */
    public Cart5 getCartOfCustomer(int customerId) {
        try {
            Cart5 cart = find(customerId);
            if (cart == null) {
                try (PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO tblCart5 (createdDate, tblCustomer5id) VALUES (?, ?)")) {
                    ps.setTimestamp(1, ts(new Date()));
                    ps.setInt(2, customerId);
                    ps.executeUpdate();
                }
                cart = find(customerId);
            }
            cart.setListItem(getItems(cart.getId()));
            return cart;
        } catch (SQLException e) {
            throw new DataAccessException5("Loi doc gio hang", e);
        }
    }

    private Cart5 find(int customerId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement("SELECT id, createdDate FROM tblCart5 WHERE tblCustomer5id = ?")) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                Cart5 cart = new Cart5();
                cart.setId(rs.getInt("id"));
                cart.setCreatedDate(rs.getTimestamp("createdDate"));
                Customer5 customer = new Customer5();
                customer.setId(customerId);
                cart.setCustomer(customer);
                return cart;
            }
        }
    }

    /** Them dong vao gio hang; cong don so luong neu mat hang da co trong gio. */
    public boolean addItem(int cartId, CartItem5 item) {
        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO tblCartItem5 (quantity, tblCart5id, tblProduct5id) VALUES (?,?,?) "
              + "ON DUPLICATE KEY UPDATE quantity = quantity + ?")) {
            ps.setInt(1, item.getQuantity());
            ps.setInt(2, cartId);
            ps.setInt(3, item.getProduct().getId());
            ps.setInt(4, item.getQuantity());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            if (e.getSQLState() != null && e.getSQLState().startsWith("23")) return false; // mat hang khong ton tai
            throw new DataAccessException5("Loi them vao gio hang", e);
        }
    }

    /** Cac dong trong gio hang, moi dong kem Product5 (gia ban hien tai). */
    public List<CartItem5> getItems(int cartId) {
        List<CartItem5> listItem = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT ci.id AS ciid, ci.quantity AS ciquantity, p.* FROM tblCartItem5 ci "
              + "JOIN tblProduct5 p ON p.id = ci.tblProduct5id WHERE ci.tblCart5id = ? ORDER BY ci.id")) {
            ps.setInt(1, cartId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CartItem5 item = new CartItem5();
                    item.setId(rs.getInt("ciid"));
                    item.setQuantity(rs.getInt("ciquantity"));
                    item.setProduct(ProductDAO5.mapProduct(rs));
                    listItem.add(item);
                }
            }
        } catch (SQLException e) {
            throw new DataAccessException5("Loi doc dong gio hang", e);
        }
        return listItem;
    }

    /** Xoa moi dong cua gio hang tam. */
    public boolean clearCart(int cartId) {
        try (PreparedStatement ps = con.prepareStatement("DELETE FROM tblCartItem5 WHERE tblCart5id = ?")) {
            ps.setInt(1, cartId);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            throw new DataAccessException5("Loi xoa gio hang", e);
        }
    }
}
