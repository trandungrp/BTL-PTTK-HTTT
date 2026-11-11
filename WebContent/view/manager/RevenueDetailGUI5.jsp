<%
    String title = "Chi tiết doanh thu";
    String mode = "month".equals(request.getParameter("mode")) ? "month" : "day";
    String period = Util5.trim(request.getParameter("period"));
    String backUrl = ctx + "/view/manager/RevenueStatisticGUI5.jsp?mode=" + mode
            + "&from=" + Util5.urlEnc(request.getParameter("from")) + "&to=" + Util5.urlEnc(request.getParameter("to"));
    if (!period.matches(mode.equals("month") ? "\\d{4}-\\d{2}" : "\\d{4}-\\d{2}-\\d{2}")) {
        Util5.flashErr(session, "Kì thống kê không hợp lệ.");
        response.sendRedirect(backUrl);
        return;
    }
    RevenueStatistic5 stat;
    try (StatisticDAO5 dao = new StatisticDAO5()) {
        stat = dao.getRevenueDetail(period, mode);
    }
%><%@ include file="/WEB-INF/header.jspf" %>
<h1>Chi tiết doanh thu <%= mode.equals("month") ? "tháng " : "ngày " %><%= h(stat.getPeriod()) %></h1>
<p class="sub">Tổng doanh thu kì này: <b><%= m(stat.getRevenue()) %> VNĐ</b> (<%= stat.getInvoiceCount() %> hóa đơn, <%= stat.getOrderCount() %> đơn hàng).</p>

<h2>Hóa đơn bán tại quầy</h2>
<% if (stat.getListInvoice().isEmpty()) { %><p class="empty">Không có hóa đơn.</p><% } else { %>
<table>
  <tr><th class="c">TT</th><th>Mã hóa đơn</th><th>Ngày bán</th><th>Nhân viên bán</th><th>Khách hàng</th><th class="num">Tổng tiền</th></tr>
<%   int i = 0; for (Invoice5 inv : stat.getListInvoice()) { i++; %>
  <tr><td class="c"><%= i %></td><td><%= h(inv.getCode()) %></td><td><%= Util5.fmtDateTime(inv.getSaleDate()) %></td>
      <td><%= h(inv.getSalesperson().getFullName()) %></td><td><%= inv.getCustomer() == null ? "Khách vãng lai" : h(inv.getCustomer().getFullName()) %></td>
      <td class="num"><%= m(inv.getTotalAmount()) %></td></tr>
<%   } %>
</table>
<% } %>

<h2>Đơn đặt hàng trực tuyến đã hoàn thành</h2>
<% if (stat.getListOrder().isEmpty()) { %><p class="empty">Không có đơn hàng.</p><% } else { %>
<table>
  <tr><th class="c">TT</th><th>Mã đơn</th><th>Ngày đặt</th><th>Khách hàng</th><th>Địa chỉ giao</th><th class="num">Tổng tiền</th></tr>
<%   int j = 0; for (Order5 o : stat.getListOrder()) { j++; %>
  <tr><td class="c"><%= j %></td><td><%= h(o.getCode()) %></td><td><%= Util5.fmtDateTime(o.getOrderDate()) %></td>
      <td><%= h(o.getCustomer().getFullName()) %></td><td><%= h(o.getDeliveryAddress()) %></td><td class="num"><%= m(o.getTotalAmount()) %></td></tr>
<%   } %>
</table>
<% } %>
<div class="actions"><a class="btn sec" href="<%= backUrl %>">Quay lại thống kê doanh thu</a></div>
<%@ include file="/WEB-INF/footer.jspf" %>
