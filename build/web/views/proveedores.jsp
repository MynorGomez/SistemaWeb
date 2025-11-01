<%@ include file="../WEB-INF/jwtFilter.jsp" %>
<%@ include file="../includes/menu.jsp" %>
<%@ page import="modelo.Proveedor,java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Mantenimiento de Proveedores</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style>
        body { background-color: #f8f9fa; }
        .main-content { margin-left: 110px; padding: 25px; }
        tr:hover { background-color: #e8f4ff; cursor: pointer; }
    </style>
</head>

<body>
<div class="main-content">
    <div class="card shadow-lg">
        <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
            <h4 class="mb-0"><i class="bi bi-truck"></i> Proveedores</h4>
            <button class="btn btn-success" onclick="nuevoProveedor()">
                <i class="bi bi-plus-circle"></i> Nuevo Proveedor
            </button>
        </div>

        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover table-striped align-middle text-center" id="tablaProveedores">
                    <thead class="table-dark">
                        <tr>
                            <th>ID</th>
                            <th>Proveedor</th>
                            <th>NIT</th>
                            <th>Dirección</th>
                            <th>Teléfono</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Proveedor pr = new Proveedor();
                            List<Proveedor> lista = pr.leer();
                            for (Proveedor p : lista) {
                        %>
                        <tr onclick="editarProveedor(this)"
                            data-id="<%= p.getId_proveedor() %>"
                            data-proveedor="<%= p.getProveedor() %>"
                            data-nit="<%= p.getNit() %>"
                            data-direccion="<%= p.getDireccion() %>"
                            data-telefono="<%= p.getTelefono() %>">
                            <td><%= p.getId_proveedor() %></td>
                            <td><%= p.getProveedor() %></td>
                            <td><%= p.getNit() %></td>
                            <td><%= p.getDireccion() %></td>
                            <td><%= p.getTelefono() %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- 🧾 MODAL PROVEEDOR -->
<div class="modal fade" id="modalProveedor" tabindex="-1" data-bs-backdrop="static">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <form action="../sr_proveedor" method="post" id="formProveedor">
                <div class="modal-header bg-success text-white">
                    <h5 class="modal-title" id="tituloModal"><i class="bi bi-person-add"></i> Nuevo Proveedor</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">
                    <input type="hidden" name="id_proveedor" id="id_proveedor">

                    <div class="row g-3">
                        <div class="col-md-6"><input type="text" name="txt_proveedor" id="txt_proveedor" class="form-control" placeholder="Proveedor" required></div>
                        <div class="col-md-3"><input type="text" name="txt_nit" id="txt_nit" class="form-control" placeholder="NIT" required></div>
                        <div class="col-md-6"><input type="text" name="txt_direccion" id="txt_direccion" class="form-control" placeholder="Dirección" required></div>
                        <div class="col-md-3"><input type="text" name="txt_telefono" id="txt_telefono" class="form-control" placeholder="Teléfono" required></div>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="submit" name="btn" value="Agregar" id="btnGuardar" class="btn btn-primary">💾 Guardar</button>
                    <button type="submit" name="btn" value="Actualizar" id="btnActualizar" class="btn btn-warning d-none">🔄 Actualizar</button>
                    <button type="submit" name="btn" value="Eliminar" id="btnEliminar" class="btn btn-danger d-none" onclick="return confirm('¿Eliminar este proveedor?')">🗑️ Eliminar</button>
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
const modalProveedor = new bootstrap.Modal(document.getElementById('modalProveedor'));

// 🟢 Nuevo proveedor
function nuevoProveedor(){
    $("#tituloModal").text("Nuevo Proveedor");
    $("#formProveedor")[0].reset();
    $("#id_proveedor").val("");
    $("#btnGuardar").removeClass("d-none");
    $("#btnActualizar, #btnEliminar").addClass("d-none");
    modalProveedor.show();
}

// 🟡 Editar proveedor
function editarProveedor(fila){
    $("#tituloModal").text("Editar Proveedor");
    $("#id_proveedor").val(fila.dataset.id);
    $("#txt_proveedor").val(fila.dataset.proveedor);
    $("#txt_nit").val(fila.dataset.nit);
    $("#txt_direccion").val(fila.dataset.direccion);
    $("#txt_telefono").val(fila.dataset.telefono);
    $("#btnGuardar").addClass("d-none");
    $("#btnActualizar, #btnEliminar").removeClass("d-none");
    modalProveedor.show();
}
</script>
</body>
</html>
