<%
    String title = "Bán hàng tại quầy";
    String self = ctx + "/view/sales/SellAtCounterGUI5.jsp";
    String q = request.getParameter("q");
    boolean searched = q != null;

    // Hoa don dang lap (luu trong session cho den khi thanh toan)
    Invoice5 draft = (Invoice5) session.getAttribute("salesDraft");
    if (draft == null) {
        draft = new Invoice5();
        session.setAttribute("salesDraft", draft);
    }
    List<Product5> results = new ArrayList<>();

    try (ProductDAO5 pdao = new ProductDAO5()) {
        if ("POST".equals(request.getMethod())) {
            String action = Util5.nvl(request.getParameter("action"));
            String dest = self + (searched ? "?q=" + Util5.urlEnc(q) : "");
            if ("add".equals(action)) {
                int pid = Util5.parseInt(request.getParameter("productId"), -1);
                int qty = Util5.parseInt(request.getParameter("quantity"), 0);
                Product5 p = pdao.getProductDetail(pid);
                InvoiceDetail5 found = null;
                if (p != null) for (InvoiceDetail5 d : draft.getListDetail()) if (d.getProduct().getId() == pid) found = d;
                int already = found == null ? 0 : found.getQuantity();
                if (p == null) Util5.flashErr(session, "Mặt hàng không tồn tại.");
                else if (qty < 1) Util5.flashErr(session, "Số lượng phải là số nguyên dương.");
                else if (qty + already > p.getQuantityInStock())
                    Util5.flashErr(session, "Không đủ hàng: " + p.getName() + " chỉ còn " + p.getQuantityInStock() + " (đã chọn " + already + ").");
                else {
                    if (found == null) {
                        found = new InvoiceDetail5();
                        found.setProduct(p);
                        draft.getListDetail().add(found);
                    }
                    found.setQuantity(already + qty);
                    found.setUnitPrice(p.getSalePrice());
                }
            } else if ("remove".equals(action)) {
                int pid = Util5.parseInt(request.getParameter("productId"), -1);
                draft.getListDetail().removeIf(d -> d.getProduct().getId() == pid);
            } else if ("customer".equals(action)) {
                String uname = Util5.trim(request.getParameter("username"));
                if (uname.isEmpty()) {
                    draft.setCustomer(null);
                } else {
                    Customer5 c = new MemberDAO5(pdao.getCon()).getCustomerByUsername(uname);
                    if (c == null) Util5.flashErr(session, "Không tìm thấy khách hàng thành viên có tên đăng nhập \"" + uname + "\".");
                    else draft.setCustomer(c);
                }
            } else if ("clear".equals(action)) {
                session.removeAttribute("salesDraft");
                Util5.flashOk(session, "Đã hủy hóa đơn đang lập.");
            } else if ("checkout".equals(action)) {
                if (draft.getListDetail().isEmpty()) {
                    Util5.flashErr(session, "Hóa đơn chưa có mặt hàng nào.");
                } else {
                    draft.setSaleDate(new Date());
                    draft.setSalesperson((Salesperson5) me);
                    try {
                        int invId = new InvoiceDAO5(pdao.getCon()).saveInvoice(draft);  // luu + tru ton kho
                        session.removeAttribute("salesDraft");
                        Util5.flashOk(session, "Thanh toán thành công. Đã lưu hóa đơn và trừ tồn kho.");
                        dest = ctx + "/view/sales/InvoiceGUI5.jsp?id=" + invId;
                    } catch (DataAccessException5 ex) {
                        Util5.flashErr(session, ex.getMessage());
                    }
                }
            }
            response.sendRedirect(dest);
            return;
        }
        if (searched) results = pdao.searchByNameOrCode(q);
    }
    double total = draft.calculateTotal();
%><%@ include file="/WEB-INF/header.jspf" %>
<h1>Bán hàng tại quầy</h1>
<p class="sub">Tìm mặt hàng theo tên hoặc mã, nhập số lượng, kiểm tra tổng tiền rồi thanh toán.</p>

<form method="get" action="<%= self %>" class="card">
  <div class="inline">
    <div class="grow"><label for="q">Tìm mặt hàng (tên hoặc mã, vd MH001)</label><input type="text" id="q" name="q" value="<%= h(q) %>" autofocus></div>
    <button class="btn" type="submit">Tìm kiếm</button>
  </div>
</form>

<% if (searched) {
     if (results.isEmpty()) { %>
<div class="alert err">Không tìm thấy mặt hàng nào.</div>
<%   } else { %>
<table>
  <tr><th>Mã</th><th>Tên mặt hàng</th><th>Hãng SX</th><th class="num">Giá bán</th><th class="num">Tồn</th><th>Số lượng</th></tr>
<%     for (Product5 p : results) { %>
  <tr>
    <td><%= h(p.getCode()) %></td><td><%= h(p.getName()) %></td><td><%= h(p.getBrand()) %></td>
    <td class="num"><%= m(p.getSalePrice()) %></td>
    <td class="num"><%= p.isInStock() ? String.valueOf(p.getQuantityInStock()) : "<span class=\"out\">Hết</span>" %></td>
    <td>
<%       if (p.isInStock()) { %>
      <form method="post" action="<%= self %>?q=<%= Util5.urlEnc(q) %>" class="inline" style="flex-wrap:nowrap">
        <input type="hidden" name="action" value="add"><input type="hidden" name="productId" value="<%= p.getId() %>">
        <input type="number" name="quantity" min="1" max="<%= p.getQuantityInStock() %>" value="1" style="width:80px">
        <button class="btn small" type="submit">Thêm</button>
      </form>
<%       } %>
    </td>
  </tr>
<%     } %>
</table>
<%   }
   } %>

<h2>Hóa đơn đang lập</h2>
<form method="post" action="<%= self %><%= searched ? "?q=" + Util5.urlEnc(q) : "" %>" class="card">
  <input type="hidden" name="action" value="customer">
  <div class="inline">
    <div class="grow"><label for="username">Khách hàng thành viên (tên đăng nhập) - để trống nếu là khách vãng lai</label>
      <input type="text" id="username" name="username" value="<%= draft.getCustomer() == null ? "" : h(draft.getCustomer().getUsername() == null ? "" : draft.getCustomer().getUsername()) %>"></div>
    <button class="btn sec" type="submit">Áp dụng</button>
  </div>
  <p class="sub" style="margin:10px 0 0">Khách hàng: <b><%= draft.getCustomer() == null ? "Khách vãng lai" : h(draft.getCustomer().getFullName()) %></b></p>
</form>

<% if (draft.getListDetail().isEmpty()) { %>
<p class="empty">Chưa có mặt hàng nào trong hóa đơn.</p>
<% } else { %>
<table>
  <tr><th class="c">TT</th><th>Mã</th><th>Tên mặt hàng</th><th class="num">Đơn giá</th><th class="num">SL</th><th class="num">Thành tiền</th><th></th></tr>
<%   int i = 0; for (InvoiceDetail5 d : draft.getListDetail()) { i++; %>
  <tr>
    <td class="c"><%= i %></td><td><%= h(d.getProduct().getCode()) %></td><td><%= h(d.getProduct().getName()) %></td>
    <td class="num"><%= m(d.getUnitPrice()) %></td><td class="num"><%= d.getQuantity() %></td><td class="num"><%= m(d.getAmount()) %></td>
    <td class="c"><form method="post" action="<%= self %><%= searched ? "?q=" + Util5.urlEnc(q) : "" %>" style="display:inline">
      <input type="hidden" name="action" value="remove"><input type="hidden" name="productId" value="<%= d.getProduct().getId() %>">
      <button class="btn sec small" type="submit">Xóa</button></form></td>
  </tr>
<%   } %>
  <tr class="total"><td></td><td colspan="4" class="num">Tổng tiền hóa đơn</td><td class="num"><%= m(total) %></td><td></td></tr>
</table>
<div class="actions">
  <form method="post" action="<%= self %>" style="display:inline" onsubmit="return confirm('Xác nhận khách đã thanh toán <%= m(total) %> VNĐ?')">
    <input type="hidden" name="action" value="checkout"><button class="btn ok" type="submit">Thanh toán</button></form>
  <form method="post" action="<%= self %>" style="display:inline" onsubmit="return confirm('Hủy hóa đơn đang lập?')">
    <input type="hidden" name="action" value="clear"><button class="btn danger" type="submit">Hủy hóa đơn</button></form>
</div>
<% } %>
<%@ include file="/WEB-INF/footer.jspf" %>
