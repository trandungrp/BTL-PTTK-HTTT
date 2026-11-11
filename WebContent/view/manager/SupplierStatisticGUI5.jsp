<%@ include file="/WEB-INF/daterange.jspf" %><%
    String title = "Thống kê nhà cung cấp";
    List<SupplierStatistic5> list;
    try (StatisticDAO5 dao = new StatisticDAO5()) {
        list = dao.getSupplierStatistics(fromDate, toExcl);
    }
    int sumCnt = 0;
    double sumVal = 0;
    for (SupplierStatistic5 s : list) { sumCnt += s.getReceiptCount(); sumVal += s.getTotalImportValue(); }
%><%@ include file="/WEB-INF/header.jspf" %>
<h1>Thống kê nhà cung cấp</h1>
<p class="sub">Số phiếu nhập và tổng giá trị nhập hàng theo từng nhà cung cấp trong khoảng thời gian.</p>
<form method="get" class="card">
  <div class="inline">
    <div><label>Từ ngày</label><input type="date" name="from" value="<%= fromStr %>"></div>
    <div><label>Đến ngày</label><input type="date" name="to" value="<%= toStr %>"></div>
    <button class="btn" type="submit">Thống kê</button>
    <a class="btn sec" href="<%= ctx %>/view/manager/ViewStatisticsGUI5.jsp">Quay lại</a>
  </div>
</form>
<table>
  <tr><th class="c">TT</th><th>Mã</th><th>Nhà cung cấp</th><th class="num">Số phiếu nhập</th><th class="num">Tổng giá trị nhập (VNĐ)</th></tr>
<% int i = 0; for (SupplierStatistic5 s : list) { i++; %>
  <tr><td class="c"><%= i %></td><td><%= h(s.getCode()) %></td><td><%= h(s.getName()) %></td>
      <td class="num"><%= s.getReceiptCount() %></td><td class="num"><%= m(s.getTotalImportValue()) %></td></tr>
<% } %>
  <tr class="total"><td></td><td colspan="2" class="num">Tổng</td><td class="num"><%= sumCnt %></td><td class="num"><%= m(sumVal) %></td></tr>
</table>
<%@ include file="/WEB-INF/footer.jspf" %>
