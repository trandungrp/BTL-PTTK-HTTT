<%
    // Hinh 6: AddToCartGUI5.jsp { outProduct : Table, inQuantity : textbox, subAddToCart : submit, product : Product5 }
    String title = "Thêm vào giỏ hàng";
    String inProductName = Util5.nvl(request.getParameter("inProductName"));
    String backUrl = ctx + "/view/customer/OrderGUI5.jsp?inProductName=" + Util5.urlEnc(inProductName);
    Product5 product;
    try (ProductDAO5 productDAO = new ProductDAO5()) {
        product = productDAO.getProductDetail(Util5.parseInt(request.getParameter("id"), -1));
    }
    if (product == null) {
        Util5.flashErr(session, "Mặt hàng không tồn tại.");
        response.sendRedirect(backUrl);
        return;
    }
    session.setAttribute("product", product);   // doAddToCart5.jsp dong goi CartItem5 tu mat hang nay

    // So luong mat hang nay da co trong gio (cart do OrderGUI5.jsp giu trong session)
    Cart5 cart = (Cart5) session.getAttribute("cart");
    int inCart = 0;
    if (cart != null) for (CartItem5 item : cart.getListItem()) if (item.getProduct().getId() == product.getId()) inCart += item.getQuantity();
    int canAdd = Math.max(0, product.getQuantityInStock() - inCart);
%><%@ include file="/WEB-INF/header.jspf" %>
<h1>Thêm vào giỏ hàng</h1>
<table id="outProduct">
  <tr><th>Mã</th><th>Tên mặt hàng</th><th>Hãng SX</th><th class="num">Giá bán</th><th class="num">Tồn kho</th></tr>
  <tr><td><%= product.getId() %></td><td><%= h(product.getName()) %></td><td><%= h(product.getBrand()) %></td>
      <td class="num"><%= m(product.getSalePrice()) %></td><td class="num"><%= product.getQuantityInStock() %></td></tr>
</table>
<% if (inCart > 0) { %><div class="alert ok" style="margin-top:12px">Trong giỏ hàng đã có <b><%= inCart %></b> sản phẩm này.</div><% } %>
<% if (canAdd <= 0) { %>
<div class="alert err" style="margin-top:12px">Mặt hàng đã hết hoặc bạn đã đặt tối đa số lượng còn trong kho.</div>
<div class="actions"><a class="btn sec" href="<%= backUrl %>">Quay lại</a></div>
<% } else { %>
<form method="post" action="<%= ctx %>/view/customer/doAddToCart5.jsp" class="card" style="margin-top:14px" onsubmit="return chk()">
  <input type="hidden" name="id" value="<%= product.getId() %>">
  <input type="hidden" name="inProductName" value="<%= h(inProductName) %>">
  <div class="inline">
    <div><label for="inQuantity">Nhập số lượng</label>
      <input type="number" id="inQuantity" name="inQuantity" min="1" max="<%= canAdd %>" step="1" autofocus style="width:140px"></div>
    <button class="btn" type="submit" id="subAddToCart" name="subAddToCart">Thêm vào giỏ hàng</button>
  </div>
</form>
<script>
function chk() {
  var v = document.getElementById('inQuantity').value;
  if (v === '' || !Number.isInteger(+v) || +v < 1) { alert('Số lượng phải là số nguyên dương'); return false; }
  if (+v > <%= canAdd %>) { alert('Số lượng vượt quá số lượng tồn (còn có thể đặt <%= canAdd %>)'); return false; }
  return true;
}
</script>
<% } %>
<%@ include file="/WEB-INF/footer.jspf" %>
