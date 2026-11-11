<%
    String title = "Nhập hàng";
    String self = ctx + "/view/warehouse/ImportGoodsGUI5.jsp";

    // Phieu nhap dang lap (luu trong session cho den khi bam Luu)
    ImportReceipt5 draft = (ImportReceipt5) session.getAttribute("importDraft");
    if (draft == null) {
        draft = new ImportReceipt5();
        session.setAttribute("importDraft", draft);
    }

    List<Supplier5> suppliers;
    List<Product5> products;
    ImportReceipt5 savedReceipt = null;

    try (ProductDAO5 pdao = new ProductDAO5()) {
        SupplierDAO5 sdao = new SupplierDAO5(pdao.getCon());

        if ("POST".equals(request.getMethod())) {
            String action = Util5.nvl(request.getParameter("action"));
            String dest = self;
            if ("supplier".equals(action)) {
                Supplier5 sp = sdao.getSupplier(Util5.parseInt(request.getParameter("supplierId"), -1));
                if (sp == null) Util5.flashErr(session, "Vui lòng chọn nhà cung cấp.");
                else draft.setSupplier(sp);
            } else if ("add".equals(action)) {
                int pid = Util5.parseInt(request.getParameter("productId"), -1);
                int qty = Util5.parseInt(request.getParameter("quantity"), 0);
                double price = Util5.parseMoney(request.getParameter("unitPrice"), -1);
                Product5 p = pdao.getProductDetail(pid);
                if (p == null) Util5.flashErr(session, "Vui lòng chọn mặt hàng.");
                else if (qty < 1) Util5.flashErr(session, "Số lượng nhập phải là số nguyên dương.");
                else if (price < 0) Util5.flashErr(session, "Đơn giá nhập không hợp lệ.");
                else {
                    ImportDetail5 found = null;
                    for (ImportDetail5 d : draft.getListDetail()) if (d.getProduct().getId() == pid) found = d;
                    if (found == null) {
                        found = new ImportDetail5();
                        found.setProduct(p);
                        draft.getListDetail().add(found);
                        found.setQuantity(qty);
                    } else {
                        found.setQuantity(found.getQuantity() + qty);
                    }
                    found.setUnitPrice(price);
                }
            } else if ("remove".equals(action)) {
                int pid = Util5.parseInt(request.getParameter("productId"), -1);
                draft.getListDetail().removeIf(d -> d.getProduct().getId() == pid);
            } else if ("clear".equals(action)) {
                session.removeAttribute("importDraft");
                Util5.flashOk(session, "Đã hủy phiếu nhập đang lập.");
            } else if ("save".equals(action)) {
                if (draft.getSupplier() == null) {
                    Util5.flashErr(session, "Vui lòng chọn nhà cung cấp trước khi lưu.");
                } else if (draft.getListDetail().isEmpty()) {
                    Util5.flashErr(session, "Phiếu nhập chưa có mặt hàng nào.");
                } else {
                    draft.setImportDate(new Date());
                    draft.setWarehouseStaff((WarehouseStaff5) me);
                    int rid = new ImportReceiptDAO5(pdao.getCon()).saveReceipt(draft);
                    session.removeAttribute("importDraft");
                    Util5.flashOk(session, "Lưu phiếu nhập thành công. Số lượng tồn kho đã được cộng.");
                    dest = self + "?receipt=" + rid;
                }
            }
            response.sendRedirect(dest);
            return;
        }

        suppliers = sdao.getAllSuppliers();
        products = pdao.getAllProducts();
        int rcpt = Util5.parseInt(request.getParameter("receipt"), 0);
        if (rcpt > 0) savedReceipt = new ImportReceiptDAO5(pdao.getCon()).getReceipt(rcpt);
    }
    double total = draft.calculateTotal();
%><%@ include file="/WEB-INF/header.jspf" %>
<h1>Nhập hàng từ nhà cung cấp</h1>
<p class="sub">Chọn nhà cung cấp, thêm lần lượt từng mặt hàng với số lượng và đơn giá nhập, sau đó lưu phiếu.</p>

<% if (savedReceipt != null) { %>
<div class="card">
  <h2 style="margin-top:0">Phiếu nhập vừa lưu: <%= h(savedReceipt.getCode()) %></h2>
  <dl class="kv">
    <dt>Ngày nhập</dt><dd><%= Util5.fmtDateTime(savedReceipt.getImportDate()) %></dd>
    <dt>Nhà cung cấp</dt><dd><%= h(savedReceipt.getSupplier().getName()) %></dd>
    <dt>Nhân viên lập</dt><dd><%= h(savedReceipt.getWarehouseStaff().getFullName()) %></dd>
  </dl>
  <table style="margin-top:12px">
    <tr><th class="c">TT</th><th>Mặt hàng</th><th class="num">SL nhập</th><th class="num">Đơn giá nhập</th><th class="num">Thành tiền</th></tr>
<%   int k = 0; for (ImportDetail5 d : savedReceipt.getListDetail()) { k++; %>
    <tr><td class="c"><%= k %></td><td><%= h(d.getProduct().getName()) %></td><td class="num"><%= d.getQuantity() %></td>
        <td class="num"><%= m(d.getUnitPrice()) %></td><td class="num"><%= m(d.getAmount()) %></td></tr>
<%   } %>
    <tr class="total"><td></td><td colspan="3" class="num">Tổng tiền phiếu nhập</td><td class="num"><%= m(savedReceipt.getTotalAmount()) %></td></tr>
  </table>
</div>
<% } %>

<form method="post" action="<%= self %>" class="card">
  <input type="hidden" name="action" value="supplier">
  <div class="inline">
    <div class="grow"><label for="supplierId">1. Nhà cung cấp</label>
      <select id="supplierId" name="supplierId">
        <option value="">-- Chọn nhà cung cấp --</option>
<% for (Supplier5 s : suppliers) { %>
        <option value="<%= s.getId() %>"<%= draft.getSupplier() != null && draft.getSupplier().getId() == s.getId() ? " selected" : "" %>><%= h(s.getCode()) %> - <%= h(s.getName()) %></option>
<% } %>
      </select></div>
    <button class="btn" type="submit">Chọn</button>
  </div>
</form>

<form method="post" action="<%= self %>" class="card" onsubmit="return chk()">
  <input type="hidden" name="action" value="add">
  <div class="inline">
    <div class="grow"><label for="productId">2. Mặt hàng</label>
      <select id="productId" name="productId" onchange="fillPrice(this)">
        <option value="" data-price="">-- Chọn mặt hàng --</option>
<% for (Product5 p : products) { %>
        <option value="<%= p.getId() %>" data-price="<%= (long) p.getImportPrice() %>"><%= h(p.getCode()) %> - <%= h(p.getName()) %> (tồn <%= p.getQuantityInStock() %>)</option>
<% } %>
      </select></div>
    <div><label for="quantity">Số lượng</label><input type="number" id="quantity" name="quantity" min="1" step="1" style="width:110px"></div>
    <div><label for="unitPrice">Đơn giá nhập (VNĐ)</label><input type="number" id="unitPrice" name="unitPrice" min="0" step="1" style="width:170px"></div>
    <button class="btn" type="submit">Thêm vào phiếu</button>
  </div>
</form>

<h2>Phiếu nhập đang lập</h2>
<p class="sub">Nhà cung cấp: <b><%= draft.getSupplier() == null ? "(chưa chọn)" : h(draft.getSupplier().getName()) %></b></p>
<% if (draft.getListDetail().isEmpty()) { %>
<p class="empty">Chưa có mặt hàng nào trong phiếu.</p>
<% } else { %>
<table>
  <tr><th class="c">TT</th><th>Mã</th><th>Mặt hàng</th><th class="num">SL nhập</th><th class="num">Đơn giá nhập</th><th class="num">Thành tiền</th><th></th></tr>
<%   int i = 0; for (ImportDetail5 d : draft.getListDetail()) { i++; %>
  <tr>
    <td class="c"><%= i %></td><td><%= h(d.getProduct().getCode()) %></td><td><%= h(d.getProduct().getName()) %></td>
    <td class="num"><%= d.getQuantity() %></td><td class="num"><%= m(d.getUnitPrice()) %></td><td class="num"><%= m(d.getAmount()) %></td>
    <td class="c"><form method="post" action="<%= self %>" style="display:inline">
      <input type="hidden" name="action" value="remove"><input type="hidden" name="productId" value="<%= d.getProduct().getId() %>">
      <button class="btn sec small" type="submit">Xóa</button></form></td>
  </tr>
<%   } %>
  <tr class="total"><td></td><td colspan="4" class="num">Tổng tiền phiếu nhập</td><td class="num"><%= m(total) %></td><td></td></tr>
</table>
<div class="actions">
  <form method="post" action="<%= self %>" style="display:inline"><input type="hidden" name="action" value="save"><button class="btn ok" type="submit">Lưu phiếu nhập</button></form>
  <form method="post" action="<%= self %>" style="display:inline" onsubmit="return confirm('Hủy phiếu nhập đang lập?')"><input type="hidden" name="action" value="clear"><button class="btn danger" type="submit">Hủy phiếu</button></form>
</div>
<% } %>
<script>
function fillPrice(sel) {
  var p = sel.options[sel.selectedIndex].getAttribute('data-price');
  if (p) document.getElementById('unitPrice').value = p;
}
function chk() {
  if (!document.getElementById('productId').value) { alert('Vui lòng chọn mặt hàng'); return false; }
  var q = parseInt(document.getElementById('quantity').value, 10);
  if (isNaN(q) || q < 1) { alert('Số lượng nhập phải là số nguyên dương'); return false; }
  var p = document.getElementById('unitPrice').value;
  if (p === '' || +p < 0) { alert('Đơn giá nhập không hợp lệ'); return false; }
  return true;
}
</script>
<%@ include file="/WEB-INF/footer.jspf" %>
