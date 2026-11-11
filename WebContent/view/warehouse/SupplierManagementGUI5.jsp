<%
    String title = "Quản lí nhà cung cấp";
    String q = Util5.nvl(request.getParameter("q"));
    List<Supplier5> list;
    try (SupplierDAO5 dao = new SupplierDAO5()) {
        list = dao.getSuppliersByName(q);
    }
%><%@ include file="/WEB-INF/header.jspf" %>
<div class="inline" style="justify-content:space-between;align-items:center">
  <h1 style="margin:0">Quản lí nhà cung cấp</h1>
  <a class="btn" href="<%= ctx %>/view/warehouse/EditSupplierGUI5.jsp">➕ Thêm nhà cung cấp</a>
</div>
<form method="get" action="<%= ctx %>/view/warehouse/SupplierManagementGUI5.jsp" class="card" style="margin-top:14px">
  <div class="inline">
    <div class="grow"><label for="q">Tên nhà cung cấp</label><input type="text" id="q" name="q" value="<%= h(q) %>"></div>
    <button class="btn" type="submit">Tìm kiếm</button>
  </div>
</form>
<% if (list.isEmpty()) { %>
<div class="alert err">Không tìm thấy nhà cung cấp nào.</div>
<% } else { %>
<table>
  <tr><th class="c">TT</th><th>Mã</th><th>Tên</th><th>Địa chỉ</th><th>Điện thoại</th><th>Email</th><th>Người liên hệ</th><th></th></tr>
<%   int i = 0; for (Supplier5 s : list) { i++; %>
  <tr>
    <td class="c"><%= i %></td><td><%= h(s.getCode()) %></td><td><%= h(s.getName()) %></td><td><%= h(s.getAddress()) %></td>
    <td><%= h(s.getPhone()) %></td><td><%= h(s.getEmail()) %></td><td><%= h(s.getContactPerson()) %></td>
    <td class="c" style="white-space:nowrap">
      <a class="btn small" href="<%= ctx %>/view/warehouse/EditSupplierGUI5.jsp?id=<%= s.getId() %>">Sửa</a>
      <form method="post" action="<%= ctx %>/view/warehouse/doDeleteSupplier5.jsp" style="display:inline" onsubmit="return confirm('Xóa nhà cung cấp này?')">
        <input type="hidden" name="id" value="<%= s.getId() %>"><button class="btn danger small" type="submit">Xóa</button>
      </form>
    </td>
  </tr>
<%   } %>
</table>
<% } %>
<%@ include file="/WEB-INF/footer.jspf" %>
