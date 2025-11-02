package controlador;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet(name = "sr_login", urlPatterns = {"/sr_login"})
public class sr_login extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String token = request.getParameter("token");
        String usuario = request.getParameter("usuario");

        if (token != null && !token.isEmpty()) {
            HttpSession sesion = request.getSession(true);
            sesion.setAttribute("jwt", token);
            sesion.setAttribute("usuario", usuario);
            sesion.setAttribute("nombre", usuario); // puedes ajustar si API devuelve nombre
            sesion.setMaxInactiveInterval(30 * 60);

            System.out.println("✅ Sesión iniciada para usuario: " + usuario);
            response.getWriter().write("ok");
        } else {
            System.out.println("❌ No se recibió token válido");
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        }
    }
}
