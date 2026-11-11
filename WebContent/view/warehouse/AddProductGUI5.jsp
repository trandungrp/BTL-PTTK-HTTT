<%
    String title = "Thêm mặt hàng";
    List<Category5> listCategory;
    try (CategoryDAO5 cdao = new CategoryDAO5()) {
        listCategory = cdao.getAllCategories();
    }
%><%@ include file="/WEB-INF/header.jspf" %>
<h1>Thêm mặt hàng</h1>
<p class="sub">Nhập thông tin mặt hàng mới.</p>
<form class="card stack" method="post" action="<%= ctx %>/view/warehouse/doAddProduct5.jsp" onsubmit="return chk()">
  <div class="grid2">
    <div><label>Tên mặt hàng *</label><input type="text" name="name" maxlength="150" autofocus></div>
    <div><label>Loại hàng *</label>
      <select name="categoryId">
<% for (Category5 c : listCategory) { %>
        <option value="<%= c.getId() %>"><%= h(c.getName()) %></option>
<% } %>
      </select></div>
    <div><label>Hãng sản xuất</label><input type="text" name="brand" maxlength="100"></div>
    <div><label>Đơn vị tính</label><input type="text" name="unit" maxlength="20" value="Chiếc"></div>
    <div><label>Giá nhập (VNĐ) *</label><input type="number" name="importPrice" min="0" step="1" value="0"></div>
    <div><label>Giá bán (VNĐ) *</label><input type="number" name="salePrice" min="0" step="1" value="0"></div>
    <div><label>Số lượng tồn ban đầu</label><input type="number" name="quantityInStock" min="0" step="1" value="0"></div>
    <div><label>Hình ảnh <span class="hint">(đường dẫn/URL)</span></label><input type="text" name="image" maxlength="255"></div>
  </div>
  <label>Mô tả</label><textarea name="description" rows="3" maxlength="500"></textarea>
  <div class="actions">
    <button class="btn" type="submit">Thêm</button>
    <a class="btn sec" href="<%= ctx %>/view/warehouse/ProductManagementGUI5.jsp">Hủy</a>
  </div>
</form>
<script>
function chk() {
  var f = document.forms[0];
  if (!f.elements['name'].value.trim()) { alert('Tên mặt hàng không được để trống'); return false; }
  if (+f.importPrice.value < 0 || +f.salePrice.value < 0) { alert('Giá phải là số không âm'); return false; }
  if (+f.quantityInStock.value < 0 || !Number.isInteger(+f.quantityInStock.value)) { alert('Số lượng tồn phải là số nguyên không âm'); return false; }
  return true;
}
</script>
<%@ include file="/WEB-INF/footer.jspf" %>
