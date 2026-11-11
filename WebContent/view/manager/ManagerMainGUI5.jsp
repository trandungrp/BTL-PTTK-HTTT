<%
    String title = "Trang chủ quản lí";
%><%@ include file="/WEB-INF/header.jspf" %>
<h1>Xin chào, <%= h(me.getFullName()) %></h1>
<p class="sub">Khu vực làm việc của nhân viên quản lí.</p>
<div class="cards">
  <a class="tile" href="<%= ctx %>/view/manager/ViewStatisticsGUI5.jsp"><div class="ico">📊</div><b>Xem thống kê</b><span>Mặt hàng, nhà cung cấp, doanh thu</span></a>
  <a class="tile" href="<%= ctx %>/view/member/ChangePasswordGUI5.jsp"><div class="ico">🔑</div><b>Đổi mật khẩu</b><span>Cập nhật mật khẩu cá nhân</span></a>
</div>
<%@ include file="/WEB-INF/footer.jspf" %>
