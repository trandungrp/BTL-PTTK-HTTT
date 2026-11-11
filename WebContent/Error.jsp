<%@ page isErrorPage="true" %><%
    response.setStatus(500);
    String title = "Có lỗi xảy ra";
    String detail = exception == null ? "" : String.valueOf(exception.getMessage());
    if (exception != null) application.log("QLST5 error", exception);
%><%@ include file="/WEB-INF/header.jspf" %>
<div class="card">
  <h1>Có lỗi xảy ra</h1>
  <p class="sub">Hệ thống không thực hiện được yêu cầu. Vui lòng thử lại hoặc liên hệ quản trị viên.</p>
  <div class="alert err"><%= h(detail) %></div>
  <div class="actions"><a class="btn" href="<%= ctx %>/index.jsp">Về trang chủ</a></div>
</div>
<%@ include file="/WEB-INF/footer.jspf" %>
