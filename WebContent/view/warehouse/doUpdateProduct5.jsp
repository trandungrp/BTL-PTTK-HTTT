<%@ page import="javax.servlet.http.Part,java.io.File,java.io.InputStream,java.nio.file.Files,java.nio.file.StandardCopyOption,java.text.Normalizer" %><%!
    /** Ten file anh an toan: bo dau tieng Viet, chi giu [a-z0-9._-]. */
    static String safeFileName(String submitted) {
        String n = submitted.replace('\\', '/');
        n = n.substring(n.lastIndexOf('/') + 1);
        n = Normalizer.normalize(n, Normalizer.Form.NFD).replaceAll("\\p{M}", "").replace('đ', 'd').replace('Đ', 'D');
        n = n.toLowerCase().replaceAll("[^a-z0-9._-]+", "-");
        return n.replaceAll("^[.-]+", "");
    }
%><%
    // Hinh 4: doUpdateProduct5.jsp { product : Product5 }
    String title = "Thông báo";
    String inProductName = Util5.nvl(request.getParameter("inProductName"));
    String listUrl = ctx + "/view/warehouse/SearchProductGUI5.jsp?mode=update&inProductName=" + Util5.urlEnc(inProductName);
    if (!"POST".equals(request.getMethod())) { response.sendRedirect(listUrl); return; }

    // Doi tuong product do UpdateProductGUI5.jsp lay tu getProductDetail() va giu trong session
    Product5 product = (Product5) session.getAttribute("product");
    int id = Util5.parseInt(request.getParameter("id"), -1);
    if (product == null || product.getId() != id) {
        Util5.flashErr(session, "Phiên sửa mặt hàng đã hết hạn, vui lòng chọn lại mặt hàng.");
        response.sendRedirect(listUrl);
        return;
    }
    String editUrl = ctx + "/view/warehouse/UpdateProductGUI5.jsp?id=" + id + "&inProductName=" + Util5.urlEnc(inProductName);

    String inoutName = Util5.trim(request.getParameter("inoutName"));
    double inoutImportPrice = Util5.parseMoney(request.getParameter("inoutImportPrice"), -1);
    double inoutSalePrice = Util5.parseMoney(request.getParameter("inoutSalePrice"), -1);
    int inoutQuantityInStock = Util5.parseInt(request.getParameter("inoutQuantityInStock"), -1);
    int inoutCategory = Util5.parseInt(request.getParameter("inoutCategory"), -1);
    if (inoutName.isEmpty() || inoutImportPrice < 0 || inoutSalePrice < 0 || inoutQuantityInStock < 0 || inoutCategory < 0) {
        Util5.flashErr(session, "Dữ liệu không hợp lệ: kiểm tra tên, giá nhập, giá bán, số lượng tồn và loại hàng.");
        response.sendRedirect(editUrl);
        return;
    }

    // inoutImage : file - neu chon anh moi thi luu vao /assets/images, nguoc lai giu anh cu
    String newImage = product.getImage();
    Part inoutImage = request.getPart("inoutImage");
    if (inoutImage != null && inoutImage.getSize() > 0) {
        String fileName = safeFileName(Util5.nvl(inoutImage.getSubmittedFileName()));
        if (!fileName.matches(".+\\.(jpg|jpeg|png|gif|webp)")) {
            Util5.flashErr(session, "Hình ảnh phải là file .jpg, .jpeg, .png, .gif hoặc .webp.");
            response.sendRedirect(editUrl);
            return;
        }
        String dir = application.getRealPath("/assets/images");
        if (dir == null) {
            Util5.flashErr(session, "Máy chủ không cho phép lưu file ảnh.");
            response.sendRedirect(editUrl);
            return;
        }
        File folder = new File(dir);
        folder.mkdirs();
        try (InputStream in = inoutImage.getInputStream()) {
            Files.copy(in, new File(folder, fileName).toPath(), StandardCopyOption.REPLACE_EXISTING);
        }
        newImage = fileName;
    }

    // Lop Product5 set lai cac thuoc tinh moi nhap
    product.setName(inoutName);
    product.setBrand(Util5.trim(request.getParameter("inoutBrand")));
    product.setUnit(Util5.trim(request.getParameter("inoutUnit")));
    product.setImportPrice(inoutImportPrice);
    product.setSalePrice(inoutSalePrice);
    product.setQuantityInStock(inoutQuantityInStock);
    product.setDescription(Util5.trim(request.getParameter("inoutDescription")));
    product.setImage(newImage);

    boolean ok;
    try (ProductDAO5 productDAO = new ProductDAO5()) {
        ok = productDAO.updateProduct(product, inoutCategory);
    }
    session.removeAttribute("product");
    if (!ok) {
        Util5.flashErr(session, "Không sửa được: mặt hàng hoặc loại hàng không tồn tại.");
        response.sendRedirect(editUrl);
        return;
    }
%><%@ include file="/WEB-INF/header.jspf" %>
<div class="card notice">
  <h2>Thông báo</h2>
  <p>Sửa thông tin mặt hàng thành công!</p>
  <a class="btn" href="<%= listUrl %>" autofocus>OK</a>
</div>
<%@ include file="/WEB-INF/footer.jspf" %>
