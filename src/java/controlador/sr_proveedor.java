package controlador;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import modelo.Proveedor;

@WebServlet(name = "sr_proveedor", urlPatterns = {"/sr_proveedor"})
public class sr_proveedor extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String btn = request.getParameter("btn");
        Proveedor p = new Proveedor();

        try {
            switch (btn) {
                case "Agregar":
                    p.setProveedor(request.getParameter("txt_proveedor"));
                    p.setNit(request.getParameter("txt_nit"));
                    p.setDireccion(request.getParameter("txt_direccion"));
                    p.setTelefono(request.getParameter("txt_telefono"));
                    p.agregar();
                    break;

                case "Actualizar":
                    p.setId_proveedor(Integer.parseInt(request.getParameter("id_proveedor")));
                    p.setProveedor(request.getParameter("txt_proveedor"));
                    p.setNit(request.getParameter("txt_nit"));
                    p.setDireccion(request.getParameter("txt_direccion"));
                    p.setTelefono(request.getParameter("txt_telefono"));
                    p.actualizar();
                    break;

                case "Eliminar":
                    p.setId_proveedor(Integer.parseInt(request.getParameter("id_proveedor")));
                    p.eliminar();
                    break;
            }
        } catch (Exception e) {
            System.out.println("❌ Error en sr_proveedor: " + e.getMessage());
        }

        response.sendRedirect("views/proveedores.jsp");
    }
}
