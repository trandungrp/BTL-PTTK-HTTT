<%
    // Hinh 4: UpdateProductGUI5.jsp { inoutName, inoutCategory : Select, inoutBrand, inoutUnit, inoutImportPrice,
    //   inoutSalePrice, inoutQuantityInStock : textbox, inoutDescription : textarea, inoutImage : file,
    //   subUpdate : submit, subCancel : link, product : Product5, listCategory : Category5[] }
    String title = "Sửa thông tin mặt hàng";
    String inProductName = Util5.nvl(request.getParameter("inProductName"));
    String backUrl = ctx + "/view/warehouse/SearchProductGUI5.jsp?mode=update&inProductName=" + Util5.urlEnc(inProductName);
    Product5 product;
    List<Category5> listCategory;
    try (ProductDAO5 productDAO = new ProductDAO5()) {
        product = productDAO.getProductDetail(Util5.parseInt(request.getParameter("id"), -1));
    }
    if (product == null) {
        Util5.flashErr(session, "Mặt hàng không tồn tại.");
        response.sendRedirect(backUrl);
        return;
    }
    try (CategoryDAO5 categoryDAO = new CategoryDAO5()) {
        listCategory = categoryDAO.getAllCategories();
    }
    session.setAttribute("product", product);   // doUpdateProduct5.jsp set lai thuoc tinh moi vao doi tuong nay
%><%@ include file="/WEB-INF/header.jspf" %>
<h1>Sửa thông tin mặt hàng</h1>
<form class="card stack" method="post" enctype="multipart/form-data" action="<%= ctx %>/view/warehouse/doUpdateProduct5.jsp" onsubmit="return chk()">
  <input type="hidden" name="id" value="<%= product.getId() %>">
  <input type="hidden" name="inProductName" value="<%= h(inProductName) %>">
  <div class="grid2">
    <div><label>Mã mặt hàng</label><input type="text" value="<%= product.getId() %>" disabled></div>
    <div><label for="inoutName">Tên mặt hàng *</label><input type="text" id="inoutName" name="inoutName" value="<%= h(product.getName()) %>" maxlength="255"></div>
    <div><label for="inoutCategory">Loại hàng *</label>
      <select id="inoutCategory" name="inoutCategory">
<% for (Category5 category : listCategory) { %>
        <option value="<%= category.getId() %>"<%= category.containsProduct(product.getId()) ? " selected" : "" %>><%= h(category.getName()) %></option>
<% } %>
      </select></div>
    <div><label for="inoutBrand">Hãng sản xuất</label><input type="text" id="inoutBrand" name="inoutBrand" value="<%= h(product.getBrand()) %>" maxlength="100"></div>
    <div><label for="inoutUnit">Đơn vị tính</label><input type="text" id="inoutUnit" name="inoutUnit" value="<%= h(product.getUnit()) %>" maxlength="20"></div>
    <div><label for="inoutImportPrice">Giá nhập (VNĐ) *</label><input type="number" id="inoutImportPrice" name="inoutImportPrice" min="0" step="1" value="<%= (long) product.getImportPrice() %>"></div>
    <div><label for="inoutSalePrice">Giá bán (VNĐ) *</label><input type="number" id="inoutSalePrice" name="inoutSalePrice" min="0" step="1" value="<%= (long) product.getSalePrice() %>"></div>
    <div><label for="inoutQuantityInStock">Số lượng tồn *</label><input type="number" id="inoutQuantityInStock" name="inoutQuantityInStock" min="0" step="1" value="<%= product.getQuantityInStock() %>"></div>
  </div>
  <label for="inoutDescription">Mô tả</label>
  <textarea id="inoutDescription" name="inoutDescription" rows="3" maxlength="1000"><%= h(product.getDescription()) %></textarea>
  <label for="inoutImage">Hình ảnh</label>
  <div>
    <div class="img-current">
<% if (!Util5.nvl(product.getImage()).isEmpty()) { %>
      <img src="<%= ctx %>/assets/images/<%= h(product.getImage()) %>" alt="" onerror="this.style.display='none'">
      <span><%= h(product.getImage()) %></span>
<% } else { %>
      <span class="hint">(chưa có ảnh)</span>
<% } %>
    </div>
    <input type="file" id="inoutImage" name="inoutImage" accept=".jpg,.jpeg,.png,.gif,.webp">
  </div>
  <div class="actions">
    <button class="btn" type="submit" id="subUpdate" name="subUpdate">Sửa</button>
    <a class="btn sec" id="subCancel" href="<%= backUrl %>">Hủy</a>
  </div>
</form>
<script>
function chk() {
  var f = document.forms[0];
  if (!f.inoutName.value.trim()) { alert('Tên mặt hàng không được để trống'); return false; }
  if (f.inoutImportPrice.value === '' || +f.inoutImportPrice.value < 0) { alert('Giá nhập phải là số không âm'); return false; }
  if (f.inoutSalePrice.value === '' || +f.inoutSalePrice.value < 0) { alert('Giá bán phải là số không âm'); return false; }
  var q = f.inoutQuantityInStock.value;
  if (q === '' || +q < 0 || !Number.isInteger(+q)) { alert('Số lượng tồn phải là số nguyên không âm'); return false; }
  var img = f.inoutImage.files[0];
  if (img && img.size > 5 * 1024 * 1024) { alert('Ảnh không được vượt quá 5MB'); return false; }
  return true;
}
</script>
<%@ include file="/WEB-INF/footer.jspf" %>
