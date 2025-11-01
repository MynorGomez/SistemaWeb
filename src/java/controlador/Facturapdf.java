package controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import reportes.FacturaPDF;

@WebServlet("/FacturaPDF")
public class Facturapdf extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int idVenta = Integer.parseInt(request.getParameter("idVenta"));

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "inline; filename=factura_" + idVenta + ".pdf");

        try {
           FacturaPDF.generarFactura(response.getOutputStream(), idVenta, request);;
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error al generar factura PDF");
        }
    }
}
