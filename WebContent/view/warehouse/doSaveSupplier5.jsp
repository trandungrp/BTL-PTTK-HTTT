<%
    String listUrl = ctx + "/view/warehouse/SupplierManagementGUI5.jsp";
    if (!"POST".equals(request.getMethod())) { response.sendRedirect(listUrl); return; }

    int sid = Util5.parseInt(request.getParameter("id"), 0);
    String name = Util5.trim(request.getParameter("name"));
    String back = ctx + "/view/warehouse/EditSupplierGUI5.jsp" + (sid > 0 ? "?id=" + sid : "");
    if (name.isEmpty()) {
        Util5.flashErr(session, "Tên nhà cung cấp không được để trống.");
        response.sendRedirect(back);
        return;
    }
    Supplier5 s = new Supplier5();
    s.setId(sid);
    s.setName(name);
    s.setAddress(Util5.trim(request.getParameter("address")));
    s.setPhone(Util5.trim(request.getParameter("phone")));
    s.setEmail(Util5.trim(request.getParameter("email")));
    s.setContactPerson(Util5.trim(request.getParameter("contactPerson")));
    try (SupplierDAO5 dao = new SupplierDAO5()) {
        if (sid > 0) {
            if (dao.updateSupplier(s)) Util5.flashOk(session, "Cập nhật nhà cung cấp thành công.");
            else Util5.flashErr(session, "Nhà cung cấp không tồn tại.");
        } else {
            dao.addSupplier(s);
            Util5.flashOk(session, "Thêm nhà cung cấp thành công. Mã: " + s.getCode());
        }
    }
    response.sendRedirect(listUrl);
%>