package util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;
import javax.servlet.http.HttpSession;

/** Cac ham tien ich dung chung cho cac trang JSP va DAO. */
public final class Util5 {
    private Util5() {}

    /** Thoat ky tu HTML de tranh XSS khi in du lieu ra trang. */
    public static String esc(Object o) {
        if (o == null) return "";
        String s = String.valueOf(o);
        StringBuilder sb = new StringBuilder(s.length() + 16);
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '&': sb.append("&amp;"); break;
                case '<': sb.append("&lt;"); break;
                case '>': sb.append("&gt;"); break;
                case '"': sb.append("&quot;"); break;
                case '\'': sb.append("&#39;"); break;
                default: sb.append(c);
            }
        }
        return sb.toString();
    }

    /** Dinh dang tien kieu Viet Nam: 8.900.000 */
    public static String money(double v) {
        DecimalFormatSymbols sym = new DecimalFormatSymbols(Locale.US);
        sym.setGroupingSeparator('.');
        return new DecimalFormat("#,##0", sym).format(v);
    }

    public static String fmtDate(Date d) {
        return d == null ? "" : new SimpleDateFormat("dd/MM/yyyy").format(d);
    }

    public static String fmtDateTime(Date d) {
        return d == null ? "" : new SimpleDateFormat("dd/MM/yyyy HH:mm").format(d);
    }

    /** yyyy-MM-dd cho the input type="date". */
    public static String fmtIso(Date d) {
        return d == null ? "" : new SimpleDateFormat("yyyy-MM-dd").format(d);
    }

    public static Date parseIso(String s) {
        if (s == null || s.trim().isEmpty()) return null;
        try {
            SimpleDateFormat f = new SimpleDateFormat("yyyy-MM-dd");
            f.setLenient(false);
            return f.parse(s.trim());
        } catch (Exception e) {
            return null;
        }
    }

    public static int parseInt(String s, int def) {
        try {
            return Integer.parseInt(s.trim());
        } catch (Exception e) {
            return def;
        }
    }

    /** Chap nhan "9500000", "9.500.000" hoac "9,500,000". */
    public static double parseMoney(String s, double def) {
        if (s == null) return def;
        String t = s.trim().replace(".", "").replace(",", "").replace(" ", "");
        try {
            return Double.parseDouble(t);
        } catch (Exception e) {
            return def;
        }
    }

    public static String trim(String s) {
        return s == null ? "" : s.trim();
    }

    public static String nvl(String s) {
        return s == null ? "" : s;
    }

    public static String sha256(String s) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] b = md.digest(s.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte x : b) sb.append(String.format("%02x", x));
            return sb.toString();
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }

    // ---------- Ngay thang cho thong ke ----------
    public static Date startOfDay(Date d) {
        Calendar c = Calendar.getInstance();
        c.setTime(d);
        c.set(Calendar.HOUR_OF_DAY, 0);
        c.set(Calendar.MINUTE, 0);
        c.set(Calendar.SECOND, 0);
        c.set(Calendar.MILLISECOND, 0);
        return c.getTime();
    }

    public static Date addDays(Date d, int n) {
        Calendar c = Calendar.getInstance();
        c.setTime(d);
        c.add(Calendar.DAY_OF_MONTH, n);
        return c.getTime();
    }

    public static Date firstDayOfYear(Date d) {
        Calendar c = Calendar.getInstance();
        c.setTime(d);
        c.set(Calendar.MONTH, 0);
        c.set(Calendar.DAY_OF_MONTH, 1);
        return startOfDay(c.getTime());
    }

    /** Trang chu (tinh tu context path) cua tung vai tro sau khi dang nhap. */
    public static String homePath(String role) {
        if (role == null) return "/view/member/LoginGUI5.jsp";
        switch (role) {
            case "CUSTOMER": return "/view/customer/CustomerMainGUI5.jsp";
            case "WAREHOUSE": return "/view/warehouse/WarehouseMainGUI5.jsp";
            case "SALES": return "/view/sales/SalesMainGUI5.jsp";
            case "MANAGER": return "/view/manager/ManagerMainGUI5.jsp";
            default: return "/view/member/LoginGUI5.jsp";
        }
    }

    public static String roleLabel(String role) {
        if (role == null) return "";
        switch (role) {
            case "CUSTOMER": return "Khách hàng";
            case "WAREHOUSE": return "Nhân viên kho";
            case "SALES": return "Nhân viên bán hàng";
            case "MANAGER": return "Nhân viên quản lí";
            default: return role;
        }
    }

    public static String urlEnc(String s) {
        try {
            return java.net.URLEncoder.encode(s == null ? "" : s, "UTF-8");
        } catch (java.io.UnsupportedEncodingException e) {
            return "";
        }
    }

    // ---------- Thong bao (flash) luu trong session ----------
    public static void flash(HttpSession s, String type, String msg) {
        s.setAttribute("flashType", type);
        s.setAttribute("flashMsg", msg);
    }

    public static void flashOk(HttpSession s, String msg) { flash(s, "ok", msg); }

    public static void flashErr(HttpSession s, String msg) { flash(s, "err", msg); }
}
