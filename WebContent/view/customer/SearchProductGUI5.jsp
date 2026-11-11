<%
    String title = "Tìm kiếm mặt hàng";
    String q = request.getParameter("q");
    boolean searched = q != null;
    List<Product5> list = new ArrayList<>();
    List<Category5> listCategory = new ArrayList<>();
    if (searched) {
        try (ProductDAO5 dao = new ProductDAO5()) {
            list = dao.getProductsByName(q);
        }
        try (CategoryDAO5 categoryDAO = new CategoryDAO5()) {
            listCategory = categoryDAO.getAllCategories();
        }
    }
%><%@ include file="/WEB-INF/header.jspf" %>
<h1>Tìm kiếm mặt hàng</h1>
<p class="sub">Nhập tên mặt hàng (để trống để xem tất cả).</p>
<form method="get" action="<%= ctx %>/view/customer/SearchProductGUI5.jsp" class="card">
  <div class="inline">
    <div class="grow"><label for="q">Tên mặt hàng</label><input type="text" id="q" name="q" value="<%= h(q) %>" placeholder="vd: tủ lạnh" autofocus></div>
    <button class="btn" type="submit">Tìm kiếm</button>
  </div>
</form>
<% if (searched) {
     if (list.isEmpty()) { %>
<div class="alert err">Không tìm thấy mặt hàng nào khớp với tên tìm kiếm.</div>
<%   } else { %>
<table>
  <tr><th class="c">TT</th><th>Mã</th><th>Tên mặt hàng</th><th>Loại hàng</th><th>Hãng SX</th><th class="num">Giá bán</th><th>Tình trạng</th></tr>
<%     int i = 0; for (Product5 p : list) { i++; %>
  <tr>
    <td class="c"><%= i %></td><td><%= h(p.getCode()) %></td><td><%= h(p.getName()) %></td>
    <td><%= h(categoryOf(listCategory, p.getId())) %></td><td><%= h(p.getBrand()) %></td>
    <td class="num"><%= m(p.getSalePrice()) %></td>
    <td><%= p.isInStock() ? "<span class=\"in\">Còn hàng</span>" : "<span class=\"out\">Hết hàng</span>" %></td>
  </tr>
<%     } %>
</table>
<div class="actions"><a class="btn" href="<%= ctx %>/view/customer/OrderGUI5.jsp?inProductName=<%= Util5.urlEnc(q) %>">Đặt hàng các mặt hàng này</a></div>
<%   }
   } %>
<%@ include file="/WEB-INF/footer.jspf" %>
