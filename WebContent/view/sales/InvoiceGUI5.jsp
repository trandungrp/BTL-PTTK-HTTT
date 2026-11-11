<%
    String title = "Hóa đơn bán hàng";
    Invoice5 inv;
    try (InvoiceDAO5 dao = new InvoiceDAO5()) {
        inv = dao.getInvoice(Util5.parseInt(request.getParameter("id"), -1));
    }
    if (inv == null) {
        Util5.flashErr(session, "Hóa đơn không tồn tại.");
        response.sendRedirect(ctx + "/view/sales/SellAtCounterGUI5.jsp");
        return;
    }
%><%@ include file="/WEB-INF/header.jspf" %>
<h1>Hóa đơn bán hàng <%= h(inv.getCode()) %></h1>
<div class="card">
  <dl class="kv">
    <dt>Siêu thị</dt><dd>QLST Điện máy</dd>
    <dt>Ngày bán</dt><dd><%= Util5.fmtDateTime(inv.getSaleDate()) %></dd>
    <dt>Nhân viên bán hàng</dt><dd><%= h(inv.getSalesperson().getFullName()) %></dd>
    <dt>Khách hàng</dt><dd><%= inv.getCustomer() == null ? "Khách vãng lai" : h(inv.getCustomer().getFullName()) %></dd>
  </dl>
</div>
<table>
  <tr><th class="c">TT</th><th>Mã</th><th>Tên mặt hàng</th><th class="num">Đơn giá</th><th class="num">SL</th><th class="num">Thành tiền</th></tr>
<% int i = 0; for (InvoiceDetail5 d : inv.getListDetail()) { i++; %>
  <tr><td class="c"><%= i %></td><td><%= h(d.getProduct().getCode()) %></td><td><%= h(d.getProduct().getName()) %></td>
      <td class="num"><%= m(d.getUnitPrice()) %></td><td class="num"><%= d.getQuantity() %></td><td class="num"><%= m(d.getAmount()) %></td></tr>
<% } %>
  <tr class="total"><td></td><td colspan="4" class="num">Tổng cộng (VNĐ)</td><td class="num"><%= m(inv.getTotalAmount()) %></td></tr>
</table>
<p class="sub" style="margin-top:12px">Cảm ơn quý khách!</p>
<div class="actions no-print">
  <button class="btn" onclick="window.print()">In hóa đơn</button>
  <a class="btn sec" href="<%= ctx %>/view/sales/SellAtCounterGUI5.jsp">Lập hóa đơn mới</a>
</div>
<%@ include file="/WEB-INF/footer.jspf" %>
