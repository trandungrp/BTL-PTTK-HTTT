<%
    String listUrl = ctx + "/view/warehouse/SupplierManagementGUI5.jsp";
    if (!"POST".equals(request.getMethod())) { response.sendRedirect(listUrl); return; }
    boolean ok;
    try (SupplierDAO5 dao = new SupplierDAO5()) {
        ok = dao.deleteSupplier(Util5.parseInt(request.getParameter("id"), -1));
    }
    if (ok) Util5.flashOk(session, "Xóa nhà cung cấp thành công.");
    else Util5.flashErr(session, "Không xóa được: nhà cung cấp đã có phiếu nhập hàng hoặc không tồn tại.");
    response.sendRedirect(listUrl);
%>