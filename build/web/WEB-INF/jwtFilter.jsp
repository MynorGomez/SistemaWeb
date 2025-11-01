<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // Evita ejecutar este bloque más de una vez por petición
    if (request.getAttribute("jwtFilterExecuted") == null) {
        request.setAttribute("jwtFilterExecuted", true);

        // ⚙️ Verificar sesión (usa la variable implícita 'session')
        if (session == null || session.getAttribute("jwt") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // 👤 Obtener usuario logueado
        Object usuarioObj = session.getAttribute("usuario");
        String usuarioLog = (usuarioObj != null) ? usuarioObj.toString() : "Invitado";
        request.setAttribute("usuarioLog", usuarioLog);

        // 🧾 Obtener nombre completo desde sesión
        Object nombreObj = session.getAttribute("nombre");
        String nombreLog = (nombreObj != null) ? nombreObj.toString() : "Invitado";
        request.setAttribute("nombreLog", nombreLog);
    }
%>
