package controlador;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.sql.*;
import utils.ConexionDB; // ✅ Usa tu clase de conexión existente

@WebServlet(name = "sr_login", urlPatterns = {"/sr_login"})
public class sr_login extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String token = request.getParameter("token");
        String usuario = request.getParameter("usuario");

        // 🔍 Consultar nombre real desde la base de datos
        String nombreCompleto = null;

        try (Connection con = new ConexionDB().getConexion();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT nombre FROM usuarios WHERE usuario = ?")) {

            ps.setString(1, usuario);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                nombreCompleto = rs.getString("nombre");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        // ✅ Crear o recuperar la sesión
        HttpSession sesion = request.getSession();
        sesion.setMaxInactiveInterval(30 * 60); // expira en 30 min

        // 🧩 Guardar datos del usuario
        sesion.setAttribute("jwt", token);
        sesion.setAttribute("usuario", usuario);
        sesion.setAttribute("nombre", nombreCompleto != null ? nombreCompleto : usuario);

        // 🔁 Responder OK al cliente
        response.setStatus(HttpServletResponse.SC_OK);
    }
}
