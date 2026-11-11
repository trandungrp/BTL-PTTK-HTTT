<%
    String title = "Xem thống kê";
%><%@ include file="/WEB-INF/header.jspf" %>
<h1>Xem thống kê</h1>
<p class="sub">Chọn loại thống kê.</p>
<div class="cards">
  <a class="tile" href="<%= ctx %>/view/manager/ProductStatisticGUI5.jsp"><div class="ico">📦</div><b>Thống kê mặt hàng</b><span>Số lượng nhập - bán - tồn</span></a>
  <a class="tile" href="<%= ctx %>/view/manager/SupplierStatisticGUI5.jsp"><div class="ico">🏭</div><b>Thống kê nhà cung cấp</b><span>Số phiếu nhập, tổng giá trị nhập</span></a>
  <a class="tile" href="<%= ctx %>/view/manager/RevenueStatisticGUI5.jsp"><div class="ico">💰</div><b>Thống kê doanh thu</b><span>Theo ngày hoặc theo tháng</span></a>
</div>
<%@ include file="/WEB-INF/footer.jspf" %>
