<%@ include file="../WEB-INF/jwtFilter.jsp" %>
<%@ include file="../includes/menu.jsp" %>
<%@ page import="java.sql.*,utils.ConexionDB" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Editar Venta</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        .content-wrapper {
            margin-left: 250px;
            padding: 30px;
            min-height: 100vh;
        }
        .card-header {
            background-color: #ffc107;
            font-weight: bold;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .table th, .table td { text-align: center; }
    </style>
</head>
<body>
<div class="content-wrapper">
    <div class="card shadow mt-4">
        <div class="card-header text-dark">
            <h5 class="mb-0"><i class="bi bi-pencil-square"></i> Editar Venta</h5>
            <a href="ventas.jsp" class="btn btn-light btn-sm"><i class="bi bi-arrow-left"></i> Volver</a>
        </div>

        <div class="card-body">
            <%
                int idVenta = Integer.parseInt(request.getParameter("idVenta"));
                Connection con = new ConexionDB().getConexion();

                PreparedStatement psVenta = con.prepareStatement(
                    "SELECT v.id_cliente, v.id_empleado, v.total, c.nit, CONCAT(c.nombres, ' ', c.apellidos) AS cliente, c.direccion, c.telefono " +
                    "FROM ventas v JOIN clientes c ON v.id_cliente=c.id_cliente WHERE v.id_venta=?");
                psVenta.setInt(1, idVenta);
                ResultSet rsVenta = psVenta.executeQuery();
                rsVenta.next();
            %>

            <form action="../ControladorVenta" method="post">
                <input type="hidden" name="accion" value="editar">
                <input type="hidden" name="idVenta" value="<%= idVenta %>">
                <input type="hidden" name="idCliente" value="<%= rsVenta.getInt("id_cliente") %>">

                <!-- Datos del cliente -->
                <div class="row mb-3">
                    <div class="col-md-4">
                        <label class="form-label fw-bold">NIT</label>
                        <input type="text" class="form-control form-control-sm" value="<%= rsVenta.getString("nit") %>" readonly>
                    </div>
                    <div class="col-md-8">
                        <label class="form-label fw-bold">Cliente</label>
                        <input type="text" class="form-control form-control-sm" value="<%= rsVenta.getString("cliente") %>" readonly>
                    </div>
                </div>
                <div class="row mb-3">
                    <div class="col-md-6">
                        <label class="form-label">Dirección</label>
                        <input type="text" class="form-control form-control-sm" value="<%= rsVenta.getString("direccion") %>" readonly>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Teléfono</label>
                        <input type="text" class="form-control form-control-sm" value="<%= rsVenta.getString("telefono") %>" readonly>
                    </div>
                </div>

                <!-- Empleado -->
                <div class="row mb-3">
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Empleado</label>
                        <select class="form-select form-select-sm" name="idEmpleado" required>
                            <%
                                int idEmpleadoSel = rsVenta.getInt("id_empleado");
                                try (Statement st = con.createStatement();
                                     ResultSet rse = st.executeQuery("SELECT id_empleado, CONCAT(nombres, ' ', apellidos) AS nombre FROM empleados")) {
                                    while (rse.next()) {
                                        int idEmp = rse.getInt("id_empleado");
                            %>
                                <option value="<%= idEmp %>" <%= (idEmp == idEmpleadoSel) ? "selected" : "" %>>
                                    <%= rse.getString("nombre") %>
                                </option>
                            <%
                                    }
                                }
                            %>
                        </select>
                    </div>
                </div>

                <!-- Detalle de productos -->
                <h5 class="mt-4 mb-3">Detalle de Productos</h5>
                <table class="table table-bordered align-middle" id="detalleTable">
                    <thead class="table-dark">
                        <tr>
                            <th>Producto</th>
                            <th>Precio (Q)</th>
                            <th>Cantidad</th>
                            <th>Subtotal</th>
                            <th>Acción</th>
                        </tr>
                    </thead>
                    <tbody id="detalleBody">
                        <%
                            PreparedStatement psd = con.prepareStatement(
                                "SELECT vd.id_producto, p.producto, p.precio_venta, p.existencia, vd.cantidad, vd.subtotal " +
                                "FROM ventas_detalle vd JOIN productos p ON vd.id_producto=p.id_producto WHERE vd.id_venta=?");
                            psd.setInt(1, idVenta);
                            ResultSet rsd = psd.executeQuery();
                            double total = 0;
                            while (rsd.next()) {
                                total += rsd.getDouble("subtotal");
                        %>
                        <tr>
                            <td>
                                <select class="form-select form-select-sm" name="idProducto" onchange="actualizarPrecio(this)" required>
                                    <%
                                        int idProdSel = rsd.getInt("id_producto");
                                        try (Statement st2 = con.createStatement();
                                             ResultSet rsp = st2.executeQuery("SELECT id_producto, producto, precio_venta, existencia FROM productos")) {
                                            while (rsp.next()) {
                                                int idp = rsp.getInt("id_producto");
                                    %>
                                        <option value="<%= idp %>"
                                                data-precio="<%= rsp.getDouble("precio_venta") %>"
                                                data-existencia="<%= rsp.getInt("existencia") %>"
                                                <%= (idp == idProdSel) ? "selected" : "" %>>
                                            <%= rsp.getString("producto") %>
                                        </option>
                                    <%
                                            }
                                        }
                                    %>
                                </select>
                            </td>
                            <td><input type="number" name="precio" value="<%= rsd.getDouble("precio_venta") %>" class="form-control form-control-sm precio" readonly></td>
                            <td>
                                <input type="number" name="cantidad" value="<%= rsd.getInt("cantidad") %>"
                                       class="form-control form-control-sm cantidad" min="1"
                                       onchange="validarCantidad(this)">
                                <input type="hidden" class="existencia" value="<%= rsd.getInt("existencia") %>">
                            </td>
                            <td><input type="number" name="subtotal" value="<%= rsd.getDouble("subtotal") %>" class="form-control form-control-sm subtotal" readonly></td>
                            <td><button type="button" class="btn btn-danger btn-sm" onclick="eliminarFila(this)"><i class="bi bi-trash"></i></button></td>
                        </tr>
                        <%
                            }
                            con.close();
                        %>
                    </tbody>
                </table>

                <button type="button" class="btn btn-secondary btn-sm" onclick="agregarFila()">
                    <i class="bi bi-plus-circle"></i> Agregar Producto
                </button>

                <div class="text-end mt-3">
                    <label class="fw-bold me-3">Total:</label>
                    <span class="fw-bold fs-5" id="total">Q<%= total %></span>
                    <input type="hidden" name="totalVenta" id="totalVenta" value="<%= total %>">
                </div>

                <div class="text-end mt-4">
                    <a href="${pageContext.request.contextPath}/FacturaPDF?idVenta=${param.idVenta}"
   target="_blank" class="btn btn-danger">
    <i class="bi bi-file-earmark-pdf"></i> Generar Factura PDF</a>
                    <button type="submit" class="btn btn-warning btn-lg">
                        <i class="bi bi-save"></i> Actualizar Venta
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
function actualizarPrecio(select) {
    const fila = select.closest('tr');
    const precio = select.options[select.selectedIndex].dataset.precio || 0;
    const existencia = select.options[select.selectedIndex].dataset.existencia || 0;

    fila.querySelector('.precio').value = precio;
    fila.querySelector('.existencia').value = existencia;

    const cantidad = fila.querySelector('.cantidad');
    cantidad.max = existencia;
    cantidad.value = 1;

    calcularSubtotal(cantidad);
}

function validarCantidad(input) {
    const fila = input.closest('tr');
    const max = parseInt(fila.querySelector('.existencia').value) || 0;
    let valor = parseInt(input.value) || 0;

    if (valor > max) {
        alert("?? Solo hay " + max + " unidades disponibles.");
        valor = max;
        input.value = max;
    } else if (valor < 1) {
        input.value = 1;
        valor = 1;
    }
    calcularSubtotal(input);
}

function calcularSubtotal(input) {
    const fila = input.closest('tr');
    const precio = parseFloat(fila.querySelector('.precio').value) || 0;
    const cantidad = parseInt(fila.querySelector('.cantidad').value) || 0;
    const subtotal = precio * cantidad;
    fila.querySelector('.subtotal').value = subtotal.toFixed(2);
    calcularTotal();
}

function calcularTotal() {
    let total = 0;
    document.querySelectorAll('.subtotal').forEach(el => total += parseFloat(el.value) || 0);
    document.getElementById('total').innerText = 'Q' + total.toFixed(2);
    document.getElementById('totalVenta').value = total.toFixed(2);
}

function agregarFila() {
    const tabla = document.getElementById('detalleBody');
    const fila = tabla.rows[0].cloneNode(true);

    fila.querySelectorAll('input').forEach(i => i.value = '');
    fila.querySelector('select').selectedIndex = 0;
    tabla.appendChild(fila);
}

function eliminarFila(btn) {
    const filas = document.querySelectorAll('#detalleBody tr');
    if (filas.length > 1) {
        btn.closest('tr').remove();
        calcularTotal();
    } else {
        alert('Debe haber al menos un producto en la venta.');
    }
}
</script>
</body>
</html>
