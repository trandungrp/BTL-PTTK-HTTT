<%
    // Hinh 4: WarehouseMainGUI5.jsp { subManageProduct : link, staff : WarehouseStaff5 }
    String title = "Trang chủ nhân viên kho";
    WarehouseStaff5 staff = (WarehouseStaff5) session.getAttribute("staff");
    int pending = 0;
    try (OrderDAO5 odao = new OrderDAO5()) {
        pending = odao.getOrdersByStatus(Order5.PENDING).size();
    }
%><%@ include file="/WEB-INF/header.jspf" %>
<h1>Trang chủ nhân viên kho</h1>
<p class="sub">Nhân viên: <b><%= h(staff.getFullName()) %></b></p>
<div class="cards">
  <a class="tile" id="subManageProduct" href="<%= ctx %>/view/warehouse/ProductManagementGUI5.jsp"><div class="ico">📦</div><b>Quản lí mặt hàng</b><span>Thêm, sửa, xóa, tìm kiếm mặt hàng</span></a>
  <a class="tile" href="<%= ctx %>/view/warehouse/SupplierManagementGUI5.jsp"><div class="ico">🏭</div><b>Quản lí nhà cung cấp</b><span>Thêm, sửa, xóa nhà cung cấp</span></a>
  <a class="tile" href="<%= ctx %>/view/warehouse/ImportGoodsGUI5.jsp"><div class="ico">🚚</div><b>Nhập hàng</b><span>Lập phiếu nhập từ nhà cung cấp</span></a>
  <a class="tile" href="<%= ctx %>/view/warehouse/ApproveOrderGUI5.jsp"><div class="ico">✅</div><b>Duyệt đơn đặt hàng</b><span><%= pending %> đơn đang chờ duyệt</span></a>
</div>
<%@ include file="/WEB-INF/footer.jspf" %>
