<%
    // Hinh 6: CartGUI5.jsp { inoutListItem : Table, outTotal : label, inDeliveryAddress : textbox,
    //   subSubmit : submit, subCancelCart : submit, cart : Cart5 }
    String title = "Giỏ hàng";
    Customer5 customer = (Customer5) session.getAttribute("customer");
    Cart5 cart = (Cart5) session.getAttribute("cart");

    // subCancelCart: khach hang huy gio hang -> xoa gio, khong tao don, quay ve trang chu (ngoai le 11)
    if ("POST".equals(request.getMethod()) && request.getParameter("subCancelCart") != null) {
        try (CartDAO5 cartDAO = new CartDAO5()) {
            if (cart == null) cart = cartDAO.getCartOfCustomer(customer.getId());
            cartDAO.clearCart(cart.getId());
        }
        session.removeAttribute("cart");
        Util5.flashOk(session, "Đã hủy giỏ hàng.");
        response.sendRedirect(ctx + "/view/customer/CustomerMainGUI5.jsp");
        return;
    }

    try (CartDAO5 cartDAO = new CartDAO5()) {
        if (cart == null) cart = cartDAO.getCartOfCustomer(customer.getId());   // vao thang tu menu
        cart.setListItem(cartDAO.getItems(cart.getId()));
    }
    session.setAttribute("cart", cart);   // doSubmitOrder5.jsp dung gio hang nay
    double total = cart.calculateTotal();
    int totalQuantity = 0;
    for (CartItem5 item : cart.getListItem()) totalQuantity += item.getQuantity();
%><%@ include file="/WEB-INF/header.jspf" %>
<h1>Giỏ hàng</h1>
<% if (cart.getListItem().isEmpty()) { %>
<div class="card"><p class="empty">Giỏ hàng đang trống.</p>
  <a class="btn" href="<%= ctx %>/view/customer/OrderGUI5.jsp">Tiếp tục chọn hàng</a></div>
<% } else { %>
<form method="post" action="<%= ctx %>/view/customer/doSubmitOrder5.jsp" id="cartForm">
<table id="inoutListItem">
  <tr><th class="c">TT</th><th>Tên mặt hàng</th><th class="num">Đơn giá</th><th class="num">SL</th><th class="num">Thành tiền</th><th class="c">Xóa</th></tr>
<%   int i = 0; for (CartItem5 item : cart.getListItem()) { i++; %>
  <tr data-price="<%= (long) item.getProduct().getSalePrice() %>">
    <td class="c"><%= i %></td><td><%= h(item.getProduct().getName()) %></td>
    <td class="num"><%= m(item.getProduct().getSalePrice()) %></td>
    <td class="num">
      <input type="hidden" name="productId" value="<%= item.getProduct().getId() %>">
      <input type="number" class="qty" name="inoutListItem" value="<%= item.getQuantity() %>" min="0" max="<%= item.getProduct().getQuantityInStock() %>" step="1" oninput="recalc()">
    </td>
    <td class="num amount"><%= m(item.getAmount()) %></td>
    <td class="c"><a href="#" onclick="removeRow(this); return false;">Xóa</a></td>
  </tr>
<%   } %>
  <tr class="total"><td></td><td class="num">Tổng tiền</td><td></td><td class="num" id="outTotalQuantity"><%= totalQuantity %></td>
      <td class="num"><span id="outTotal"><%= m(total) %></span></td><td></td></tr>
</table>

<div class="card stack" style="margin-top:18px">
  <label for="inDeliveryAddress">Địa chỉ giao hàng</label>
  <input type="text" id="inDeliveryAddress" name="inDeliveryAddress" maxlength="255" placeholder="Số nhà, đường, phường/xã, quận/huyện, tỉnh/thành">
  <div class="actions">
    <button class="btn ok" type="submit" id="subSubmit" name="subSubmit" onclick="return chkSubmit()">Submit</button>
    <button class="btn danger" type="submit" id="subCancelCart" name="subCancelCart" formaction="<%= ctx %>/view/customer/CartGUI5.jsp" formnovalidate
            onclick="return confirm('Bạn chắc chắn muốn hủy giỏ hàng? Toàn bộ mặt hàng trong giỏ sẽ bị xóa.')">Hủy giỏ hàng</button>
  </div>
</div>
</form>
<script>
function fmt(n) { return n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.'); }
function recalc() {
  var total = 0, qtyTotal = 0;
  document.querySelectorAll('#inoutListItem tr[data-price]').forEach(function (tr) {
    var q = parseInt(tr.querySelector('input.qty').value, 10);
    if (isNaN(q) || q < 0) q = 0;
    var amount = q * parseInt(tr.dataset.price, 10);
    tr.querySelector('.amount').textContent = fmt(amount);
    total += amount; qtyTotal += q;
  });
  document.getElementById('outTotal').textContent = fmt(total);
  document.getElementById('outTotalQuantity').textContent = qtyTotal;
}
function removeRow(a) {
  var tr = a.closest('tr');
  tr.querySelector('input.qty').value = 0;   // so luong 0 = bo mat hang khoi don
  tr.style.display = 'none';
  recalc();
}
function chkSubmit() {
  var rows = document.querySelectorAll('#inoutListItem tr[data-price]'), any = false;
  for (var i = 0; i < rows.length; i++) {
    var inp = rows[i].querySelector('input.qty'), v = inp.value;
    if (v === '' || !Number.isInteger(+v) || +v < 0) { alert('Số lượng phải là số nguyên không âm'); inp.focus(); return false; }
    if (+v > +inp.max) { alert('Số lượng vượt quá số lượng tồn (còn ' + inp.max + ')'); inp.focus(); return false; }
    if (+v > 0) any = true;
  }
  if (!any) { alert('Giỏ hàng đang trống'); return false; }
  if (!document.getElementById('inDeliveryAddress').value.trim()) { alert('Vui lòng nhập địa chỉ giao hàng'); return false; }
  return true;
}
</script>
<% } %>
<%@ include file="/WEB-INF/footer.jspf" %>
