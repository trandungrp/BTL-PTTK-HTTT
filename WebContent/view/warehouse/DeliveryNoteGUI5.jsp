<%
    String title = "Phiếu xuất giao hàng";
    Order5 o;
    try (OrderDAO5 odao = new OrderDAO5()) {
        o = odao.getOrder(Util5.parseInt(request.getParameter("id"), -1));
    }
    if (o == null || o.getShipper() == null) {
        Util5.flashErr(session, "Đơn hàng chưa được xuất giao.");
        response.sendRedirect(ctx + "/view/warehouse/ApproveOrderGUI5.jsp");
        return;
    }
%><%@ include file="/WEB-INF/header.jspf" %>
<h1>Phiếu xuất giao hàng</h1>
<p class="sub">Thông tin đơn xuất cho nhân viên giao hàng.</p>
<div class="card">
  <dl class="kv">
    <dt>Mã đơn</dt><dd><%= h(o.getCode()) %></dd>
    <dt>Nhân viên giao hàng</dt><dd><%= h(o.getShipper().getFullName()) %> · <%= h(o.getShipper().getPhone()) %></dd>
    <dt>Khách hàng</dt><dd><%= h(o.getCustomer().getFullName()) %> · <%= h(o.getCustomer().getPhone()) %></dd>
    <dt>Địa chỉ giao</dt><dd><%= h(o.getDeliveryAddress()) %></dd>
    <dt>Nhân viên kho duyệt</dt><dd><%= o.getApprovedBy() == null ? "" : h(o.getApprovedBy().getFullName()) %></dd>
    <dt>Trạng thái</dt><dd><span class="badge <%= o.getStatus() %>"><%= h(o.getStatusLabel()) %></span></dd>
  </dl>
</div>
<table>
  <tr><th class="c">TT</th><th>Mã</th><th>Mặt hàng</th><th class="num">Số lượng</th><th class="num">Thành tiền</th></tr>
<% int i = 0; for (OrderDetail5 d : o.getListDetail()) { i++; %>
  <tr><td class="c"><%= i %></td><td><%= h(d.getProduct().getCode()) %></td><td><%= h(d.getProduct().getName()) %></td>
      <td class="num"><%= d.getQuantity() %></td><td class="num"><%= m(d.getAmount()) %></td></tr>
<% } %>
  <tr class="total"><td></td><td colspan="3" class="num">Tổng tiền thu hộ</td><td class="num"><%= m(o.getTotalAmount()) %></td></tr>
</table>
<div class="actions no-print">
  <button class="btn" onclick="window.print()">In phiếu</button>
  <a class="btn sec" href="<%= ctx %>/view/warehouse/ApproveOrderGUI5.jsp">Quay lại danh sách đơn</a>
</div>
<%@ include file="/WEB-INF/footer.jspf" %>
