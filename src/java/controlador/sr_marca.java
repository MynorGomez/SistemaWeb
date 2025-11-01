package controlador;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import modelo.Marca;

@WebServlet(name = "sr_marca", urlPatterns = {"/sr_marca"})
public class sr_marca extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Obtenemos la acción (Agregar, Actualizar o Eliminar)
        String accion = request.getParameter("accion");
        Marca marca = new Marca();

        try {
            switch (accion) {
                case "Agregar":
                    marca.setMarca(request.getParameter("txt_marca"));
                    marca.agregar();
                    break;

                case "Actualizar":
                    marca.setId_marca(Integer.parseInt(request.getParameter("id_marca")));
                    marca.setMarca(request.getParameter("txt_marca"));
                    marca.actualizar();
                    break;

                case "Eliminar":
                    marca.setId_marca(Integer.parseInt(request.getParameter("id_marca")));
                    marca.eliminar();
                    break;
            }

            // Respuesta vacía para AJAX (status 200 OK)
            response.setStatus(HttpServletResponse.SC_OK);

        } catch (Exception e) {
            System.err.println("❌ Error en sr_marca: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
