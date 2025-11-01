package controlador;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.OutputStream;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.Date;
import utils.ConexionDB;

@WebServlet("/ReporteVentasPDF")
public class ReporteVentasPDF extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fechaInicio = request.getParameter("fechaInicio");
        String fechaFin = request.getParameter("fechaFin");

        // Configurar PDF
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "inline; filename=reporte_ventas.pdf");

        try (OutputStream out = response.getOutputStream()) {
            Document doc = new Document(PageSize.A4.rotate()); // horizontal
            PdfWriter.getInstance(doc, out);
            doc.open();

            // 🧾 Encabezado
            Font tituloFont = new Font(Font.FontFamily.HELVETICA, 18, Font.BOLD);
            Font headerFont = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD);
            Font bodyFont = new Font(Font.FontFamily.HELVETICA, 10);

            Paragraph titulo = new Paragraph("📊 Reporte de Ventas", tituloFont);
            titulo.setAlignment(Element.ALIGN_CENTER);
            titulo.setSpacingAfter(10);
            doc.add(titulo);

            String fechaActual = new SimpleDateFormat("dd/MM/yyyy HH:mm").format(new Date());
            Paragraph fecha = new Paragraph("Generado el: " + fechaActual, new Font(Font.FontFamily.HELVETICA, 10));
            fecha.setAlignment(Element.ALIGN_RIGHT);
            fecha.setSpacingAfter(15);
            doc.add(fecha);

            // 📋 Tabla PDF
            PdfPTable tabla = new PdfPTable(6);
            tabla.setWidthPercentage(100);
            tabla.setWidths(new float[]{2, 2, 3, 4, 2, 2});

            tabla.addCell(new PdfPCell(new Phrase("ID Venta", headerFont)));
            tabla.addCell(new PdfPCell(new Phrase("No. Factura", headerFont)));
            tabla.addCell(new PdfPCell(new Phrase("Serie", headerFont)));
            tabla.addCell(new PdfPCell(new Phrase("Cliente", headerFont)));
            tabla.addCell(new PdfPCell(new Phrase("Fecha Venta", headerFont)));
            tabla.addCell(new PdfPCell(new Phrase("Total (Q)", headerFont)));

            // ✅ Consulta SQL directa
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT v.id_venta, v.no_factura, v.serie, c.nombres AS cliente, ")
               .append("v.fecha_venta, v.total ")
               .append("FROM ventas v INNER JOIN clientes c ON v.id_cliente = c.id_cliente WHERE 1=1 ");

            if (fechaInicio != null && !fechaInicio.isEmpty() && fechaFin != null && !fechaFin.isEmpty()) {
                sql.append("AND DATE(v.fecha_venta) BETWEEN ? AND ? ");
            }

            sql.append("ORDER BY v.fecha_venta DESC");

            try (Connection con = new ConexionDB().getConexion();
                 PreparedStatement ps = con.prepareStatement(sql.toString())) {

                int index = 1;
                if (fechaInicio != null && !fechaInicio.isEmpty() && fechaFin != null && !fechaFin.isEmpty()) {
                    ps.setString(index++, fechaInicio);
                    ps.setString(index++, fechaFin);
                }

                try (ResultSet rs = ps.executeQuery()) {
                    boolean hayDatos = false;
                    while (rs.next()) {
                        hayDatos = true;
                        tabla.addCell(new PdfPCell(new Phrase(String.valueOf(rs.getInt("id_venta")), bodyFont)));
                        tabla.addCell(new PdfPCell(new Phrase(String.valueOf(rs.getInt("no_factura")), bodyFont)));
                        tabla.addCell(new PdfPCell(new Phrase(rs.getString("serie"), bodyFont)));
                        tabla.addCell(new PdfPCell(new Phrase(rs.getString("cliente"), bodyFont)));
                        tabla.addCell(new PdfPCell(new Phrase(rs.getString("fecha_venta"), bodyFont)));
                        tabla.addCell(new PdfPCell(new Phrase(String.format("Q %.2f", rs.getDouble("total")), bodyFont)));
                    }

                    if (!hayDatos) {
                        Paragraph vacio = new Paragraph("\n⚠️ No hay datos disponibles para mostrar.", bodyFont);
                        vacio.setAlignment(Element.ALIGN_CENTER);
                        doc.add(vacio);
                    } else {
                        doc.add(tabla);
                    }
                }

            } catch (SQLException e) {
                Paragraph error = new Paragraph("❌ Error SQL: " + e.getMessage(), bodyFont);
                error.setAlignment(Element.ALIGN_CENTER);
                doc.add(error);
            }

            doc.close();

        } catch (DocumentException e) {
            throw new IOException("Error al generar el PDF: " + e.getMessage());
        }
    }
}
