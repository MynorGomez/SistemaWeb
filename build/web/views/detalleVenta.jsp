<%@ include file="../WEB-INF/jwtFilter.jsp" %>
<%@ page import="java.sql.*, java.text.SimpleDateFormat, utils.ConexionDB" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Detalle de Venta</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

    <style>
        body { background-color: #f8fafc; font-family: 'Poppins', sans-serif; }
        .card {
            border-radius: 12px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.1);
        }
        .section-header {
            background: #007bff;
            color: white;
            padding: 10px 15px;
            border-radius: 10px 10px 0 0;
        }
        .table th {
            background-color: #c7efcf;
        }
        .table tfoot {
            background-color: #212529;
            color: #fff;
            font-weight: bold;
        }
    </style>
</head>

<body>
<div class="card border-0">
    <div class="card-body">
        <%
            String idVenta = request.getParameter("idVenta");
            if (idVenta == null || idVenta.trim().isEmpty()) {
        %>
            <div class="alert alert-danger">❌ No se recibió el ID de la venta.</div>
        <%
            } else {
                ConexionDB cn = new ConexionDB();
                Connection con = cn.getConexion();

                // 🔹 Configurar formato de fecha legible
                SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");

                // 🔹 CABECERA DE VENTA
                PreparedStatement ps = con.prepareStatement(
                    "SELECT v.no_factura, v.serie, v.fecha_venta, v.total, v.fechaingreso, " +
                    "c.nombres AS cliente_nombre, c.apellidos AS cliente_apellido, c.nit, " +
                    "e.nombres AS empleado_nombre, e.apellidos AS empleado_apellido " +
                    "FROM ventas v " +
                    "INNER JOIN clientes c ON v.id_cliente = c.id_cliente " +
                    "INNER JOIN empleados e ON v.id_empleado = e.id_empleado " +
                    "WHERE v.id_venta = ?"
                );
                ps.setInt(1, Integer.parseInt(idVenta));
                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    Timestamp fechaVenta = rs.getTimestamp("fecha_venta");
                    Timestamp fechaIngreso = rs.getTimestamp("fechaingreso");
        %>

        <!-- 🔹 DATOS GENERALES -->
        <div class="border rounded p-3 mb-4 bg-light">
            <h6 class="text-primary mb-3"><i class="bi bi-receipt"></i> Datos de la Venta</h6>
            <div class="row">
                <div class="col-md-3"><strong>No. Factura:</strong> <%= rs.getString("no_factura") %></div>
                <div class="col-md-3"><strong>Serie:</strong> <%= rs.getString("serie") %></div>
                <div class="col-md-3"><strong>Fecha Venta:</strong> 
                    <%= (fechaVenta != null) ? sdf.format(fechaVenta) : "N/A" %>
                </div>
                <div class="col-md-3"><strong>Total Venta:</strong> 
                    Q <%= String.format("%.2f", rs.getDouble("total")) %>
                </div>
            </div>
            <div class="row mt-3">
                <div class="col-md-4"><strong>Cliente:</strong> <%= rs.getString("cliente_nombre") %> <%= rs.getString("cliente_apellido") %></div>
                <div class="col-md-4"><strong>NIT:</strong> <%= rs.getString("nit") %></div>
                <div class="col-md-4"><strong>Empleado:</strong> <%= rs.getString("empleado_nombre") %> <%= rs.getString("empleado_apellido") %></div>
            </div>
            <div class="row mt-3">
                <div class="col-md-4"><strong>Fecha Ingreso:</strong> 
                    <%= (fechaIngreso != null) ? sdf.format(fechaIngreso) : "N/A" %>
                </div>
            </div>
        </div>

        <% } rs.close(); %>

        <!-- 🔹 DETALLE DE PRODUCTOS -->
        <h6 class="text-secondary mb-3"><i class="bi bi-box-seam"></i> Productos Vendidos</h6>
        <table class="table table-bordered table-striped align-middle">
            <thead class="text-center">
                <tr>
                    <th>Producto</th>
                    <th>Cantidad</th>
                    <th>Precio Unitario (Q)</th>
                    <th>Subtotal (Q)</th>
                </tr>
            </thead>
            <tbody>
                <%
                    ps = con.prepareStatement(
                        "SELECT p.producto, d.cantidad, d.precio_unitario, d.subtotal " +
                        "FROM ventas_detalle d " +
                        "INNER JOIN productos p ON d.id_producto = p.id_producto " +
                        "WHERE d.id_venta = ?"
                    );
                    ps.setInt(1, Integer.parseInt(idVenta));
                    rs = ps.executeQuery();

                    double total = 0;
                    boolean hayProductos = false;
                    while (rs.next()) {
                        hayProductos = true;
                        total += rs.getDouble("subtotal");
                %>
                <tr>
                    <td><%= rs.getString("producto") %></td>
                    <td class="text-center"><%= rs.getInt("cantidad") %></td>
                    <td class="text-end">Q <%= String.format("%.2f", rs.getDouble("precio_unitario")) %></td>
                    <td class="text-end">Q <%= String.format("%.2f", rs.getDouble("subtotal")) %></td>
                </tr>
                <% } %>

                <% if (!hayProductos) { %>
                    <tr><td colspan="4" class="text-center text-muted">No hay productos en esta venta.</td></tr>
                <% } %>
            </tbody>
            <tfoot>
                <tr>
                    <td colspan="3" class="text-end">Total:</td>
                    <td class="text-end">Q <%= String.format("%.2f", total) %></td>
                </tr>
            </tfoot>
        </table>

        <%
                rs.close();
                con.close();
            }
        %>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
