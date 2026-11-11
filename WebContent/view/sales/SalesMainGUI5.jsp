<%
    String title = "Trang chủ nhân viên bán hàng";
%><%@ include file="/WEB-INF/header.jspf" %>
<h1>Xin chào, <%= h(me.getFullName()) %></h1>
<p class="sub">Khu vực làm việc của nhân viên bán hàng.</p>
<div class="cards">
  <a class="tile" href="<%= ctx %>/view/sales/SellAtCounterGUI5.jsp"><div class="ico">🧾</div><b>Bán hàng tại quầy</b><span>Lập hóa đơn cho khách mua trực tiếp</span></a>
  <a class="tile" href="<%= ctx %>/view/member/ChangePasswordGUI5.jsp"><div class="ico">🔑</div><b>Đổi mật khẩu</b><span>Cập nhật mật khẩu cá nhân</span></a>
</div>
<%@ include file="/WEB-INF/footer.jspf" %>
