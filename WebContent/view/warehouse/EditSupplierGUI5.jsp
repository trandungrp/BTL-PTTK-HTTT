<%
    int sid = Util5.parseInt(request.getParameter("id"), 0);
    Supplier5 s = null;
    List<SupplierProduct5> supplied = new ArrayList<>();
    if (sid > 0) {
        try (SupplierDAO5 dao = new SupplierDAO5()) {
            s = dao.getSupplier(sid);
            if (s != null) supplied = new SupplierProductDAO5(dao.getCon()).getBySupplier(sid);
        }
        if (s == null) {
            Util5.flashErr(session, "Nhà cung cấp không tồn tại.");
            response.sendRedirect(ctx + "/view/warehouse/SupplierManagementGUI5.jsp");
            return;
        }
    }
    boolean isEdit = s != null;
    String title = isEdit ? "Sửa nhà cung cấp" : "Thêm nhà cung cấp";
%><%@ include file="/WEB-INF/header.jspf" %>
<h1><%= title %></h1>
<form class="card stack" method="post" action="<%= ctx %>/view/warehouse/doSaveSupplier5.jsp" onsubmit="return chk()">
  <input type="hidden" name="id" value="<%= isEdit ? s.getId() : 0 %>">
  <div class="grid2">
    <div><label>Tên nhà cung cấp *</label><input type="text" name="name" maxlength="150" value="<%= isEdit ? h(s.getName()) : "" %>" autofocus></div>
    <div><label>Người liên hệ</label><input type="text" name="contactPerson" maxlength="100" value="<%= isEdit ? h(s.getContactPerson()) : "" %>"></div>
    <div><label>Số điện thoại</label><input type="text" name="phone" maxlength="20" value="<%= isEdit ? h(s.getPhone()) : "" %>"></div>
    <div><label>Email</label><input type="text" name="email" maxlength="100" value="<%= isEdit ? h(s.getEmail()) : "" %>"></div>
  </div>
  <label>Địa chỉ</label><input type="text" name="address" maxlength="255" value="<%= isEdit ? h(s.getAddress()) : "" %>">
  <div class="actions">
    <button class="btn" type="submit"><%= isEdit ? "Lưu thay đổi" : "Thêm" %></button>
    <a class="btn sec" href="<%= ctx %>/view/warehouse/SupplierManagementGUI5.jsp">Hủy</a>
  </div>
</form>
<% if (isEdit) { %>
<h2>Mặt hàng đã nhập từ nhà cung cấp này</h2>
<% if (supplied.isEmpty()) { %><p class="empty">Chưa có mặt hàng nào.</p><% } else { %>
<table>
  <tr><th>Mã</th><th>Tên mặt hàng</th><th>Hãng SX</th><th class="num">Giá nhập gần nhất</th></tr>
<%   for (SupplierProduct5 sp : supplied) { %>
  <tr><td><%= h(sp.getProduct().getCode()) %></td><td><%= h(sp.getProduct().getName()) %></td>
      <td><%= h(sp.getProduct().getBrand()) %></td><td class="num"><%= m(sp.getSupplyPrice()) %></td></tr>
<%   } %>
</table>
<% } } %>
<script>
function chk() {
  var f = document.forms[0];
  if (!f.elements['name'].value.trim()) { alert('Tên nhà cung cấp không được để trống'); return false; }
  return true;
}
</script>
<%@ include file="/WEB-INF/footer.jspf" %>
