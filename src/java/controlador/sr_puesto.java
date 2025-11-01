package controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import modelo.Puesto;

@WebServlet(name = "sr_puesto", urlPatterns = {"/sr_puesto"})
public class sr_puesto extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/plain;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        String accion = request.getParameter("accion");
        Puesto puesto = new Puesto();

        try {
            if (accion == null || accion.trim().isEmpty()) {
                System.out.println("⚠️ Acción nula o vacía en sr_puesto.");
                response.getWriter().write("error");
                return;
            }

            switch (accion) {
                case "Agregar":
                    puesto.setPuesto(request.getParameter("txt_puesto"));
                    puesto.agregar();
                    response.getWriter().write("ok");
                    break;

                case "Actualizar":
                    puesto.setId_puesto(Integer.parseInt(request.getParameter("id_puesto")));
                    puesto.setPuesto(request.getParameter("txt_puesto"));
                    puesto.actualizar();
                    response.getWriter().write("ok");
                    break;

                case "Eliminar":
                    puesto.setId_puesto(Integer.parseInt(request.getParameter("id_puesto")));
                    puesto.eliminar();
                    response.getWriter().write("ok");
                    break;

                default:
                    System.out.println("⚠️ Acción desconocida: " + accion);
                    response.getWriter().write("error");
                    break;
            }

        } catch (Exception e) {
            System.out.println("❌ Error en sr_puesto: " + e.getMessage());
            response.getWriter().write("error");
        }
    }
}
