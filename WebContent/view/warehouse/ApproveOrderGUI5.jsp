<%
    String title = "Duyệt đơn đặt hàng";
    String self = ctx + "/view/warehouse/ApproveOrderGUI5.jsp";
    int selId = Util5.parseInt(request.getParameter("id"), 0);

    List<Order5> pendingOrders, approvedOrders;
    List<Shipper5> shippers;
    Order5 sel = null;
    try (OrderDAO5 odao = new OrderDAO5()) {
        pendingOrders = odao.getOrdersByStatus(Order5.PENDING);
        approvedOrders = odao.getOrdersByStatus(Order5.APPROVED);
        shippers = new ShipperDAO5(odao.getCon()).getAllShippers();
        if (selId > 0) sel = odao.getOrder(selId);
    }
%><%@ include file="/WEB-INF/header.jspf" %>
<h1>Duyệt đơn đặt hàng trực tuyến</h1>
<p class="sub">Chọn một đơn đang chờ duyệt để xem chi tiết và đối chiếu số lượng tồn kho.</p>

<h2>Đơn chờ duyệt (<%= pendingOrders.size() %>)</h2>
<% if (pendingOrders.isEmpty()) { %><p class="empty">Không có đơn nào đang chờ duyệt.</p><% } else { %>
<table>
  <tr><th>Mã đơn</th><th>Ngày đặt</th><th>Khách hàng</th><th class="num">Tổng tiền</th><th></th></tr>
<%   for (Order5 o : pendingOrders) { %>
  <tr class="click" onclick="location.href='<%= self %>?id=<%= o.getId() %>'">
    <td><%= h(o.getCode()) %></td><td><%= Util5.fmtDateTime(o.getOrderDate()) %></td><td><%= h(o.getCustomer().getFullName()) %></td>
    <td class="num"><%= m(o.getTotalAmount()) %></td><td class="c"><a class="btn small" href="<%= self %>?id=<%= o.getId() %>">Xem chi tiết</a></td>
  </tr>
<%   } %>
</table>
<% } %>

<% if (sel != null) {
     boolean enough = true;
     for (OrderDetail5 d : sel.getListDetail()) if (d.getQuantity() > d.getProduct().getQuantityInStock()) enough = false; %>
<h2 id="detail">Chi tiết đơn <%= h(sel.getCode()) %> <span class="badge <%= sel.getStatus() %>"><%= h(sel.getStatusLabel()) %></span></h2>
<div class="card">
  <dl class="kv">
    <dt>Ngày đặt</dt><dd><%= Util5.fmtDateTime(sel.getOrderDate()) %></dd>
    <dt>Khách hàng</dt><dd><%= h(sel.getCustomer().getFullName()) %> · <%= h(sel.getCustomer().getPhone()) %></dd>
    <dt>Địa chỉ giao hàng</dt><dd><%= h(sel.getDeliveryAddress()) %></dd>
<%   if (sel.getApprovedBy() != null) { %><dt>Nhân viên duyệt</dt><dd><%= h(sel.getApprovedBy().getFullName()) %></dd><% } %>
<%   if (sel.getShipper() != null) { %><dt>Nhân viên giao hàng</dt><dd><%= h(sel.getShipper().getFullName()) %> · <%= h(sel.getShipper().getPhone()) %></dd><% } %>
  </dl>
</div>
<table>
  <tr><th class="c">TT</th><th>Mặt hàng</th><th class="num">SL đặt</th><th class="num">Tồn kho</th><th class="num">Đơn giá</th><th class="num">Thành tiền</th></tr>
<%   int i = 0; for (OrderDetail5 d : sel.getListDetail()) { i++;
       boolean lack = d.getQuantity() > d.getProduct().getQuantityInStock(); %>
  <tr>
    <td class="c"><%= i %></td><td><%= h(d.getProduct().getName()) %></td><td class="num"><%= d.getQuantity() %></td>
    <td class="num"><%= Order5.PENDING.equals(sel.getStatus()) ? (lack ? "<span class=\"out\">" + d.getProduct().getQuantityInStock() + " (thiếu)</span>" : "<span class=\"in\">" + d.getProduct().getQuantityInStock() + "</span>") : "-" %></td>
    <td class="num"><%= m(d.getUnitPrice()) %></td><td class="num"><%= m(d.getAmount()) %></td>
  </tr>
<%   } %>
  <tr class="total"><td></td><td colspan="4" class="num">Tổng tiền</td><td class="num"><%= m(sel.getTotalAmount()) %></td></tr>
</table>
<%   if (Order5.PENDING.equals(sel.getStatus())) { %>
<form method="post" action="<%= ctx %>/view/warehouse/doApproveOrder5.jsp" class="card" style="margin-top:14px" id="approveForm">
  <input type="hidden" name="id" value="<%= sel.getId() %>">
  <input type="hidden" name="action" id="act" value="approve">
<%     if (!enough) { %><div class="alert err">Một số mặt hàng không đủ tồn kho. Bạn có thể từ chối đơn hoặc để đơn ở trạng thái chờ (nhập thêm hàng rồi duyệt sau).</div><% } %>
  <div class="inline">
    <div class="grow"><label for="shipperId">Nhân viên giao hàng nhận đơn</label>
      <select id="shipperId" name="shipperId">
<%     for (Shipper5 sh : shippers) { %><option value="<%= sh.getId() %>"><%= h(sh.getFullName()) %> - <%= h(sh.getPhone()) %></option><% } %>
      </select></div>
    <button class="btn ok" type="submit"<%= enough ? "" : " disabled" %>>Duyệt &amp; xuất giao hàng</button>
    <button class="btn danger" type="button" onclick="reject()">Từ chối đơn</button>
    <a class="btn sec" href="<%= self %>">Để chờ</a>
  </div>
</form>
<script>
function reject() {
  if (confirm('Từ chối đơn hàng này?')) { document.getElementById('act').value = 'reject'; document.getElementById('approveForm').submit(); }
}
</script>
<%   } else if (Order5.APPROVED.equals(sel.getStatus())) { %>
<div class="actions"><a class="btn" href="<%= ctx %>/view/warehouse/DeliveryNoteGUI5.jsp?id=<%= sel.getId() %>">Xem phiếu xuất giao hàng</a></div>
<%   }
   } %>

<h2>Đơn đã duyệt - đang giao (<%= approvedOrders.size() %>)</h2>
<% if (approvedOrders.isEmpty()) { %><p class="empty">Không có đơn nào đang giao.</p><% } else { %>
<table>
  <tr><th>Mã đơn</th><th>Ngày đặt</th><th>Khách hàng</th><th>Giao hàng</th><th class="num">Tổng tiền</th><th></th></tr>
<%   for (Order5 o : approvedOrders) { %>
  <tr>
    <td><a href="<%= self %>?id=<%= o.getId() %>"><%= h(o.getCode()) %></a></td><td><%= Util5.fmtDateTime(o.getOrderDate()) %></td>
    <td><%= h(o.getCustomer().getFullName()) %></td><td><%= o.getShipper() == null ? "" : h(o.getShipper().getFullName()) %></td>
    <td class="num"><%= m(o.getTotalAmount()) %></td>
    <td class="c" style="white-space:nowrap">
      <a class="btn sec small" href="<%= ctx %>/view/warehouse/DeliveryNoteGUI5.jsp?id=<%= o.getId() %>">Phiếu giao</a>
      <form method="post" action="<%= ctx %>/view/warehouse/doApproveOrder5.jsp" style="display:inline" onsubmit="return confirm('Xác nhận đơn đã giao xong?')">
        <input type="hidden" name="action" value="complete"><input type="hidden" name="id" value="<%= o.getId() %>">
        <button class="btn ok small" type="submit">Đã giao xong</button>
      </form>
    </td>
  </tr>
<%   } %>
</table>
<% } %>
<%@ include file="/WEB-INF/footer.jspf" %>
