<%
    // Hinh 4: ProductManagementGUI5.jsp { subAddProduct, subUpdateProduct, subDeleteProduct, subSearchProduct : link, staff : WarehouseStaff5 }
    String title = "Quản lí mặt hàng";
    WarehouseStaff5 staff = (WarehouseStaff5) session.getAttribute("staff");
%><%@ include file="/WEB-INF/header.jspf" %>
<h1>Quản lí mặt hàng</h1>
<p class="sub">Nhân viên: <b><%= h(staff.getFullName()) %></b></p>
<div class="cards">
  <a class="tile" id="subAddProduct" href="<%= ctx %>/view/warehouse/AddProductGUI5.jsp"><div class="ico">➕</div><b>Thêm mặt hàng</b><span>Tạo mặt hàng mới</span></a>
  <a class="tile" id="subUpdateProduct" href="<%= ctx %>/view/warehouse/SearchProductGUI5.jsp?mode=update"><div class="ico">✏️</div><b>Sửa thông tin mặt hàng</b><span>Tìm theo tên rồi chỉnh sửa</span></a>
  <a class="tile" id="subDeleteProduct" href="<%= ctx %>/view/warehouse/SearchProductGUI5.jsp?mode=delete"><div class="ico">🗑️</div><b>Xóa mặt hàng</b><span>Tìm theo tên rồi xóa</span></a>
  <a class="tile" id="subSearchProduct" href="<%= ctx %>/view/warehouse/SearchProductGUI5.jsp?mode=view"><div class="ico">🔍</div><b>Tìm kiếm mặt hàng</b><span>Xem thông tin mặt hàng</span></a>
</div>
<%@ include file="/WEB-INF/footer.jspf" %>
