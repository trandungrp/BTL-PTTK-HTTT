<%
    // Hinh 6: doAddToCart5.jsp { cartItem : CartItem5, cart : Cart5 }
    String title = "Thông báo";
    String inProductName = Util5.nvl(request.getParameter("inProductName"));
    String orderUrl = ctx + "/view/customer/OrderGUI5.jsp?inProductName=" + Util5.urlEnc(inProductName);
    if (!"POST".equals(request.getMethod())) { response.sendRedirect(orderUrl); return; }

    // Mat hang do AddToCartGUI5.jsp giu trong session; gio hang do OrderGUI5.jsp giu trong session
    Product5 product = (Product5) session.getAttribute("product");
    Cart5 cart = (Cart5) session.getAttribute("cart");
    int id = Util5.parseInt(request.getParameter("id"), -1);
    if (cart == null) {   // vd khach bam Back cua trinh duyet sau khi da dat don
        try (CartDAO5 cartDAO = new CartDAO5()) {
            cart = cartDAO.getCartOfCustomer(((Customer5) session.getAttribute("customer")).getId());
        }
        session.setAttribute("cart", cart);
    }
    if (product == null || product.getId() != id) {
        Util5.flashErr(session, "Phiên đặt hàng đã hết hạn, vui lòng chọn lại mặt hàng.");
        response.sendRedirect(orderUrl);
        return;
    }
    String addUrl = ctx + "/view/customer/AddToCartGUI5.jsp?id=" + id + "&inProductName=" + Util5.urlEnc(inProductName);
    int inQuantity = Util5.parseInt(request.getParameter("inQuantity"), 0);
    int inCart = 0;
    for (CartItem5 item : cart.getListItem()) if (item.getProduct().getId() == id) inCart += item.getQuantity();
    if (inQuantity < 1 || inQuantity + inCart > product.getQuantityInStock()) {
        Util5.flashErr(session, "Số lượng không hợp lệ hoặc vượt quá số lượng tồn.");
        response.sendRedirect(addUrl);
        return;
    }

    // Lop CartItem5 dong goi dong gio hang (mat hang, so luong)
    CartItem5 cartItem = new CartItem5();
    cartItem.setProduct(product);
    cartItem.setQuantity(inQuantity);
    boolean ok;
    try (CartDAO5 cartDAO = new CartDAO5()) {
        ok = cartDAO.addItem(cart.getId(), cartItem);   // cong don so luong neu mat hang da co trong gio
    }
    session.removeAttribute("product");
    if (ok) cart.getListItem().add(cartItem);
    if (!ok) {
        Util5.flashErr(session, "Không thêm được vào giỏ hàng: mặt hàng không còn tồn tại.");
        response.sendRedirect(orderUrl);
        return;
    }
%><%@ include file="/WEB-INF/header.jspf" %>
<div class="card notice">
  <h2>Thông báo</h2>
  <p>Đã thêm vào giỏ hàng!</p>
  <a class="btn" href="<%= orderUrl %>" autofocus>OK</a>
</div>
<%@ include file="/WEB-INF/footer.jspf" %>
