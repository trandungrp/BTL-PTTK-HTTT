<%
    // Hinh 6: OrderGUI5.jsp { inProductName : textbox, subSearch : submit, outsubListProduct : Table,
    //   subViewCart : link, outCartCount : label, listProduct : Product5[], cart : Cart5 }
    // Trang submit (GET) vao chinh no de tim mat hang theo ten.
    String title = "Đặt hàng trực tuyến";
    Customer5 customer = (Customer5) session.getAttribute("customer");
    String inProductName = request.getParameter("inProductName");
    boolean searched = inProductName != null;
    Cart5 cart;
    List<Product5> listProduct = new ArrayList<>();
    try (CartDAO5 cartDAO = new CartDAO5()) {
        cart = cartDAO.getCartOfCustomer(customer.getId());   // tao gio hang trong neu khach chua co gio
    }
    session.setAttribute("cart", cart);
    if (searched) {
        try (ProductDAO5 productDAO = new ProductDAO5()) {
            listProduct = productDAO.getProductsByName(inProductName);
        }
    }
%><%@ include file="/WEB-INF/header.jspf" %>
<div class="inline" style="justify-content:space-between;align-items:center">
  <h1 style="margin:0">Đặt hàng trực tuyến</h1>
  <a class="btn sec cart-link" id="subViewCart" href="<%= ctx %>/view/customer/CartGUI5.jsp">🛒 Giỏ hàng (<span id="outCartCount"><%= cart.getListItem().size() %></span>)</a>
</div>
<form method="get" action="<%= ctx %>/view/customer/OrderGUI5.jsp" class="card" style="margin-top:14px">
  <div class="inline">
    <div class="grow"><label for="inProductName">Tên mặt hàng</label>
      <input type="text" id="inProductName" name="inProductName" value="<%= h(inProductName) %>" placeholder="vd: máy giặt" autofocus></div>
    <button class="btn" type="submit" id="subSearch" name="subSearch">Tìm kiếm</button>
  </div>
</form>
<% if (searched) {
     if (listProduct.isEmpty()) { %>
<div class="alert err">Không tìm thấy mặt hàng nào khớp với tên tìm kiếm.</div>
<%   } else { %>
<table id="outsubListProduct">
  <tr><th class="c">TT</th><th>Mã</th><th>Tên mặt hàng</th><th>Hãng SX</th><th class="num">Giá bán</th><th>Tình trạng</th></tr>
<%     int i = 0; for (Product5 product : listProduct) { i++; %>
  <tr>
    <td class="c"><%= i %></td><td><%= product.getId() %></td>
    <td><% if (product.isInStock()) { %><a href="<%= ctx %>/view/customer/AddToCartGUI5.jsp?id=<%= product.getId() %>&amp;inProductName=<%= Util5.urlEnc(inProductName) %>"><%= h(product.getName()) %></a><% } else { %><%= h(product.getName()) %><% } %></td>
    <td><%= h(product.getBrand()) %></td>
    <td class="num"><%= m(product.getSalePrice()) %></td>
    <td><%= product.isInStock() ? "<span class=\"in\">Còn hàng</span>" : "<span class=\"out\">Hết hàng</span>" %></td>
  </tr>
<%     } %>
</table>
<p class="hint">Click vào tên mặt hàng để chọn và nhập số lượng.</p>
<%   }
   } %>
<%@ include file="/WEB-INF/footer.jspf" %>
