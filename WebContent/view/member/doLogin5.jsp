<%
    String back = ctx + "/view/member/LoginGUI5.jsp";
    if (!"POST".equals(request.getMethod())) { response.sendRedirect(back); return; }

    String username = Util5.trim(request.getParameter("username"));
    String password = Util5.nvl(request.getParameter("password"));
    if (username.isEmpty() || password.isEmpty()) {
        Util5.flashErr(session, "Vui lòng nhập tên đăng nhập và mật khẩu.");
        response.sendRedirect(back);
        return;
    }

    Member5 found;
    try (MemberDAO5 dao = new MemberDAO5()) {
        found = dao.login(username, password);
    }
    if (found == null) {
        Util5.flashErr(session, "Sai tên đăng nhập hoặc mật khẩu.");
        response.sendRedirect(back);
        return;
    }
    request.changeSessionId(); // chong session fixation
    session.setAttribute("member", found);
    // Bang 1, Bang 2: trang chu giu doi tuong staff (nhan vien kho) / customer (khach hang) trong session
    if (found instanceof WarehouseStaff5) session.setAttribute("staff", found);
    if (found instanceof Customer5) session.setAttribute("customer", found);
    response.sendRedirect(ctx + Util5.homePath(found.getRole()));
%>