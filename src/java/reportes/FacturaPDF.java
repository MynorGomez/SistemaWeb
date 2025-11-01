package reportes;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import com.itextpdf.text.pdf.draw.LineSeparator;
import jakarta.servlet.http.HttpServletRequest; // 👈 Import necesario
import java.io.OutputStream;
import java.sql.*;
import java.text.SimpleDateFormat;
import utils.ConexionDB;

public class FacturaPDF {

    // ✅ Ahora recibe también el objeto HttpServletRequest
    public static void generarFactura(OutputStream out, int idVenta, HttpServletRequest request) throws Exception {
        Document doc = new Document(PageSize.A4, 50, 50, 50, 50);
        PdfWriter.getInstance(doc, out);
        doc.open();

        // 🎨 Fuentes y colores
        Font fontTitulo = new Font(Font.FontFamily.HELVETICA, 18, Font.BOLD);
        Font fontSubtitulo = new Font(Font.FontFamily.HELVETICA, 13, Font.BOLD);
        Font fontNormal = new Font(Font.FontFamily.HELVETICA, 11);
        Font fontBold = new Font(Font.FontFamily.HELVETICA, 11, Font.BOLD);
        BaseColor azulOscuro = new BaseColor(30, 60, 90);

        // 🔹 Encabezado con logo y datos de empresa
        PdfPTable encabezado = new PdfPTable(2);
        encabezado.setWidthPercentage(100);
        encabezado.setWidths(new float[]{1.5f, 3f});

        try {
            // ✅ Cargar logo desde la carpeta del proyecto (ruta real en Tomcat)
            String rutaLogo = request.getServletContext().getRealPath("/reportes/logo_kadam.png");
            if (rutaLogo != null) {
                Image logo = Image.getInstance(rutaLogo);
                logo.scaleToFit(100, 100);
                PdfPCell cellLogo = new PdfPCell(logo);
                cellLogo.setBorder(Rectangle.NO_BORDER);
                cellLogo.setRowspan(2);
                cellLogo.setHorizontalAlignment(Element.ALIGN_LEFT);
                encabezado.addCell(cellLogo);
            } else {
                throw new Exception("No se encontró el logo.");
            }

        } catch (Exception e) {
            System.out.println("⚠️ No se pudo cargar el logo: " + e.getMessage());
            PdfPCell cellEmpty = new PdfPCell(new Phrase("KADAM S.A.", fontTitulo));
            cellEmpty.setBorder(Rectangle.NO_BORDER);
            cellEmpty.setVerticalAlignment(Element.ALIGN_MIDDLE);
            encabezado.addCell(cellEmpty);
        }

        PdfPCell datosEmpresa = new PdfPCell(new Phrase(
            "KADAM S.A.\nDirección: Guatemala\nTeléfono: +502 1234-5678\nCorreo: info@kadam.com\n\n",
            fontNormal
        ));
        datosEmpresa.setHorizontalAlignment(Element.ALIGN_RIGHT);
        datosEmpresa.setBorder(Rectangle.NO_BORDER);
        encabezado.addCell(datosEmpresa);
        doc.add(encabezado);

        // 🔹 Línea divisoria azul
        LineSeparator separator = new LineSeparator();
        separator.setLineColor(azulOscuro);
        doc.add(separator);
        doc.add(Chunk.NEWLINE);

        // 🔹 Consultar venta y cliente
        Connection con = new ConexionDB().getConexion();
        String sqlVenta =
            "SELECT v.no_factura, v.serie, v.fecha_venta, " +
            "CONCAT(c.nombres, ' ', c.apellidos) AS nombre_cliente " +
            "FROM ventas v " +
            "INNER JOIN clientes c ON v.id_cliente = c.id_cliente " +
            "WHERE v.id_venta = ?";
        PreparedStatement psVenta = con.prepareStatement(sqlVenta);
        psVenta.setInt(1, idVenta);
        ResultSet rsVenta = psVenta.executeQuery();

        String noFactura = "-", serie = "-", cliente = "-";
        String fechaVenta = new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date());

        if (rsVenta.next()) {
            noFactura = rsVenta.getString("no_factura");
            serie = rsVenta.getString("serie");
            cliente = rsVenta.getString("nombre_cliente");
            fechaVenta = new SimpleDateFormat("dd/MM/yyyy")
                    .format(rsVenta.getTimestamp("fecha_venta"));
        }

        // 🔹 Información de la factura
        Paragraph info = new Paragraph("Factura No: " + noFactura + "   Serie: " + serie, fontBold);
        info.setSpacingAfter(5);
        doc.add(info);

        Paragraph fecha = new Paragraph("Fecha de venta: " + fechaVenta, fontNormal);
        doc.add(fecha);

        Paragraph datosCliente = new Paragraph("Cliente: " + cliente + "\n\n", fontNormal);
        doc.add(datosCliente);

        // 🔹 Título del detalle
        Paragraph tituloDetalle = new Paragraph("Detalle de Productos", fontSubtitulo);
        tituloDetalle.setSpacingBefore(10);
        tituloDetalle.setSpacingAfter(5);
        doc.add(tituloDetalle);

        // 🔹 Tabla de productos
        PdfPTable tabla = new PdfPTable(4);
        tabla.setWidthPercentage(100);
        tabla.setWidths(new float[]{4, 2, 2, 2});
        tabla.addCell(celda("Producto", true, azulOscuro));
        tabla.addCell(celda("Precio", true, azulOscuro));
        tabla.addCell(celda("Cantidad", true, azulOscuro));
        tabla.addCell(celda("Subtotal", true, azulOscuro));

        String sqlDetalle =
            "SELECT p.producto, vd.precio_unitario, vd.cantidad, " +
            "(vd.precio_unitario * vd.cantidad) AS subtotal " +
            "FROM ventas_detalle vd " +
            "INNER JOIN productos p ON vd.id_producto = p.id_producto " +
            "WHERE vd.id_venta = ?";
        PreparedStatement psDetalle = con.prepareStatement(sqlDetalle);
        psDetalle.setInt(1, idVenta);
        ResultSet rsDetalle = psDetalle.executeQuery();

        double total = 0;
        while (rsDetalle.next()) {
            tabla.addCell(celda(rsDetalle.getString("producto"), false, BaseColor.WHITE));
            tabla.addCell(celda(String.format("Q %.2f", rsDetalle.getDouble("precio_unitario")), false, BaseColor.WHITE));
            tabla.addCell(celda(String.valueOf(rsDetalle.getInt("cantidad")), false, BaseColor.WHITE));
            tabla.addCell(celda(String.format("Q %.2f", rsDetalle.getDouble("subtotal")), false, BaseColor.WHITE));
            total += rsDetalle.getDouble("subtotal");
        }

        doc.add(tabla);

        // 🔹 Totales
        double iva = total * 0.12;
        double totalGeneral = total + iva;
        Paragraph totales = new Paragraph(
            String.format("\nSubtotal: Q %.2f\nIVA (12%%): Q %.2f\nTotal General: Q %.2f",
                total, iva, totalGeneral),
            fontBold
        );
        totales.setAlignment(Element.ALIGN_RIGHT);
        totales.setSpacingBefore(10);
        doc.add(totales);

        // ❤️ Mensaje final
        Paragraph mensaje = new Paragraph(
            "\nGracias por su compra.\n¡Esperamos verle pronto!",
            new Font(Font.FontFamily.HELVETICA, 12, Font.ITALIC, azulOscuro)
        );
        mensaje.setAlignment(Element.ALIGN_CENTER);
        mensaje.setSpacingBefore(20);
        doc.add(mensaje);

        doc.close();
        con.close();
    }

    // 🔹 Celdas personalizadas
    private static PdfPCell celda(String texto, boolean encabezado, BaseColor colorFondo) {
        Font font = encabezado
            ? new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD, BaseColor.WHITE)
            : new Font(Font.FontFamily.HELVETICA, 11);
        PdfPCell cell = new PdfPCell(new Phrase(texto, font));
        if (encabezado) {
            cell.setBackgroundColor(colorFondo);
            cell.setHorizontalAlignment(Element.ALIGN_CENTER);
        } else {
            cell.setBackgroundColor(BaseColor.WHITE);
        }
        cell.setPadding(5);
        return cell;
    }
}
