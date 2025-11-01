package controlador;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import modelo.VentaDAO;

@WebServlet("/ReporteServlet")
public class ReporteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fechaInicio = request.getParameter("fechaInicio");
        String fechaFin = request.getParameter("fechaFin");

        List<Map<String, Object>> ventas = VentaDAO.obtenerVentasConTotales(fechaInicio, fechaFin);

        String alerta = (ventas == null || ventas.isEmpty())
                ? "⚠️ No se encontraron ventas en el rango indicado."
                : "📊 Reporte generado correctamente.";

        request.setAttribute("ventas", ventas);
        request.setAttribute("alerta", alerta);
        request.getRequestDispatcher("reporteResultados.jsp").forward(request, response);
    }
}
