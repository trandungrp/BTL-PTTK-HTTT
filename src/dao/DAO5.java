package dao;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Date;
import java.util.Properties;

/**
 * Lop cha cua moi lop DAO: giu ket noi CSDL (con : Connection) dung chung.
 * Cac DAO con cung dung mot ket noi nen nhieu thao tac (vd luu don + chi tiet don)
 * nam trong cung mot transaction.
 *
 * Ket noi bang JDBC thuan (DriverManager). Thong so doc tu db.properties (trong classpath),
 * co the ghi de bang bien moi truong DB_URL, DB_USER, DB_PASS.
 */
public class DAO5 implements AutoCloseable {
    private static final Properties CFG = new Properties();

    static {
        try (InputStream in = DAO5.class.getResourceAsStream("/db.properties")) {
            if (in != null) CFG.load(in);
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (IOException | ClassNotFoundException e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    protected Connection con;
    private final boolean owner;

    public DAO5() {
        this.con = openConnection();
        this.owner = true;
    }

    /** Dung chung ket noi voi DAO khac (khong tu dong dong). */
    public DAO5(Connection shared) {
        this.con = shared;
        this.owner = false;
    }

    public Connection getCon() { return con; }

    private static Connection openConnection() {
        String url = setting("DB_URL", "db.url", "jdbc:mysql://localhost:3306/qlst5_db");
        String user = setting("DB_USER", "db.user", "root");
        String pass = setting("DB_PASS", "db.password", "");
        try {
            return DriverManager.getConnection(url, user, pass);
        } catch (SQLException e) {
            throw new DataAccessException5("Khong ket noi duoc CSDL qlst5_db (kiem tra db.properties): " + e.getMessage(), e);
        }
    }

    private static String setting(String envKey, String propKey, String def) {
        String v = System.getenv(envKey);
        if (v != null && !v.isEmpty()) return v;
        return CFG.getProperty(propKey, def);
    }

    protected static Timestamp ts(Date d) {
        return d == null ? null : new Timestamp(d.getTime());
    }

    protected void begin() throws SQLException { con.setAutoCommit(false); }

    protected void commit() throws SQLException {
        con.commit();
        con.setAutoCommit(true);
    }

    protected void rollback() {
        try {
            con.rollback();
            con.setAutoCommit(true);
        } catch (SQLException ignored) {
            // bo qua
        }
    }

    @Override
    public void close() {
        if (owner && con != null) {
            try {
                if (!con.getAutoCommit()) con.rollback();
                con.close();
            } catch (SQLException ignored) {
                // bo qua
            }
        }
    }
}
