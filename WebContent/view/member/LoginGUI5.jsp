<%
    if (me != null) { response.sendRedirect(ctx + Util5.homePath(me.getRole())); return; }
    String title = "Đăng nhập";
%><%@ include file="/WEB-INF/header.jspf" %>
<div class="card login-box">
  <h1>Đăng nhập</h1>
  <p class="sub">Dành cho khách hàng và nhân viên siêu thị.</p>
  <form class="stack" method="post" action="<%= ctx %>/view/member/doLogin5.jsp" onsubmit="return chk()">
    <label for="username">Tên đăng nhập</label>
    <input type="text" id="username" name="username" autofocus autocomplete="username">
    <label for="password">Mật khẩu</label>
    <input type="password" id="password" name="password" autocomplete="current-password">
    <div class="actions">
      <button class="btn" type="submit">Đăng nhập</button>
      <a class="btn sec" href="<%= ctx %>/view/member/RegisterGUI5.jsp">Đăng kí thành viên</a>
    </div>
  </form>
</div>
<script>
function chk() {
  var u = document.getElementById('username').value.trim(), p = document.getElementById('password').value;
  if (!u || !p) { alert('Vui lòng nhập tên đăng nhập và mật khẩu'); return false; }
  return true;
}
</script>
<%@ include file="/WEB-INF/footer.jspf" %>
