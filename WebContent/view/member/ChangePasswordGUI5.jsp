<%
    String title = "Đổi mật khẩu";
    String error = null;
    if ("POST".equals(request.getMethod())) {
        String oldPw = Util5.nvl(request.getParameter("oldPassword"));
        String newPw = Util5.nvl(request.getParameter("newPassword"));
        String confirm = Util5.nvl(request.getParameter("confirm"));
        if (oldPw.isEmpty() || newPw.isEmpty()) {
            error = "Vui lòng nhập đầy đủ mật khẩu cũ và mật khẩu mới.";
        } else if (newPw.length() < 6) {
            error = "Mật khẩu mới phải có ít nhất 6 kí tự.";
        } else if (!newPw.equals(confirm)) {
            error = "Mật khẩu mới nhập lại không khớp.";
        } else {
            boolean ok;
            try (MemberDAO5 dao = new MemberDAO5()) {
                ok = dao.changePassword(me.getId(), oldPw, newPw);
            }
            if (ok) {
                Util5.flashOk(session, "Đổi mật khẩu thành công.");
                response.sendRedirect(ctx + Util5.homePath(me.getRole()));
                return;
            }
            error = "Mật khẩu cũ không đúng.";
        }
    }
%><%@ include file="/WEB-INF/header.jspf" %>
<div class="card" style="max-width:460px;margin:0 auto">
  <h1>Đổi mật khẩu</h1>
  <p class="sub">Tài khoản: <b><%= h(me.getUsername()) %></b></p>
<% if (error != null) { %><div class="alert err"><%= h(error) %></div><% } %>
  <form class="stack" method="post" action="<%= ctx %>/view/member/ChangePasswordGUI5.jsp">
    <label>Mật khẩu cũ</label><input type="password" name="oldPassword" autocomplete="current-password">
    <label>Mật khẩu mới <span class="hint">(tối thiểu 6 kí tự)</span></label><input type="password" name="newPassword" autocomplete="new-password">
    <label>Nhập lại mật khẩu mới</label><input type="password" name="confirm" autocomplete="new-password">
    <div class="actions">
      <button class="btn" type="submit">Đổi mật khẩu</button>
      <a class="btn sec" href="<%= ctx %><%= Util5.homePath(me.getRole()) %>">Hủy</a>
    </div>
  </form>
</div>
<%@ include file="/WEB-INF/footer.jspf" %>
