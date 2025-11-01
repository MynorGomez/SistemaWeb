package controlador;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import modelo.Empleado;

@WebServlet(name = "sr_empleado", urlPatterns = {"/sr_empleado"})
public class sr_empleado extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String btn = request.getParameter("btn");
        Empleado emp = new Empleado();

        try {
            // ===============================
            // Cargar datos comunes
            // ===============================
            emp.setCodigo(request.getParameter("txt_codigo"));
            emp.setNombres(request.getParameter("txt_nombres"));
            emp.setApellidos(request.getParameter("txt_apellidos"));
            emp.setDireccion(request.getParameter("txt_direccion"));
            emp.setTelefono(request.getParameter("txt_telefono"));
            emp.setFecha_nacimiento(request.getParameter("txt_fn"));
            emp.setId_puesto(Integer.parseInt(request.getParameter("drop_puesto")));

            // ===============================
            // Nuevos campos de la tabla empleados
            // ===============================
            emp.setGenero(Boolean.parseBoolean(request.getParameter("txt_genero")));

            String fechaInicio = request.getParameter("txt_fecha_inicio_labores");
            if (fechaInicio != null && !fechaInicio.isEmpty()) {
                emp.setFecha_inicio_labores(fechaInicio);
            }

            String fechaIngreso = request.getParameter("txt_fechaingreso");
            if (fechaIngreso != null && !fechaIngreso.isEmpty()) {
                emp.setFechaingreso(fechaIngreso);
            }

            // ===============================
            // CRUD
            // ===============================
            switch (btn) {
                case "Agregar":
                    emp.agregar(); // fechaingreso se autollenará con NOW() si no se manda
                    break;

                case "Actualizar":
                    emp.setId_empleado(Integer.parseInt(request.getParameter("id_empleado")));
                    emp.actualizar();
                    break;

                case "Eliminar":
                    emp.setId_empleado(Integer.parseInt(request.getParameter("id_empleado")));
                    emp.eliminar();
                    break;
            }

        } catch (Exception e) {
            System.out.println("❌ Error en sr_empleado: " + e.getMessage());
        }

        response.sendRedirect("views/empleados.jsp");
    }
}
