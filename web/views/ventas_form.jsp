<%@ include file="../WEB-INF/jwtFilter.jsp" %>
<%@ include file="../includes/menu.jsp" %>
<%@ page import="java.sql.*,utils.ConexionDB" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Nueva Venta</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

    <style>
        .content-wrapper {
            margin-left: 250px;
            padding: 30px;
            min-height: 100vh;
        }
        .card-header {
            background-color: #0d6efd;
            color: white;
            font-weight: bold;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
    </style>
</head>

<body>
<div class="content-wrapper">
    <div class="card shadow mt-4">
        <div class="card-header">
            <h5 class="mb-0"><i class="bi bi-cart-plus"></i> Nueva Venta</h5>
            <a href="ventas.jsp" class="btn btn-light btn-sm"><i class="bi bi-arrow-left"></i> Volver</a>
        </div>

        <div class="card-body">
            <form action="../ControladorVenta" method="post">
                <input type="hidden" name="accion" value="guardar">
                <input type="hidden" name="idCliente" id="idCliente">

                <!-- ? Buscar Cliente por NIT -->
               <!-- ? Buscar Cliente por NIT -->
<div class="row mb-3">
    <div class="col-md-4">
        <label class="form-label fw-bold">NIT del Cliente</label>
        <div class="input-group input-group-sm"> <!-- ? tamaño más pequeño -->
            <input type="text" id="nit" name="nit" class="form-control" placeholder="Ej. 123456-7">
            <button type="button" class="btn btn-primary px-2" onclick="buscarCliente()" title="Buscar">
                <i class="bi bi-search"></i>
            </button>
            <a href="clientes.jsp" class="btn btn-success px-2" title="Nuevo cliente">
                <i class="bi bi-person-plus"></i>
            </a>
        </div>
    </div>
    <div class="col-md-8">
        <label class="form-label fw-bold">Cliente</label>
        <input type="text" id="nombreCliente" class="form-control form-control-sm" readonly placeholder="Nombre del cliente">
    </div>
</div>

<div class="row mb-3">
    <div class="col-md-6">
        <label class="form-label">Dirección</label>
        <input type="text" id="direccion" class="form-control form-control-sm" readonly>
    </div>
    <div class="col-md-3">
        <label class="form-label">Teléfono</label>
        <input type="text" id="telefono" class="form-control form-control-sm" readonly>
    </div>
</div>
 <!-- ? Empleado -->
                <div class="row mb-3">
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Empleado</label>
                        <select class="form-select" name="idEmpleado" required>
                            <option value="">Seleccione un empleado</option>
                            <%
                                try (Connection con = new ConexionDB().getConexion();
                                     Statement st = con.createStatement();
                                     ResultSet rs = st.executeQuery("SELECT id_empleado, CONCAT(nombres, ' ', apellidos) AS nombre FROM empleados")) {
                                    while (rs.next()) {
                            %>
                                <option value="<%= rs.getInt("id_empleado") %>"><%= rs.getString("nombre") %></option>
                            <%
                                    }
                                } catch (Exception e) {
                                    out.print("<option>Error cargando empleados</option>");
                                }
                            %>
                        </select>
                    </div>
                </div>

                <!-- ? Detalle de productos -->
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
                        <tr>
                            <td>
                                <select class="form-select" name="idProducto" onchange="actualizarPrecio(this)" required>
                                    <option value="">Seleccione un producto</option>
                                    <%
                                        try (Connection con = new ConexionDB().getConexion();
                                             Statement st = con.createStatement();
                                             ResultSet rs = st.executeQuery("SELECT id_producto, producto, precio_venta, existencia FROM productos WHERE existencia > 0")) {
                                            while (rs.next()) {
                                    %>
                                        <option value="<%= rs.getInt("id_producto") %>"
                                                data-precio="<%= rs.getDouble("precio_venta") %>"
                                                data-existencia="<%= rs.getInt("existencia") %>">
                                            <%= rs.getString("producto") %>
                                        </option>
                                    <%
                                            }
                                        } catch (Exception e) {
                                            out.print("<option>Error cargando productos</option>");
                                        }
                                    %>
                                </select>
                            </td>
                            <td><input type="number" class="form-control precio" name="precio" step="0.01" readonly></td>
                            <td><input type="number" class="form-control cantidad" name="cantidad" min="1" value="1" onchange="validarCantidad(this)" required></td>
                            <td><input type="number" class="form-control subtotal" name="subtotal" readonly></td>
                            <td><button type="button" class="btn btn-danger btn-sm" onclick="eliminarFila(this)"><i class="bi bi-trash"></i></button></td>
                        </tr>
                    </tbody>
                </table>

                <button type="button" class="btn btn-secondary" onclick="agregarFila()">
                    <i class="bi bi-plus-circle"></i> Agregar Producto
                </button>

                <div class="mt-4 text-end">
                    <label class="fw-bold me-3">Total:</label>
                    <span class="fw-bold fs-5" id="total">Q0.00</span>
                    <input type="hidden" name="totalVenta" id="totalVenta">
                </div>

                <div class="mt-4 text-end">
                    <button type="submit" class="btn btn-success btn-lg">
                        <i class="bi bi-save"></i> Guardar Venta
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
function buscarCliente() {
    const nit = document.getElementById("nit").value.trim();
    if (nit === "") {
        alert("Ingrese un NIT válido.");
        return;
    }

    fetch("code/buscarCliente.jsp?nit=" + nit)
        .then(res => res.text())
        .then(data => {
            if (data && data.includes("|")) {
                const partes = data.split("|");
                document.getElementById("idCliente").value = partes[0];
                document.getElementById("nombreCliente").value = partes[1] + " " + partes[2];
                document.getElementById("direccion").value = partes[3];
                document.getElementById("telefono").value = partes[4];
            } else {
                alert("?? Cliente no encontrado con ese NIT. Puede agregarlo con 'Nuevo Cliente'.");
                document.getElementById("idCliente").value = "";
                document.getElementById("nombreCliente").value = "";
                document.getElementById("direccion").value = "";
                document.getElementById("telefono").value = "";
            }
        })
        .catch(err => {
            alert("Error al buscar cliente: " + err);
        });
}

// ?? Funciones del detalle de venta (existencias, subtotales, etc.)
function actualizarPrecio(select) {
    const fila = select.closest('tr');
    const precio = select.options[select.selectedIndex].dataset.precio || 0;
    const existencia = select.options[select.selectedIndex].dataset.existencia || 0;

    fila.querySelector('.precio').value = precio;
    fila.querySelector('.cantidad').max = existencia;
    fila.querySelector('.cantidad').value = 1;
    calcularSubtotal(fila.querySelector('.cantidad'));
}

function validarCantidad(input) {
    const max = parseInt(input.max) || 0;
    let valor = parseInt(input.value) || 0;
    if (valor > max) {
        alert("?? Solo hay " + max + " unidades disponibles.");
        input.value = max;
    } else if (valor < 1) {
        input.value = 1;
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
        alert('Debe haber al menos un producto.');
    }
}
</script>
</body>
</html>
