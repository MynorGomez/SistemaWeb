package controlador;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.OutputStream;
import java.util.List;
import modelo.ProductoReporte;
import modelo.ProductoReporteDAO;


@WebServlet("/ReporteProductosPDF")
public class ReporteProductosPDF extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String tipo = request.getParameter("tipo"); // venta o compra
        List<ProductoReporte> productos;

        if ("compra".equalsIgnoreCase(tipo)) {
            productos = ProductoReporteDAO.obtenerProductosMasComprados();
        } else {
            productos = ProductoReporteDAO.obtenerProductosMasVendidos();
        }

        // Configurar respuesta HTTP para PDF
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "inline; filename=reporte_productos.pdf");

        try {
            OutputStream out = response.getOutputStream();
            Document doc = new Document(PageSize.A4);
            PdfWriter.getInstance(doc, out);
            doc.open();

            // Encabezado
            Font tituloFont = new Font(Font.FontFamily.HELVETICA, 18, Font.BOLD);
            Font headerFont = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD);
            Font bodyFont = new Font(Font.FontFamily.HELVETICA, 11);

            Paragraph titulo = new Paragraph(
                "📦 Reporte de " + ("compra".equalsIgnoreCase(tipo) ? "Productos Más Comprados" : "Productos Más Vendidos"),
                tituloFont
            );
            titulo.setAlignment(Element.ALIGN_CENTER);
            titulo.setSpacingAfter(20);
            doc.add(titulo);

            // Tabla PDF
            PdfPTable tabla = new PdfPTable(3);
            tabla.setWidthPercentage(100);
            tabla.setWidths(new float[]{5, 2, 3});

            tabla.addCell(new PdfPCell(new Phrase("Producto", headerFont)));
            tabla.addCell(new PdfPCell(new Phrase("Cantidad", headerFont)));
            tabla.addCell(new PdfPCell(new Phrase("Total (Q)", headerFont)));

            for (ProductoReporte p : productos) {
                tabla.addCell(new PdfPCell(new Phrase(p.getNombre(), bodyFont)));
                tabla.addCell(new PdfPCell(new Phrase(String.valueOf(p.getCantidad()), bodyFont)));
                tabla.addCell(new PdfPCell(new Phrase(String.format("%.2f", p.getTotal()), bodyFont)));
            }

            doc.add(tabla);
            doc.close();
            out.close();

        } catch (DocumentException e) {
            throw new IOException("Error al generar el PDF: " + e.getMessage());
        }
    }
}
