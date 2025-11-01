<%@ include file="../WEB-INF/jwtFilter.jsp" %>
<%@ include file="../includes/menu.jsp" %>
<%@ page import="java.sql.*, utils.ConexionDB" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Listado de Ventas</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

    <style>
        /* ? Ajusta el espacio para el menú lateral */
        body {
            background-color: #f8f9fa;
        }

        .content-wrapper {
            margin-left: 250px; /* ancho de tu sidebar */
            padding: 30px;
            min-height: 100vh;
        }

        .card {
            border: none;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
            max-width: 1200px;
            margin: auto;
        }
        .card-header {
            background-color: #0d6efd;
            color: white;
            font-weight: bold;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .table th, .table td {
            text-align: center;
            vertical-align: middle;
        }
    </style>
</head>

<body>
<div class="content-wrapper">
    <div class="card">
        <div class="card-header">
            <span><i class="bi bi-receipt"></i> Listado de Ventas</span>
            <a href="ventas_form.jsp" class="btn btn-light btn-sm">
                <i class="bi bi-plus-circle"></i> Nueva Venta
            </a>
        </div>

        <div class="card-body">
            <table class="table table-striped table-bordered align-middle">
                <thead class="table-dark">
                    <tr>
                        <th>ID</th>
                        <th>No. Factura</th>
                        <th>Cliente</th>
                        <th>Empleado</th>
                        <th>Fecha</th>
                        <th>Total (Q)</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    Connection con = null;
                    try {
                        con = new ConexionDB().getConexion();
                        String sql = "SELECT v.id_venta AS idVenta, v.no_factura, "
                                   + "CONCAT(c.nombres, ' ', c.apellidos) AS cliente, "
                                   + "CONCAT(e.nombres, ' ', e.apellidos) AS empleado, "
                                   + "v.fecha_venta, v.total "
                                   + "FROM ventas v "
                                   + "JOIN clientes c ON v.id_cliente = c.id_cliente "
                                   + "JOIN empleados e ON v.id_empleado = e.id_empleado "
                                   + "ORDER BY v.id_venta DESC";

                        Statement st = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
                        ResultSet rs = st.executeQuery(sql);

                        rs.last();
                        int total = rs.getRow();
                        rs.beforeFirst();

                        if (total == 0) {
                %>
                            <tr>
                                <td colspan="7" class="text-center text-muted">
                                    <i class="bi bi-info-circle"></i> No hay ventas registradas todavía.
                                </td>
                            </tr>
                <%
                        } else {
                            while (rs.next()) {
                %>
                            <tr>
                                <td><%= rs.getInt("idVenta") %></td>
                                <td><%= rs.getString("no_factura") %></td>
                                <td><%= rs.getString("cliente") %></td>
                                <td><%= rs.getString("empleado") %></td>
                                <td><%= rs.getTimestamp("fecha_venta") %></td>
                                <td>Q<%= rs.getBigDecimal("total") %></td>
                                <td>
                                    <button class="btn btn-info btn-sm" 
                                            onclick="verDetalle(<%= rs.getInt("idVenta") %>)">
                                        <i class="bi bi-eye"></i>
                                    </button>
                                    <a href="ventas_editar.jsp?idVenta=<%= rs.getInt("idVenta") %>" 
                                       class="btn btn-warning btn-sm"><i class="bi bi-pencil-square"></i></a>
                                    <form action="../ControladorVenta" method="post" style="display:inline">
                                        <input type="hidden" name="accion" value="eliminar">
                                        <input type="hidden" name="idVenta" value="<%= rs.getInt("idVenta") %>">
                                        <button type="submit" class="btn btn-danger btn-sm"
                                                onclick="return confirm('¿Eliminar esta venta?');">
                                            <i class="bi bi-trash"></i>
                                        </button>
                                    </form>
                                </td>
                            </tr>
                <%
                            }
                        }
                        rs.close(); st.close();
                    } catch (Exception e) {
                %>
                    <tr>
                        <td colspan="7" class="text-danger text-center">
                            ?? Error al consultar ventas: <%= e.getMessage() %>
                        </td>
                    </tr>
                <%
                    } finally {
                        if (con != null) try { con.close(); } catch (SQLException ex) {}
                    }
                %>
                </tbody>
            </table>

            <!-- Mensajes de operación -->
            <%
                String msg = request.getParameter("msg");
                if ("ok".equals(msg)) {
            %>
                <div class="alert alert-success mt-3"><i class="bi bi-check-circle"></i> Venta registrada correctamente.</div>
            <%
                } else if ("editok".equals(msg)) {
            %>
                <div class="alert alert-info mt-3">Venta actualizada correctamente.</div>
            <%
                } else if ("deleted".equals(msg)) {
            %>
                <div class="alert alert-warning mt-3">Venta eliminada correctamente.</div>
            <%
                }
            %>
                <% if ("editok".equals(request.getParameter("msg"))) { %>
<div class="alert alert-info mt-3">
     Venta actualizada correctamente.
        </div>
<% } %>

<!-- ? MODAL DETALLE VENTA -->
<div class="modal fade" id="detalleVentaModal" tabindex="-1" data-bs-backdrop="static">
    <div class="modal-dialog modal-xl modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header bg-info text-white">
                <h5 class="modal-title"><i class="bi bi-card-list"></i> Detalle de Venta</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body" id="contenidoDetalleVenta">
                <div class="text-center text-muted py-5">
                    <div class="spinner-border text-info mb-3" role="status"></div><br>
                    Cargando detalle de la venta...
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
function verDetalle(idVenta) {
    const modal = new bootstrap.Modal(document.getElementById('detalleVentaModal'));
    document.getElementById('contenidoDetalleVenta').innerHTML = `
        <div class="text-center text-muted py-5">
            <div class="spinner-border text-info mb-3" role="status"></div><br>
            Cargando detalle de la venta...
        </div>`;
    
    fetch("detalleVenta.jsp?idVenta=" + idVenta)
        .then(res => res.text())
        .then(html => {
            document.getElementById('contenidoDetalleVenta').innerHTML = html;
        })
        .catch(err => {
            document.getElementById('contenidoDetalleVenta').innerHTML =
                "<div class='alert alert-danger text-center'>Error al cargar detalle: " + err + "</div>";
        });
    modal.show();
}
</script>
</body>
</html>
