<%
    String inProductName = Util5.nvl(request.getParameter("inProductName"));
    String listUrl = ctx + "/view/warehouse/SearchProductGUI5.jsp?mode=delete&inProductName=" + Util5.urlEnc(inProductName);
    if (!"POST".equals(request.getMethod())) { response.sendRedirect(listUrl); return; }
    boolean ok;
    try (ProductDAO5 productDAO = new ProductDAO5()) {
        ok = productDAO.deleteProduct(Util5.parseInt(request.getParameter("id"), -1));
    }
    if (ok) Util5.flashOk(session, "Xóa mặt hàng thành công.");
    else Util5.flashErr(session, "Không xóa được: mặt hàng đã phát sinh giao dịch (nhập, bán hoặc đặt hàng) hoặc không tồn tại.");
    response.sendRedirect(listUrl);
%>
