<%@ include file="../WEB-INF/jwtFilter.jsp" %>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Compra,java.util.List,java.sql.*,utils.ConexionDB" %>
<%@ include file="../includes/menu.jsp" %>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Mantenimiento de Compras</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <style>
        body { background-color: #f8f9fa; }
        .main-content { margin-left: 110px; padding: 25px; }
        tr:hover { background-color: #e8f4ff; cursor: pointer; }
        .modal-dialog { max-width: 95%; height: 90vh; }
        .modal-content { height: 100%; display: flex; flex-direction: column; }
        .modal-body { overflow-y: auto; flex: 1 1 auto; max-height: calc(90vh - 150px); }
        .modal-footer { position: sticky; bottom: 0; background-color: white; border-top: 1px solid #ddd; }
    </style>
</head>

<body>
<div class="main-content">
    <div class="card shadow-lg">
        <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
            <h4 class="mb-0"><i class="bi bi-cart"></i> Compras</h4>
            <button class="btn btn-success" onclick="nuevaCompra()">
                <i class="bi bi-plus-circle"></i> Nueva Compra
            </button>
        </div>

        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover table-striped align-middle text-center">
                    <thead class="table-dark">
                        <tr>
                            <th>No. Orden</th>
                            <th>Proveedor</th>
                            <th>Fecha Orden</th>
                            <th>Fecha Ingreso</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Compra compra = new Compra();
                            List<Compra> compras = compra.leer(); // ← tu modelo expone leer()
                            for (Compra c : compras) {
                        %>
                        <%
                            String fechaGridemStr = (c.getFecha_gridem() != null) ? c.getFecha_gridem().toString() : "";
                            String fechaIngresoStr = "";
                            if (c.getFecha_ingreso() != null) {
                                String full = c.getFecha_ingreso().toString();
                                int idx = full.indexOf(" ");
                                fechaIngresoStr = (idx > 0) ? full.substring(0, idx) : full;
                            }
                        %>
                        <tr class="fila-compra"
                            data-id="<%= c.getId_compra() %>"
                            data-no="<%= c.getNegorden_compra() %>"
                            data-prov="<%= c.getId_proveedor() %>"
                            data-fecha="<%= fechaGridemStr %>"
                            data-fecha_ingreso="<%= fechaIngresoStr %>">
                            <td><%= c.getNegorden_compra() %></td>
                            <td><%= c.getProveedor() %></td>
                            <td><%= fechaGridemStr %></td>
                            <td><%= fechaIngresoStr %></td>
                            <td>
                                <button class="btn btn-info btn-sm ver-detalle" data-id="<%= c.getId_compra() %>">
                                    <i class="bi bi-eye"></i> Ver Detalle
                                </button>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- 🧾 MODAL COMPRA -->
<div class="modal fade" id="modalCompra" tabindex="-1" data-bs-backdrop="static">
    <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">
            <form action="../sr_compra" method="post" id="formCompra">
                <div class="modal-header bg-success text-white">
                    <h5 class="modal-title" id="tituloModal"><i class="bi bi-receipt"></i> Nueva Compra</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">
                    <input type="hidden" name="id_compra" id="id_compra">
                    <input type="hidden" name="accion" id="accion" value="">

                    <div class="row g-3">
                        <div class="col-md-3">
                            <label class="form-label">No. Orden</label>
                            <%
                                ConexionDB cn = new ConexionDB();
                                Connection con = cn.getConexion();
                                PreparedStatement ps = con.prepareStatement("SELECT IFNULL(MAX(negorden_compra), 0) + 1 AS siguiente FROM compras");
                                ResultSet rs = ps.executeQuery();
                                int siguienteOrden = 1;
                                if (rs.next()) siguienteOrden = rs.getInt("siguiente");
                                con.close();
                            %>
                            <input type="text" name="no_orden" id="no_orden" class="form-control" value="<%= siguienteOrden %>" readonly>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label">Proveedor</label>
                            <select name="id_proveedor" id="id_proveedor" class="form-select" required>
                                <option value="0">Seleccione</option>
                                <%
                                    cn = new ConexionDB();
                                    con = cn.getConexion();
                                    ps = con.prepareStatement("SELECT id_proveedor, proveedor FROM proveedores");
                                    rs = ps.executeQuery();
                                    while (rs.next()) {
                                %>
                                <option value="<%=rs.getInt("id_proveedor")%>"><%=rs.getString("proveedor")%></option>
                                <% } con.close(); %>
                            </select>
                            <a href="proveedores.jsp" class="btn btn-link p-0 mt-1">➡ Ir a Proveedores</a>
                        </div>

                        <div class="col-md-3">
                            <label class="form-label">Fecha de Orden</label>
                            <input type="date" name="fecha_gridem" id="fecha_gridem" class="form-control" required>
                        </div>

                        <div class="col-md-3">
                            <label class="form-label">Fecha de Ingreso</label>
                            <input type="date" name="fecha_ingreso" id="fecha_ingreso" class="form-control" required>
                        </div>
                    </div>

                    <hr>
                    <h6 class="text-secondary">Detalle de Productos</h6>

                    <div id="contenedorDetalles">
                        <table class="table table-bordered" id="tablaProductos">
                            <thead class="table-success text-center">
                                <tr><th>Producto</th><th>Cantidad</th><th>Precio Costo</th><th>Subtotal</th><th></th></tr>
                            </thead>
                            <tbody>
                                <!-- Al crear nueva compra, la tabla inicia vacía. Las filas se agregan con el botón 'Agregar producto' -->
                            </tbody>
                        </table>
                        <button type="button" id="agregar" class="btn btn-success mt-2">➕ Agregar producto</button>
                    </div>

                    <div class="d-flex justify-content-end mt-3">
                        <div>
                            <label class="form-label fw-bold me-2">Total:</label>
                            <input type="text" id="total" name="total" class="form-control d-inline-block" style="width:150px" readonly>
                        </div>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="submit" id="btnGuardar" class="btn btn-primary">💾 Guardar</button>
                    <button type="button" id="btnActualizar" class="btn btn-warning d-none">🔄 Actualizar</button>
                    <button type="button" id="btnEliminar" class="btn btn-danger d-none">🗑️ Eliminar</button>
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- 👁️ MODAL DETALLE -->
<div class="modal fade" id="modalDetalle" tabindex="-1">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header bg-info text-white">
                <h5 class="modal-title"><i class="bi bi-list-check"></i> Detalle de Compra</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body" id="detalleCompra"></div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
const modalCompra = new bootstrap.Modal(document.getElementById('modalCompra'));
const modalDetalle = new bootstrap.Modal(document.getElementById('modalDetalle'));

function nuevaCompra() {
    $("#tituloModal").text("Nueva Compra");
    $("#accion").val("agregar");
    $("#formCompra")[0].reset();
    $("#btnGuardar").removeClass("d-none");
    $("#btnActualizar, #btnEliminar").addClass("d-none");
    modalCompra.show();
}

// editar compra
$(document).on("click", ".fila-compra", function(e) {
    if ($(e.target).closest(".ver-detalle").length) return;

    const id = $(this).data("id");
    const no = $(this).data("no");
    const prov = $(this).data("prov");
    const fecha = $(this).data("fecha");
    const fechaIngreso = $(this).data("fecha_ingreso");

    $("#accion").val("actualizar");
    $("#id_compra").val(id);
    $("#no_orden").val(no);
    $("#id_proveedor").val(prov);
    $("#fecha_gridem").val(fecha);
    $("#fecha_ingreso").val(fechaIngreso);
    $("#tituloModal").text("Editar Compra #" + no);
    $("#btnGuardar").addClass("d-none");
    $("#btnActualizar, #btnEliminar").removeClass("d-none");

    // Respetando tu ruta:
    $("#contenedorDetalles").load("code/detalleCompraEditable.jsp?id_compra=" + id, function() {
        recalcular();
    });

    modalCompra.show();
});

// ver detalle
$(document).on("click", ".ver-detalle", function(e) {
    e.stopPropagation();
    const id = $(this).data("id");
    $("#detalleCompra").load("compras_detalles.jsp?id_compra=" + id, function() {
        modalDetalle.show();
    });
});

// agregar producto
$(document).on("click", "#agregar", function(){
    let $tbody = $("#tablaProductos tbody");
    if ($tbody.find("tr").length === 0) {
        // Si no hay filas, crear una nueva desde cero
        let nuevaFila = `<tr>
            <td>
                <select name="id_producto[]" class="form-select producto">
                    <option value="0">Seleccione</option>
                    <% 
                        cn = new ConexionDB(); 
                        con = cn.getConexion(); 
                        ps = con.prepareStatement("SELECT id_producto, producto, precio_costo FROM productos");
                        rs = ps.executeQuery();
                        while (rs.next()) { 
                    %>
                    <option value="<%=rs.getInt("id_producto")%>" data-precio="<%=rs.getDouble("precio_costo")%>">
                        <%=rs.getString("producto")%>
                    </option>
                    <% } con.close(); %>
                </select>
            </td>
            <td><input type="number" name="cantidad[]" class="form-control cantidad" value="1" min="1"></td>
            <td><input type="number" step="0.01" name="precio_unitario[]" class="form-control precio" autocomplete="off"></td>
            <td><input type="text" name="subtotal[]" class="form-control subtotal" readonly></td>
            <td class="text-center"><button type="button" class="btn btn-danger btn-sm eliminar">🗑️</button></td>
        </tr>`;
        $tbody.append(nuevaFila);
    } else {
        let $row = $tbody.find("tr:first").clone();
        $row.find("input").val("");
        $row.find("select").prop("selectedIndex", 0);
        $row.find(".cantidad").val("1");
        $tbody.append($row);
    }
});

// eliminar fila
$(document).on("click", ".eliminar", function(){
    if($("#tablaProductos tbody tr").length > 1){
        $(this).closest("tr").remove();
        recalcular();
    }
});

// recalcular subtotal y total
$(document).on("change input", ".producto, .cantidad, .precio", function(){
    recalcular();
});

function recalcular(){
    let total = 0;
    $("#tablaProductos tbody tr").each(function(){
        const $row = $(this);
        let precio = parseFloat($row.find(".precio").val());
        if (isNaN(precio)) precio = 0;
        const cantidad = parseInt($row.find(".cantidad").val()) || 0;
        const subtotal = precio * cantidad;
        $row.find(".subtotal").val(subtotal.toFixed(2));
        total += subtotal;
    });
    $("#total").val(total.toFixed(2));
}

// ✅ Validar productos solo si es agregar
$("#formCompra").submit(function(e){
    if($("#accion").val() === "agregar") {
        let filasValidas = 0;
        $("#tablaProductos tbody tr").each(function(){
            const prod = $(this).find(".producto").val();
            const cantidad = parseFloat($(this).find(".cantidad").val() || 0);
            const precio = parseFloat($(this).find(".precio").val() || 0);
            if(prod !== "0" && prod !== "" && cantidad > 0 && precio > 0){
                filasValidas++;
            }
        });
        if(filasValidas === 0){
            alert("⚠️ Debes agregar al menos un producto con cantidad y precio válidos antes de guardar la compra.");
            e.preventDefault();
            return false;
        }
    }
});

// eliminar compra
$("#btnEliminar").click(function(){
    if(confirm("¿Seguro que deseas eliminar esta compra?")){
        const id = $("#id_compra").val();
        $.post("../sr_compra", { accion: "eliminar", id_compra: id }, function(){
            location.reload();
        });
    }
});

// actualizar compra
$("#btnActualizar").click(function(){
    $("#accion").val("actualizar");
    $("#formCompra").submit();
});
</script>
</body>
</html>
