<%
    // Hinh 4: SearchProductGUI5.jsp { inProductName : textbox, subSearch : submit, outsubListProduct : Table, listProduct : Product5[] }
    // Trang submit (GET) vao chinh no. Tham so mode (an) dung chung trang cho cac chuc nang sua / xoa / tim kiem.
    String title = "Tìm kiếm mặt hàng";
    String mode = Util5.nvl(request.getParameter("mode"));
    if (!mode.equals("update") && !mode.equals("delete")) mode = "view";
    String inProductName = request.getParameter("inProductName");
    boolean searched = inProductName != null;
    List<Product5> listProduct = new ArrayList<>();
    if (searched) {
        try (ProductDAO5 productDAO = new ProductDAO5()) {
            listProduct = productDAO.getProductsByName(inProductName);
        }
    }
    String heading = mode.equals("update") ? "Tìm mặt hàng cần sửa" : mode.equals("delete") ? "Tìm mặt hàng cần xóa" : "Tìm kiếm mặt hàng";
%><%@ include file="/WEB-INF/header.jspf" %>
<h1><%= heading %></h1>
<form method="get" action="<%= ctx %>/view/warehouse/SearchProductGUI5.jsp" class="card">
  <input type="hidden" name="mode" value="<%= mode %>">
  <div class="inline">
    <div class="grow"><label for="inProductName">Tên mặt hàng</label>
      <input type="text" id="inProductName" name="inProductName" value="<%= h(inProductName) %>" placeholder="vd: tủ lạnh" autofocus></div>
    <button class="btn" type="submit" id="subSearch" name="subSearch">Tìm kiếm</button>
    <a class="btn sec" href="<%= ctx %>/view/warehouse/ProductManagementGUI5.jsp">Quay lại</a>
  </div>
</form>
<% if (searched) {
     if (listProduct.isEmpty()) { %>
<div class="alert err">Không tìm thấy mặt hàng nào khớp với tên tìm kiếm.</div>
<%   } else { %>
<table id="outsubListProduct">
  <tr><th class="c">TT</th><th>Mã</th><th>Tên mặt hàng</th><th>Hãng SX</th><th class="num">Giá bán</th><th class="num">Tồn</th><% if (!mode.equals("view")) { %><th class="c">Chọn</th><% } %></tr>
<%     int i = 0; for (Product5 product : listProduct) { i++;
         String editUrl = ctx + "/view/warehouse/UpdateProductGUI5.jsp?id=" + product.getId() + "&inProductName=" + Util5.urlEnc(inProductName); %>
  <tr>
    <td class="c"><%= i %></td><td><%= product.getId() %></td><td><%= h(product.getName()) %></td>
    <td><%= h(product.getBrand()) %></td>
    <td class="num"><%= m(product.getSalePrice()) %></td>
    <td class="num"><%= product.getQuantityInStock() == 0 ? "<span class=\"out\">0</span>" : String.valueOf(product.getQuantityInStock()) %></td>
<%       if (mode.equals("update")) { %>
    <td class="c"><a href="<%= editUrl %>">Sửa</a></td>
<%       } else if (mode.equals("delete")) { %>
    <td class="c">
      <form method="post" action="<%= ctx %>/view/warehouse/doDeleteProduct5.jsp" style="display:inline"
            onsubmit="return confirm('Xóa mặt hàng này? Thao tác không thể hoàn tác.')">
        <input type="hidden" name="id" value="<%= product.getId() %>"><input type="hidden" name="inProductName" value="<%= h(inProductName) %>">
        <button class="btn danger small" type="submit">Xóa</button>
      </form>
    </td>
<%       } %>
  </tr>
<%     } %>
</table>
<%   }
   } %>
<%@ include file="/WEB-INF/footer.jspf" %>
