package controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import modelo.ProductoReporteDAO;
import modelo.ProductoReporte;

@WebServlet("/ReporteProductosServlet")
public class ReporteProductosServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String tipo = request.getParameter("tipo"); // "venta" o "compra"

        List<ProductoReporte> productos;
        String titulo;

        if ("compra".equalsIgnoreCase(tipo)) {
            productos = ProductoReporteDAO.obtenerProductosMasComprados();
            titulo = "Productos Más Comprados";
        } else {
            productos = ProductoReporteDAO.obtenerProductosMasVendidos();
            titulo = "Productos Más Vendidos";
        }

        request.setAttribute("productos", productos);
        request.setAttribute("titulo", titulo);

        request.getRequestDispatcher("reporteProductos.jsp").forward(request, response);
    }
}
