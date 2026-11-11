<%@ include file="/WEB-INF/daterange.jspf" %><%
    String title = "Thống kê doanh thu";
    String mode = "month".equals(request.getParameter("mode")) ? "month" : "day";
    List<RevenueStatistic5> list;
    try (StatisticDAO5 dao = new StatisticDAO5()) {
        list = dao.getRevenueStatistics(fromDate, toExcl, mode);
    }
    int sumInv = 0, sumOrd = 0;
    double sumRev = 0;
    for (RevenueStatistic5 s : list) { sumInv += s.getInvoiceCount(); sumOrd += s.getOrderCount(); sumRev += s.getRevenue(); }
%><%@ include file="/WEB-INF/header.jspf" %>
<h1>Thống kê doanh thu</h1>
<p class="sub">Tổng hợp từ hóa đơn bán tại quầy và đơn đặt hàng trực tuyến đã hoàn thành. Bấm vào một dòng để xem chi tiết kì đó.</p>
<form method="get" class="card">
  <div class="inline">
    <div><label>Từ ngày</label><input type="date" name="from" value="<%= fromStr %>"></div>
    <div><label>Đến ngày</label><input type="date" name="to" value="<%= toStr %>"></div>
    <div><label>Thống kê theo</label>
      <select name="mode" style="width:130px">
        <option value="day"<%= mode.equals("day") ? " selected" : "" %>>Ngày</option>
        <option value="month"<%= mode.equals("month") ? " selected" : "" %>>Tháng</option>
      </select></div>
    <button class="btn" type="submit">Thống kê</button>
    <a class="btn sec" href="<%= ctx %>/view/manager/ViewStatisticsGUI5.jsp">Quay lại</a>
  </div>
</form>
<% if (list.isEmpty()) { %>
<div class="alert err">Không có doanh thu trong khoảng thời gian đã chọn.</div>
<% } else { %>
<table>
  <tr><th class="c">TT</th><th><%= mode.equals("month") ? "Tháng" : "Ngày" %></th><th class="num">Số hóa đơn</th><th class="num">Số đơn hàng</th><th class="num">Doanh thu (VNĐ)</th></tr>
<%   int i = 0; for (RevenueStatistic5 s : list) { i++;
       String detailUrl = ctx + "/view/manager/RevenueDetailGUI5.jsp?period=" + Util5.urlEnc(s.getPeriod())
                        + "&mode=" + mode + "&from=" + fromStr + "&to=" + toStr; %>
  <tr class="click" onclick="location.href='<%= detailUrl %>'">
    <td class="c"><%= i %></td><td><a href="<%= detailUrl %>"><%= h(s.getPeriod()) %></a></td>
    <td class="num"><%= s.getInvoiceCount() %></td><td class="num"><%= s.getOrderCount() %></td><td class="num"><%= m(s.getRevenue()) %></td>
  </tr>
<%   } %>
  <tr class="total"><td></td><td class="num">Tổng doanh thu</td><td class="num"><%= sumInv %></td><td class="num"><%= sumOrd %></td><td class="num"><%= m(sumRev) %></td></tr>
</table>
<% } %>
<%@ include file="/WEB-INF/footer.jspf" %>
