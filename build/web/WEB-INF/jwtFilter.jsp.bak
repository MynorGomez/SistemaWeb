<%
    HttpSession sesion = request.getSession(false);
    if (sesion == null || sesion.getAttribute("jwt") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
