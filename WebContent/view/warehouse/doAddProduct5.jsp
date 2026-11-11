<%
    String addUrl = ctx + "/view/warehouse/AddProductGUI5.jsp";
    if (!"POST".equals(request.getMethod())) { response.sendRedirect(addUrl); return; }

    String name = Util5.trim(request.getParameter("name"));
    double importPrice = Util5.parseMoney(request.getParameter("importPrice"), -1);
    double salePrice = Util5.parseMoney(request.getParameter("salePrice"), -1);
    int stock = Util5.parseInt(request.getParameter("quantityInStock"), -1);
    int categoryId = Util5.parseInt(request.getParameter("categoryId"), -1);
    if (name.isEmpty() || importPrice < 0 || salePrice < 0 || stock < 0 || categoryId < 0) {
        Util5.flashErr(session, "Dữ liệu không hợp lệ: kiểm tra tên, giá nhập, giá bán, số lượng tồn và loại hàng.");
        response.sendRedirect(addUrl);
        return;
    }
    Product5 p = new Product5();
    p.setName(name);
    p.setBrand(Util5.trim(request.getParameter("brand")));
    p.setUnit(Util5.trim(request.getParameter("unit")));
    p.setImportPrice(importPrice);
    p.setSalePrice(salePrice);
    p.setQuantityInStock(stock);
    p.setDescription(Util5.trim(request.getParameter("description")));
    p.setImage(Util5.trim(request.getParameter("image")));
    try (ProductDAO5 dao = new ProductDAO5()) {
        dao.addProduct(p, categoryId);
    }
    Util5.flashOk(session, "Thêm mặt hàng thành công. Mã mặt hàng: " + p.getCode());
    response.sendRedirect(ctx + "/view/warehouse/ProductManagementGUI5.jsp");
%>