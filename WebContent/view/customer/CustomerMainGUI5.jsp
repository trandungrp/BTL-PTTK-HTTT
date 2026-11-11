<%
    // Hinh 6: CustomerMainGUI5.jsp { subPlaceOrder : link, customer : Customer5 }
    String title = "Trang chủ khách hàng";
    Customer5 customer = (Customer5) session.getAttribute("customer");
%><%@ include file="/WEB-INF/header.jspf" %>
<h1>Trang chủ khách hàng</h1>
<p class="sub">Khách hàng: <b><%= h(customer.getFullName()) %></b></p>
<div class="cards">
  <a class="tile" id="subPlaceOrder" href="<%= ctx %>/view/customer/OrderGUI5.jsp"><div class="ico">🛒</div><b>Đặt hàng trực tuyến</b><span>Chọn mặt hàng, thêm vào giỏ và gửi đơn</span></a>
  <a class="tile" href="<%= ctx %>/view/customer/SearchProductGUI5.jsp"><div class="ico">🔍</div><b>Tìm kiếm mặt hàng</b><span>Xem giá và tình trạng còn hàng</span></a>
  <a class="tile" href="<%= ctx %>/view/member/ChangePasswordGUI5.jsp"><div class="ico">🔑</div><b>Đổi mật khẩu</b><span>Cập nhật mật khẩu cá nhân</span></a>
</div>
<div class="hint-box">Muốn mua trực tiếp? Hãy đến quầy của siêu thị, nhân viên bán hàng sẽ lập hóa đơn cho bạn (báo tên đăng nhập để được gắn vào tài khoản thành viên).</div>
<%@ include file="/WEB-INF/footer.jspf" %>
