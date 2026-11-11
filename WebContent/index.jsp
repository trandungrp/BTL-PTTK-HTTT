<%
    response.sendRedirect(ctx + (me == null ? "/view/member/LoginGUI5.jsp" : Util5.homePath(me.getRole())));
%>