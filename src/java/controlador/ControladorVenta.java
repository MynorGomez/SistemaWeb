package controlador;

import utils.ConexionDB;
import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/ControladorVenta")
public class ControladorVenta extends HttpServlet {

   @Override
protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

    String accion = request.getParameter("accion");
    if (accion == null) accion = "";

    switch (accion) {
        case "guardar":
            guardarVenta(request, response);
            break;
        case "editar":
            editarVenta(request, response);
            break;
        case "eliminar":
            eliminarVenta(request, response);
            break;
        default:
            response.sendRedirect("views/ventas.jsp");
    }
}

// 🔹 Nuevo método para editar venta
private void editarVenta(HttpServletRequest request, HttpServletResponse response)
        throws IOException, ServletException {

    Connection cn = null;

    try {
        cn = new ConexionDB().getConexion();
        cn.setAutoCommit(false);

        int idVenta = Integer.parseInt(request.getParameter("idVenta"));
        int idCliente = Integer.parseInt(request.getParameter("idCliente"));
        int idEmpleado = Integer.parseInt(request.getParameter("idEmpleado"));
        double total = Double.parseDouble(request.getParameter("totalVenta"));

        // 🔸 Primero, revertimos existencias de los productos anteriores
        PreparedStatement psOld = cn.prepareStatement(
            "SELECT id_producto, cantidad FROM ventas_detalle WHERE id_venta = ?");
        psOld.setInt(1, idVenta);
        ResultSet rsOld = psOld.executeQuery();
        while (rsOld.next()) {
            int idProd = rsOld.getInt("id_producto");
            int cant = rsOld.getInt("cantidad");
            PreparedStatement psUpd = cn.prepareStatement(
                "UPDATE productos SET existencia = existencia + ? WHERE id_producto = ?");
            psUpd.setInt(1, cant);
            psUpd.setInt(2, idProd);
            psUpd.executeUpdate();
        }

        // 🔸 Eliminamos detalle antiguo
        PreparedStatement psDel = cn.prepareStatement(
            "DELETE FROM ventas_detalle WHERE id_venta = ?");
        psDel.setInt(1, idVenta);
        psDel.executeUpdate();

        // 🔸 Actualizamos datos de la venta
        PreparedStatement psVenta = cn.prepareStatement(
            "UPDATE ventas SET id_cliente=?, id_empleado=?, total=? WHERE id_venta=?");
        psVenta.setInt(1, idCliente);
        psVenta.setInt(2, idEmpleado);
        psVenta.setDouble(3, total);
        psVenta.setInt(4, idVenta);
        psVenta.executeUpdate();

        // 🔸 Insertamos nuevos detalles
        String[] idProducto = request.getParameterValues("idProducto");
        String[] cantidad = request.getParameterValues("cantidad");
        String[] precio = request.getParameterValues("precio");
        String[] subtotal = request.getParameterValues("subtotal");

        PreparedStatement psDet = cn.prepareStatement(
            "INSERT INTO ventas_detalle (id_venta, id_producto, cantidad, precio_unitario, subtotal) VALUES (?,?,?,?,?)");

        for (int i = 0; i < idProducto.length; i++) {
            int idProd = Integer.parseInt(idProducto[i]);
            int cant = Integer.parseInt(cantidad[i]);
            double prec = Double.parseDouble(precio[i]);
            double sub = Double.parseDouble(subtotal[i]);

            // Insertar detalle
            psDet.setInt(1, idVenta);
            psDet.setInt(2, idProd);
            psDet.setInt(3, cant);
            psDet.setDouble(4, prec);
            psDet.setDouble(5, sub);
            psDet.executeUpdate();

            // Actualizar existencias
            PreparedStatement psStock = cn.prepareStatement(
                "UPDATE productos SET existencia = existencia - ? WHERE id_producto = ?");
            psStock.setInt(1, cant);
            psStock.setInt(2, idProd);
            psStock.executeUpdate();
        }

        cn.commit();
        response.sendRedirect("views/ventas.jsp?msg=editok");

    } catch (Exception e) {
        try { if (cn != null) cn.rollback(); } catch (SQLException ex) {}
        throw new ServletException("❌ Error al editar la venta: " + e.getMessage(), e);
    } finally {
        if (cn != null) try { cn.setAutoCommit(true); cn.close(); } catch (SQLException ex) {}
    }
}
private void guardarVenta(HttpServletRequest request, HttpServletResponse response)
        throws IOException, ServletException {

    Connection cn = null;

    try {
        cn = new ConexionDB().getConexion();
        cn.setAutoCommit(false);

        // 🔹 Validar valores antes de convertir
        String idClienteStr = request.getParameter("idCliente");
        String idEmpleadoStr = request.getParameter("idEmpleado");
        String totalStr = request.getParameter("totalVenta");

        if (idClienteStr == null || idClienteStr.trim().isEmpty() ||
            idEmpleadoStr == null || idEmpleadoStr.trim().isEmpty() ||
            totalStr == null || totalStr.trim().isEmpty()) {
            request.setAttribute("errorMsg", "⚠️ Complete todos los campos antes de guardar la venta.");
            request.getRequestDispatcher("views/ventas_form.jsp").forward(request, response);
            return;
        }

        int idCliente = Integer.parseInt(idClienteStr.trim());
        int idEmpleado = Integer.parseInt(idEmpleadoStr.trim());
        double total = Double.parseDouble(totalStr.trim());

        int noFactura = (int) (Math.random() * 100000);
        String serie = "A";
        Timestamp fechaVenta = new Timestamp(System.currentTimeMillis());

        // Validar existencias
        String[] idProducto = request.getParameterValues("idProducto");
        String[] cantidad = request.getParameterValues("cantidad");

        if (idProducto == null || cantidad == null) {
            request.setAttribute("errorMsg", "⚠️ Debe agregar al menos un producto a la venta.");
            request.getRequestDispatcher("views/ventas_form.jsp").forward(request, response);
            return;
        }

        for (int i = 0; i < idProducto.length; i++) {
            if (idProducto[i] == null || idProducto[i].trim().isEmpty() ||
                cantidad[i] == null || cantidad[i].trim().isEmpty()) {
                continue; // Saltar filas vacías
            }

            int idProd = Integer.parseInt(idProducto[i]);
            int cant = Integer.parseInt(cantidad[i]);

            PreparedStatement psCheck = cn.prepareStatement(
                    "SELECT existencia, producto FROM productos WHERE id_producto = ?");
            psCheck.setInt(1, idProd);
            ResultSet rs = psCheck.executeQuery();
            if (rs.next()) {
                int existencia = rs.getInt("existencia");
                String producto = rs.getString("producto");

                if (cant > existencia) {
                    request.setAttribute("errorMsg", "❌ No hay suficiente existencia para el producto: "
                            + producto + " (Disponible: " + existencia + ", solicitado: " + cant + ")");
                    request.getRequestDispatcher("views/ventas_form.jsp").forward(request, response);
                    return;
                }
            }
        }

        // Insertar venta
        String sqlVenta = "INSERT INTO ventas (no_factura, serie, fecha_venta, id_cliente, id_empleado, total) "
                        + "VALUES (?, ?, ?, ?, ?, ?)";
        PreparedStatement psVenta = cn.prepareStatement(sqlVenta, Statement.RETURN_GENERATED_KEYS);
        psVenta.setInt(1, noFactura);
        psVenta.setString(2, serie);
        psVenta.setTimestamp(3, fechaVenta);
        psVenta.setInt(4, idCliente);
        psVenta.setInt(5, idEmpleado);
        psVenta.setDouble(6, total);
        psVenta.executeUpdate();

        ResultSet rsVenta = psVenta.getGeneratedKeys();
        int idVenta = 0;
        if (rsVenta.next()) idVenta = rsVenta.getInt(1);

        // Insertar detalles
        String[] precio = request.getParameterValues("precio");
        String[] subtotal = request.getParameterValues("subtotal");

        if (precio == null || subtotal == null) {
            request.setAttribute("errorMsg", "⚠️ Los datos del detalle están incompletos.");
            request.getRequestDispatcher("views/ventas_form.jsp").forward(request, response);
            return;
        }

        String sqlDetalle = "INSERT INTO ventas_detalle (id_venta, id_producto, cantidad, precio_unitario, subtotal) "
                          + "VALUES (?, ?, ?, ?, ?)";
        PreparedStatement psDet = cn.prepareStatement(sqlDetalle);

        for (int i = 0; i < idProducto.length; i++) {
            if (idProducto[i] == null || idProducto[i].trim().isEmpty() ||
                cantidad[i] == null || cantidad[i].trim().isEmpty() ||
                precio[i] == null || precio[i].trim().isEmpty() ||
                subtotal[i] == null || subtotal[i].trim().isEmpty()) {
                continue; // Saltar filas vacías
            }

            int idProd = Integer.parseInt(idProducto[i]);
            int cant = Integer.parseInt(cantidad[i]);
            double prec = Double.parseDouble(precio[i]);
            double sub = Double.parseDouble(subtotal[i]);

            psDet.setInt(1, idVenta);
            psDet.setInt(2, idProd);
            psDet.setInt(3, cant);
            psDet.setDouble(4, prec);
            psDet.setDouble(5, sub);
            psDet.executeUpdate();

            PreparedStatement psStock = cn.prepareStatement(
                    "UPDATE productos SET existencia = existencia - ? WHERE id_producto = ?");
            psStock.setInt(1, cant);
            psStock.setInt(2, idProd);
            psStock.executeUpdate();
            psStock.close();
        }

        cn.commit();
        response.sendRedirect("views/ventas.jsp?msg=ok");

    } catch (Exception e) {
        try { if (cn != null) cn.rollback(); } catch (SQLException ex) {}
        throw new ServletException("❌ Error al guardar la venta: " + e.getMessage(), e);
    } finally {
        if (cn != null) try { cn.setAutoCommit(true); cn.close(); } catch (SQLException ex) {}
    }
}

    private void eliminarVenta(HttpServletRequest request, HttpServletResponse response)
        throws IOException, ServletException {

    int idVenta = Integer.parseInt(request.getParameter("idVenta"));
    Connection cn = null;

    try {
        cn = new ConexionDB().getConexion();
        cn.setAutoCommit(false);

        // 1️⃣ Recuperar los productos y cantidades del detalle
        PreparedStatement psDet = cn.prepareStatement(
            "SELECT id_producto, cantidad FROM ventas_detalle WHERE id_venta = ?");
        psDet.setInt(1, idVenta);
        ResultSet rs = psDet.executeQuery();

        // 2️⃣ Devolver existencias
        while (rs.next()) {
            int idProd = rs.getInt("id_producto");
            int cant = rs.getInt("cantidad");

            PreparedStatement psStock = cn.prepareStatement(
                "UPDATE productos SET existencia = existencia + ? WHERE id_producto = ?");
            psStock.setInt(1, cant);
            psStock.setInt(2, idProd);
            psStock.executeUpdate();
        }

        // 3️⃣ Eliminar detalles
        PreparedStatement psDelDet = cn.prepareStatement(
            "DELETE FROM ventas_detalle WHERE id_venta = ?");
        psDelDet.setInt(1, idVenta);
        psDelDet.executeUpdate();

        // 4️⃣ Eliminar la venta
        PreparedStatement psDelVenta = cn.prepareStatement(
            "DELETE FROM ventas WHERE id_venta = ?");
        psDelVenta.setInt(1, idVenta);
        psDelVenta.executeUpdate();

        cn.commit();
        response.sendRedirect("views/ventas.jsp?msg=deleted");

    } catch (Exception e) {
        try { if (cn != null) cn.rollback(); } catch (SQLException ex) {}
        throw new ServletException("❌ Error al eliminar la venta: " + e.getMessage(), e);
    } finally {
        if (cn != null) try { cn.setAutoCommit(true); cn.close(); } catch (SQLException ex) {}
    }
}
}