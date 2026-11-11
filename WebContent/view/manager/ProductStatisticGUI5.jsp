<%@ include file="/WEB-INF/daterange.jspf" %><%
    String title = "Thống kê mặt hàng";
    List<ProductStatistic5> list;
    try (StatisticDAO5 dao = new StatisticDAO5()) {
        list = dao.getProductStatistics(fromDate, toExcl);
    }
    List<Category5> listCategory;
    try (CategoryDAO5 categoryDAO = new CategoryDAO5()) {
        listCategory = categoryDAO.getAllCategories();
    }
    int sumImp = 0, sumSold = 0, sumRemain = 0;
    for (ProductStatistic5 s : list) { sumImp += s.getImportedQuantity(); sumSold += s.getSoldQuantity(); sumRemain += s.getRemainQuantity(); }
%><%@ include file="/WEB-INF/header.jspf" %>
<h1>Thống kê mặt hàng</h1>
<p class="sub">Số lượng nhập, bán (hóa đơn tại quầy + đơn online đã duyệt) trong khoảng thời gian; tồn là số lượng hiện tại trong kho.</p>
<form method="get" class="card">
  <div class="inline">
    <div><label>Từ ngày</label><input type="date" name="from" value="<%= fromStr %>"></div>
    <div><label>Đến ngày</label><input type="date" name="to" value="<%= toStr %>"></div>
    <button class="btn" type="submit">Thống kê</button>
    <a class="btn sec" href="<%= ctx %>/view/manager/ViewStatisticsGUI5.jsp">Quay lại</a>
  </div>
</form>
<table>
  <tr><th class="c">TT</th><th>Mã</th><th>Tên mặt hàng</th><th>Loại hàng</th><th class="num">SL nhập</th><th class="num">SL bán</th><th class="num">Tồn kho</th></tr>
<% int i = 0; for (ProductStatistic5 s : list) { i++; %>
  <tr><td class="c"><%= i %></td><td><%= h(s.getCode()) %></td><td><%= h(s.getName()) %></td><td><%= h(categoryOf(listCategory, s.getId())) %></td>
      <td class="num"><%= s.getImportedQuantity() %></td><td class="num"><%= s.getSoldQuantity() %></td>
      <td class="num"><%= s.getRemainQuantity() == 0 ? "<span class=\"out\">0</span>" : String.valueOf(s.getRemainQuantity()) %></td></tr>
<% } %>
  <tr class="total"><td></td><td colspan="3" class="num">Tổng</td><td class="num"><%= sumImp %></td><td class="num"><%= sumSold %></td><td class="num"><%= sumRemain %></td></tr>
</table>
<%@ include file="/WEB-INF/footer.jspf" %>
