package controlador;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.time.LocalDateTime;
import modelo.Compra;
import utils.ConexionDB;

@WebServlet(name = "sr_compra", urlPatterns = {"/sr_compra"})
public class sr_compra extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String accion = request.getParameter("accion");

        try {
            if (accion != null) {
                // ✅ Sintaxis clásica compatible con Java 11
                switch (accion) {
                    case "eliminar":
                        eliminarCompra(request);
                        break;
                    case "actualizar":
                        actualizarCompra(request);
                        break;
                    default:
                        agregarCompra(request);
                        break;
                }
                response.sendRedirect("views/compras.jsp");
                return;
            }

            // Por defecto: agregar
            agregarCompra(request);
            response.sendRedirect("views/compras.jsp");

        } catch (Exception e) {
            System.out.println("❌ Error general en sr_compra: " + e.getMessage());
            throw new ServletException(e);
        }
    }

    // ============================================================
    // 🟢 AGREGAR NUEVA COMPRA
    // ============================================================
    private void agregarCompra(HttpServletRequest request) {
        try (Connection con = new ConexionDB().getConexion()) {
            con.setAutoCommit(false);

            String noOrdenStr = request.getParameter("no_orden");
            String idProvStr = request.getParameter("id_proveedor");
            String fechaGridemStr = request.getParameter("fecha_gridem");
            String fechaIngresoStr = request.getParameter("fecha_ingreso");

            if (noOrdenStr == null || noOrdenStr.isEmpty()
                    || idProvStr == null || idProvStr.isEmpty()
                    || fechaGridemStr == null || fechaGridemStr.isEmpty()) {
                System.out.println("⚠️ Campos obligatorios vacíos al agregar compra.");
                return;
            }

            String queryCompra = "INSERT INTO compras (negorden_compra, id_proveedor, fecha_gridem, fecha_ingreso) VALUES (?, ?, ?, ?)";
            try (PreparedStatement ps = con.prepareStatement(queryCompra, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, Integer.parseInt(noOrdenStr));
                ps.setInt(2, Integer.parseInt(idProvStr));
                ps.setDate(3, Date.valueOf(fechaGridemStr));

                // Si no se envía fecha de ingreso, usar la fecha actual
                if (fechaIngresoStr != null && !fechaIngresoStr.isEmpty()) {
                    ps.setDate(4, Date.valueOf(fechaIngresoStr));
                } else {
                    ps.setTimestamp(4, Timestamp.valueOf(LocalDateTime.now()));
                }

                ps.executeUpdate();

                ResultSet rs = ps.getGeneratedKeys();
                int idCompra = 0;
                if (rs.next()) idCompra = rs.getInt(1);

                insertarDetalles(con, idCompra, request);
            }

            con.commit();
            System.out.println("✅ Compra registrada con éxito.");
        } catch (Exception e) {
            System.out.println("❌ Error al agregar compra: " + e.getMessage());
        }
    }

    // ============================================================
    // 🟡 ACTUALIZAR COMPRA EXISTENTE
    // ============================================================
    private void actualizarCompra(HttpServletRequest request) {
        String idStr = request.getParameter("id_compra");
        if (idStr == null || idStr.isEmpty()) {
            System.out.println("⚠️ ID de compra vacío al actualizar.");
            return;
        }

        int idCompra = Integer.parseInt(idStr);
        try (Connection con = new ConexionDB().getConexion()) {
            con.setAutoCommit(false);

            // 1️⃣ Revertir existencias anteriores
            String queryOld = "SELECT id_producto, cantidad FROM compras_detalle WHERE id_compra=?";
            try (PreparedStatement psOld = con.prepareStatement(queryOld)) {
                psOld.setInt(1, idCompra);
                ResultSet rs = psOld.executeQuery();
                while (rs.next()) {
                    int idProd = rs.getInt("id_producto");
                    int cant = rs.getInt("cantidad");
                    try (PreparedStatement psUpd = con.prepareStatement(
                            "UPDATE productos SET existencia = GREATEST(existencia - ?, 0) WHERE id_producto=?")) {
                        psUpd.setInt(1, cant);
                        psUpd.setInt(2, idProd);
                        psUpd.executeUpdate();
                    }
                }
            }

            // 2️⃣ Eliminar detalles antiguos
            try (PreparedStatement psDel = con.prepareStatement("DELETE FROM compras_detalle WHERE id_compra=?")) {
                psDel.setInt(1, idCompra);
                psDel.executeUpdate();
            }

            // 3️⃣ Actualizar maestro
            String queryUp = "UPDATE compras SET id_proveedor=?, fecha_gridem=?, fecha_ingreso=? WHERE id_compra=?";
            try (PreparedStatement psUp = con.prepareStatement(queryUp)) {
                String idProvStr = request.getParameter("id_proveedor");
                String fechaGridemStr = request.getParameter("fecha_gridem");
                String fechaIngresoStr = request.getParameter("fecha_ingreso");

                psUp.setInt(1, (idProvStr != null && !idProvStr.isEmpty()) ? Integer.parseInt(idProvStr) : 0);
                psUp.setDate(2, (fechaGridemStr != null && !fechaGridemStr.isEmpty())
                        ? Date.valueOf(fechaGridemStr)
                        : new Date(System.currentTimeMillis()));
                psUp.setDate(3, (fechaIngresoStr != null && !fechaIngresoStr.isEmpty())
                        ? Date.valueOf(fechaIngresoStr)
                        : new Date(System.currentTimeMillis()));
                psUp.setInt(4, idCompra);
                psUp.executeUpdate();
            }

            // 4️⃣ Insertar nuevos detalles
            insertarDetalles(con, idCompra, request);

            con.commit();
            System.out.println("✅ Compra actualizada correctamente.");
        } catch (Exception e) {
            System.out.println("❌ Error al actualizar compra: " + e.getMessage());
        }
    }

    // ============================================================
    // 🔴 ELIMINAR COMPRA
    // ============================================================
    private void eliminarCompra(HttpServletRequest request) {
        String idStr = request.getParameter("id_compra");
        if (idStr == null || idStr.isEmpty()) {
            System.out.println("⚠️ ID de compra vacío al eliminar.");
            return;
        }

        int idCompra = Integer.parseInt(idStr);
        try (Connection con = new ConexionDB().getConexion()) {
            con.setAutoCommit(false);

            // Devolver existencias al eliminar
            String queryDet = "SELECT id_producto, cantidad FROM compras_detalle WHERE id_compra=?";
            try (PreparedStatement psDet = con.prepareStatement(queryDet)) {
                psDet.setInt(1, idCompra);
                ResultSet rs = psDet.executeQuery();
                while (rs.next()) {
                    int idProd = rs.getInt("id_producto");
                    int cant = rs.getInt("cantidad");
                    try (PreparedStatement psUpd = con.prepareStatement(
                            "UPDATE productos SET existencia = GREATEST(existencia - ?, 0) WHERE id_producto=?")) {
                        psUpd.setInt(1, cant);
                        psUpd.setInt(2, idProd);
                        psUpd.executeUpdate();
                    }
                }
            }

            // Eliminar detalles y cabecera
            try (PreparedStatement psDelDet = con.prepareStatement("DELETE FROM compras_detalle WHERE id_compra=?")) {
                psDelDet.setInt(1, idCompra);
                psDelDet.executeUpdate();
            }

            try (PreparedStatement psDelCompra = con.prepareStatement("DELETE FROM compras WHERE id_compra=?")) {
                psDelCompra.setInt(1, idCompra);
                psDelCompra.executeUpdate();
            }

            con.commit();
            System.out.println("🗑️ Compra eliminada correctamente.");
        } catch (Exception e) {
            System.out.println("❌ Error al eliminar compra: " + e.getMessage());
        }
    }

    // ============================================================
    // 🧩 FUNCION AUXILIAR — INSERTAR DETALLES
    // ============================================================
    private void insertarDetalles(Connection con, int idCompra, HttpServletRequest request) throws SQLException {
        String[] productos = request.getParameterValues("id_producto[]");
        String[] cantidades = request.getParameterValues("cantidad[]");
        String[] precios = request.getParameterValues("precio_unitario[]");

        if (productos == null || productos.length == 0) {
            System.out.println("⚠️ No se enviaron detalles de compra.");
            return;
        }

        int registros = 0;
        for (int i = 0; i < productos.length; i++) {
            if (productos[i] == null || productos[i].equals("0") || productos[i].trim().isEmpty()) continue;

            int idProducto = Integer.parseInt(productos[i]);
            int cantidad = (cantidades != null && i < cantidades.length && !cantidades[i].isEmpty())
                    ? Integer.parseInt(cantidades[i]) : 0;
            double precio = (precios != null && i < precios.length && !precios[i].isEmpty())
                    ? Double.parseDouble(precios[i]) : 0.0;

            if (idProducto <= 0 || cantidad <= 0 || precio <= 0) continue;

            try (PreparedStatement psDet = con.prepareStatement(
                    "INSERT INTO compras_detalle (id_compra, id_producto, cantidad, precio_unitario) VALUES (?, ?, ?, ?)")) {
                psDet.setInt(1, idCompra);
                psDet.setInt(2, idProducto);
                psDet.setInt(3, cantidad);
                psDet.setDouble(4, precio);
                psDet.executeUpdate();
                registros++;
            }

            try (PreparedStatement psProd = con.prepareStatement(
                    "UPDATE productos SET existencia = existencia + ?, precio_costo = ?, precio_venta = (? * 1.25), fecha_ingreso = NOW() WHERE id_producto = ?")) {
                psProd.setInt(1, cantidad);
                psProd.setDouble(2, precio);
                psProd.setDouble(3, precio);
                psProd.setInt(4, idProducto);
                psProd.executeUpdate();
            }
        }

        if (registros > 0) {
            System.out.println("✅ Se insertaron " + registros + " productos.");
        } else {
            System.out.println("⚠️ No se insertaron productos válidos.");
        }
    }
}
