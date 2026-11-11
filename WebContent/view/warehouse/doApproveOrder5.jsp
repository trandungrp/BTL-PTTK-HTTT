<%
    String listUrl = ctx + "/view/warehouse/ApproveOrderGUI5.jsp";
    if (!"POST".equals(request.getMethod())) { response.sendRedirect(listUrl); return; }

    String action = Util5.nvl(request.getParameter("action"));
    int orderId = Util5.parseInt(request.getParameter("id"), -1);
    String dest = listUrl;

    try (OrderDAO5 odao = new OrderDAO5()) {
        if ("approve".equals(action)) {
            int shipperId = Util5.parseInt(request.getParameter("shipperId"), -1);
            if (shipperId < 0) {
                Util5.flashErr(session, "Vui lòng chọn nhân viên giao hàng.");
                dest = listUrl + "?id=" + orderId;
            } else {
                String err = odao.approveOrder(orderId, me.getId(), shipperId);
                if (err == null) {
                    Util5.flashOk(session, "Duyệt đơn thành công: đã trừ tồn kho và xuất đơn cho nhân viên giao hàng.");
                    dest = ctx + "/view/warehouse/DeliveryNoteGUI5.jsp?id=" + orderId;
                } else {
                    Util5.flashErr(session, err);
                    dest = listUrl + "?id=" + orderId;
                }
            }
        } else if ("reject".equals(action)) {
            if (odao.rejectOrder(orderId, me.getId())) Util5.flashOk(session, "Đã từ chối đơn hàng.");
            else Util5.flashErr(session, "Không từ chối được: đơn không còn ở trạng thái chờ duyệt.");
        } else if ("complete".equals(action)) {
            if (odao.completeOrder(orderId)) Util5.flashOk(session, "Đã ghi nhận đơn giao hoàn thành.");
            else Util5.flashErr(session, "Không cập nhật được: đơn không ở trạng thái đã duyệt.");
        }
    }
    response.sendRedirect(dest);
%>