<%
    // Hinh 6: doSubmitOrder5.jsp { outOrder : Table, order : Order5, cart : Cart5 }
    String title = "Lưu đơn hàng thành công";
    String cartUrl = ctx + "/view/customer/CartGUI5.jsp";
    if (!"POST".equals(request.getMethod())) { response.sendRedirect(cartUrl); return; }

    Customer5 customer = (Customer5) session.getAttribute("customer");
    Cart5 cart = (Cart5) session.getAttribute("cart");   // gio hang do CartGUI5.jsp giu trong session
    if (cart == null) { response.sendRedirect(cartUrl); return; }

    // Ap dung so luong khach sua tren bang inoutListItem (0 = da xoa dong do)
    String[] productIds = request.getParameterValues("productId");
    String[] quantities = request.getParameterValues("inoutListItem");
    Map<Integer, Integer> newQuantity = new HashMap<>();
    if (productIds != null && quantities != null && productIds.length == quantities.length) {
        for (int k = 0; k < productIds.length; k++) {
            int q = Util5.parseInt(quantities[k], -1);
            if (q < 0) {
                Util5.flashErr(session, "Số lượng phải là số nguyên không âm.");
                response.sendRedirect(cartUrl);
                return;
            }
            newQuantity.put(Util5.parseInt(productIds[k], -1), q);
        }
    }
    List<CartItem5> listItem = new ArrayList<>();
    for (CartItem5 item : cart.getListItem()) {
        Integer q = newQuantity.get(item.getProduct().getId());
        if (q != null) item.setQuantity(q);
        if (item.getQuantity() > 0) listItem.add(item);
    }
    cart.setListItem(listItem);

    String inDeliveryAddress = Util5.trim(request.getParameter("inDeliveryAddress"));
    if (listItem.isEmpty()) {
        Util5.flashErr(session, "Giỏ hàng đang trống, không thể đặt hàng.");
        response.sendRedirect(cartUrl);
        return;
    }
    if (inDeliveryAddress.isEmpty()) {
        Util5.flashErr(session, "Vui lòng nhập địa chỉ giao hàng");
        response.sendRedirect(cartUrl);
        return;
    }

    Order5 order;
    try (ProductDAO5 productDAO = new ProductDAO5()) {
        // Kiem tra lai so luong ton cua cac mat hang trong gio
        if (!productDAO.checkStock(cart.getListItem())) {
            Util5.flashErr(session, "Số lượng tồn của một số mặt hàng không đủ, vui lòng điều chỉnh giỏ hàng.");
            response.sendRedirect(cartUrl);
            return;
        }

        // Lop Order5 dong goi don hang: khach hang, ngay dat, dia chi giao, trang thai "cho duyet", OrderDetail5 tu cac dong gio
        order = new Order5();
        order.setCustomer(customer);
        order.setOrderDate(new Date());
        order.setDeliveryAddress(inDeliveryAddress);
        order.setStatus(Order5.PENDING);
        for (CartItem5 item : cart.getListItem()) {
            OrderDetail5 orderDetail = new OrderDetail5();
            orderDetail.setProduct(item.getProduct());
            orderDetail.setQuantity(item.getQuantity());
            orderDetail.setUnitPrice(item.getProduct().getSalePrice());   // gia tai thoi diem dat
            order.getListDetail().add(orderDetail);
        }
        order.calculateTotal();

        // OrderDAO5.saveOrder() goi OrderDetailDAO5.saveOrderDetail() trong cung mot transaction
        OrderDAO5 orderDAO = new OrderDAO5(productDAO.getCon());
        if (!orderDAO.saveOrder(order)) {
            Util5.flashErr(session, "Không lưu được đơn hàng, vui lòng thử lại.");
            response.sendRedirect(cartUrl);
            return;
        }

        // Xoa gio hang tam
        new CartDAO5(productDAO.getCon()).clearCart(cart.getId());
    }
    session.removeAttribute("cart");
%><%@ include file="/WEB-INF/header.jspf" %>
<div class="card notice" style="max-width:520px;text-align:left">
  <h2 style="text-align:center">Lưu đơn hàng thành công</h2>
  <table id="outOrder">
    <tr><th>Mã đơn hàng</th><td><%= order.getId() %></td></tr>
    <tr><th>Ngày đặt</th><td><%= Util5.fmtDate(order.getOrderDate()) %></td></tr>
    <tr><th>Khách hàng</th><td><%= h(customer.getFullName()) %></td></tr>
    <tr><th>Địa chỉ giao</th><td><%= h(order.getDeliveryAddress()) %></td></tr>
    <tr><th>Tổng tiền</th><td><%= m(order.getTotalAmount()) %></td></tr>
    <tr><th>Trạng thái</th><td><span class="badge <%= order.getStatus() %>"><%= h(order.getStatusLabel()) %></span></td></tr>
  </table>
  <div class="actions" style="justify-content:center"><a class="btn" href="<%= ctx %>/view/customer/CustomerMainGUI5.jsp" autofocus>OK</a></div>
</div>
<%@ include file="/WEB-INF/footer.jspf" %>
