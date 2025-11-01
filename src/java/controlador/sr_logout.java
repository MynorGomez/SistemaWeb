package controlador;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet(name = "sr_logout", urlPatterns = {"/sr_logout"})
public class sr_logout extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ✅ Invalidar toda la sesión (borra el JWT y cualquier otro dato)
        HttpSession sesion = request.getSession(false);
        if (sesion != null) {
            sesion.invalidate();
        }

        // ✅ Redirigir al login
        response.sendRedirect("login.jsp");
    }
}
