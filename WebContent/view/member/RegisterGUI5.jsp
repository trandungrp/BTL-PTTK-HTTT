<%
    if (me != null) { response.sendRedirect(ctx + Util5.homePath(me.getRole())); return; }
    String title = "Đăng kí thành viên";
    String fullName = "", birthday = "", address = "", phone = "", email = "", username = "";
    String error = null;

    if ("POST".equals(request.getMethod())) {
        fullName = Util5.trim(request.getParameter("fullName"));
        birthday = Util5.trim(request.getParameter("birthday"));
        address = Util5.trim(request.getParameter("address"));
        phone = Util5.trim(request.getParameter("phone"));
        email = Util5.trim(request.getParameter("email"));
        username = Util5.trim(request.getParameter("username"));
        String password = Util5.nvl(request.getParameter("password"));
        String confirm = Util5.nvl(request.getParameter("confirm"));

        if (fullName.isEmpty() || address.isEmpty() || phone.isEmpty() || email.isEmpty() || username.isEmpty() || password.isEmpty()) {
            error = "Vui lòng nhập đầy đủ các thông tin bắt buộc.";
        } else if (!username.matches("[A-Za-z0-9_.]{3,30}")) {
            error = "Tên đăng nhập gồm 3-30 kí tự chữ không dấu, số, dấu chấm hoặc gạch dưới.";
        } else if (password.length() < 6) {
            error = "Mật khẩu phải có ít nhất 6 kí tự.";
        } else if (!password.equals(confirm)) {
            error = "Mật khẩu nhập lại không khớp.";
        } else if (!email.matches("[^@\\s]+@[^@\\s]+\\.[^@\\s]+")) {
            error = "Email không hợp lệ.";
        } else if (!phone.matches("[0-9]{9,11}")) {
            error = "Số điện thoại gồm 9-11 chữ số.";
        } else if (!birthday.isEmpty() && Util5.parseIso(birthday) == null) {
            error = "Ngày sinh không hợp lệ.";
        } else {
            try (MemberDAO5 dao = new MemberDAO5()) {
                if (dao.usernameExists(username)) {
                    error = "Tên đăng nhập đã tồn tại, vui lòng chọn tên khác.";
                } else {
                    Customer5 c = new Customer5();
                    c.setFullName(fullName);
                    c.setBirthday(Util5.parseIso(birthday));
                    c.setAddress(address);
                    c.setPhone(phone);
                    c.setEmail(email);
                    c.setUsername(username);
                    c.setPassword(password);
                    dao.registerCustomer(c);
                }
            }
            if (error == null) {
                Util5.flashOk(session, "Đăng kí thành viên thành công. Mời bạn đăng nhập.");
                response.sendRedirect(ctx + "/view/member/LoginGUI5.jsp");
                return;
            }
        }
    }
%><%@ include file="/WEB-INF/header.jspf" %>
<div class="card" style="max-width:720px;margin:0 auto">
  <h1>Đăng kí thành viên</h1>
  <p class="sub">Tạo tài khoản khách hàng để tìm kiếm và đặt hàng trực tuyến.</p>
<% if (error != null) { %><div class="alert err"><%= h(error) %></div><% } %>
  <form class="stack" method="post" action="<%= ctx %>/view/member/RegisterGUI5.jsp" onsubmit="return chk()">
    <div class="grid2">
      <div><label>Họ và tên *</label><input type="text" name="fullName" value="<%= h(fullName) %>" maxlength="100"></div>
      <div><label>Ngày sinh</label><input type="date" name="birthday" value="<%= h(birthday) %>"></div>
      <div><label>Số điện thoại *</label><input type="text" name="phone" value="<%= h(phone) %>" maxlength="11"></div>
      <div><label>Email *</label><input type="email" name="email" value="<%= h(email) %>" maxlength="100"></div>
    </div>
    <label>Địa chỉ *</label><input type="text" name="address" value="<%= h(address) %>" maxlength="255">
    <div class="grid2">
      <div><label>Tên đăng nhập *</label><input type="text" name="username" value="<%= h(username) %>" maxlength="30" autocomplete="username"></div>
      <div></div>
      <div><label>Mật khẩu * <span class="hint">(tối thiểu 6 kí tự)</span></label><input type="password" name="password" autocomplete="new-password"></div>
      <div><label>Nhập lại mật khẩu *</label><input type="password" name="confirm" autocomplete="new-password"></div>
    </div>
    <div class="actions">
      <button class="btn" type="submit">Đăng kí</button>
      <a class="btn sec" href="<%= ctx %>/view/member/LoginGUI5.jsp">Quay lại đăng nhập</a>
    </div>
  </form>
</div>
<script>
function chk() {
  var f = document.forms[0];
  if (!f.elements['fullName'].value.trim() || !f.phone.value.trim() || !f.email.value.trim() || !f.address.value.trim() || !f.username.value.trim() || !f.password.value) {
    alert('Vui lòng nhập đầy đủ các thông tin bắt buộc'); return false;
  }
  if (f.password.value !== f.confirm.value) { alert('Mật khẩu nhập lại không khớp'); return false; }
  return true;
}
</script>
<%@ include file="/WEB-INF/footer.jspf" %>
