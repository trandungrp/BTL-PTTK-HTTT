package filter;

import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Member5;
import util.Util5;

/**
 * Dat ma hoa UTF-8 va phan quyen theo goi view:
 *  /view/member/*     - dang nhap, dang ki, dang xuat la cong khai; doi mat khau can dang nhap
 *  /view/customer/*   - chi khach hang
 *  /view/warehouse/*  - chi nhan vien kho
 *  /view/sales/*      - chi nhan vien ban hang
 *  /view/manager/*    - chi nhan vien quan li
 */
@WebFilter("/view/*")
public class AuthFilter5 implements Filter {
    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        req.setCharacterEncoding("UTF-8");
        res.setCharacterEncoding("UTF-8");
        HttpServletRequest rq = (HttpServletRequest) req;
        HttpServletResponse rs = (HttpServletResponse) res;
        String path = rq.getServletPath();

        String need = requiredRole(path);
        if (need == null) { chain.doFilter(req, res); return; }

        HttpSession session = rq.getSession(false);
        Member5 me = session == null ? null : (Member5) session.getAttribute("member");
        if (me == null) {
            Util5.flashErr(rq.getSession(true), "Vui lòng đăng nhập để tiếp tục.");
            rs.sendRedirect(rq.getContextPath() + "/view/member/LoginGUI5.jsp");
            return;
        }
        if (!"ANY".equals(need) && !need.equals(me.getRole())) {
            Util5.flashErr(session, "Bạn không có quyền truy cập chức năng này.");
            rs.sendRedirect(rq.getContextPath() + "/index.jsp");
            return;
        }
        // Dam bao doi tuong staff / customer co trong session (vd session cu duoc Tomcat khoi phuc sau khi khoi dong lai)
        if (me instanceof model.WarehouseStaff5 && session.getAttribute("staff") == null) session.setAttribute("staff", me);
        if (me instanceof model.Customer5 && session.getAttribute("customer") == null) session.setAttribute("customer", me);
        rs.setHeader("Cache-Control", "no-store"); // khong cache trang sau dang nhap
        chain.doFilter(req, res);
    }

    private static String requiredRole(String path) {
        if (path.startsWith("/view/customer/")) return Member5.ROLE_CUSTOMER;
        if (path.startsWith("/view/warehouse/")) return Member5.ROLE_WAREHOUSE;
        if (path.startsWith("/view/sales/")) return Member5.ROLE_SALES;
        if (path.startsWith("/view/manager/")) return Member5.ROLE_MANAGER;
        if (path.equals("/view/member/ChangePasswordGUI5.jsp")) return "ANY";
        return null; // login, register, logout, trang chu
    }
}
