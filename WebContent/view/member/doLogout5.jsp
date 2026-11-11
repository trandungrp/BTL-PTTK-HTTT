<%
    session.invalidate();
    Util5.flashOk(request.getSession(true), "Bạn đã đăng xuất.");
    response.sendRedirect(ctx + "/view/member/LoginGUI5.jsp");
%>