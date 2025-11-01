<%@ include file="../WEB-INF/jwtFilter.jsp" %>
<%@ include file="../includes/menu.jsp" %>
<%@ page import="modelo.Cliente,java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Mantenimiento de Clientes</title>
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
            <h4 class="mb-0"><i class="bi bi-person-lines-fill"></i> Clientes</h4>
            <button class="btn btn-success" onclick="nuevoCliente()">
                <i class="bi bi-plus-circle"></i> Nuevo Cliente
            </button>
        </div>

        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover table-striped align-middle text-center" id="tablaClientes">
                    <thead class="table-dark">
                        <tr>
                            <th>ID</th>
                            <th>NIT</th>
                            <th>Nombres</th>
                            <th>Apellidos</th>
                            <th>Dirección</th>
                            <th>Teléfono</th>
                            <th>Fecha Nac.</th>
                            <th>Correo</th>
                            <th>Género</th>
                            <th>Fecha Ingreso</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Cliente c = new Cliente();
                            List<Cliente> lista = c.leer();
                            for (Cliente cli : lista) {
                        %>
                        <tr onclick="editarCliente(this)"
                            data-id="<%= cli.getId_cliente() %>"
                            data-nit="<%= cli.getNit() %>"
                            data-nombres="<%= cli.getNombres() %>"
                            data-apellidos="<%= cli.getApellidos() %>"
                            data-direccion="<%= cli.getDireccion() %>"
                            data-telefono="<%= cli.getTelefono() %>"
                            data-fn="<%= cli.getFecha_nacimiento() %>"
                            data-correo="<%= cli.getCorreo_electronico() %>"
                            data-genero="<%= cli.getGenero() %>"
                            data-fechaingreso="<%= cli.getFechaingreso() %>">
                            <td><%= cli.getId_cliente() %></td>
                            <td><%= cli.getNit() %></td>
                            <td><%= cli.getNombres() %></td>
                            <td><%= cli.getApellidos() %></td>
                            <td><%= cli.getDireccion() %></td>
                            <td><%= cli.getTelefono() %></td>
                            <td><%= cli.getFecha_nacimiento() %></td>
                            <td><%= cli.getCorreo_electronico() %></td>
                            <td><%= cli.getGenero() ? "Femenino" : "Masculino" %></td>
                            <td><%= cli.getFechaingreso() %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- 🧾 MODAL CLIENTE -->
<div class="modal fade" id="modalCliente" tabindex="-1" data-bs-backdrop="static">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <form action="../sr_cliente" method="post" id="formCliente">
                <div class="modal-header bg-success text-white">
                    <h5 class="modal-title" id="tituloModal"><i class="bi bi-person-add"></i> Nuevo Cliente</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">
                    <input type="hidden" name="id_cliente" id="id_cliente">

                    <div class="row g-3">
                        <div class="col-md-4">
                            <input type="text" name="txt_nit" id="txt_nit" class="form-control" placeholder="NIT" required>
                        </div>
                        <div class="col-md-4">
                            <input type="text" name="txt_nombres" id="txt_nombres" class="form-control" placeholder="Nombres" required>
                        </div>
                        <div class="col-md-4">
                            <input type="text" name="txt_apellidos" id="txt_apellidos" class="form-control" placeholder="Apellidos" required>
                        </div>
                        <div class="col-md-6">
                            <input type="text" name="txt_direccion" id="txt_direccion" class="form-control" placeholder="Dirección" required>
                        </div>
                        <div class="col-md-3">
                            <input type="text" name="txt_telefono" id="txt_telefono" class="form-control" placeholder="Teléfono" required>
                        </div>
                        <div class="col-md-3">
                            <input type="date" name="txt_fn" id="txt_fn" class="form-control" required>
                        </div>
                        <div class="col-md-6">
                            <input type="email" name="txt_correo" id="txt_correo" class="form-control" placeholder="Correo Electrónico">
                        </div>
                        <div class="col-md-3">
                            <select name="txt_genero" id="txt_genero" class="form-select">
                                <option value="false">Masculino</option>
                                <option value="true">Femenino</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <input type="datetime-local" name="txt_fechaingreso" id="txt_fechaingreso" class="form-control" readonly>
                        </div>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="submit" name="btn" value="Agregar" id="btnGuardar" class="btn btn-primary">💾 Guardar</button>
                    <button type="submit" name="btn" value="Actualizar" id="btnActualizar" class="btn btn-warning d-none">🔄 Actualizar</button>
                    <button type="submit" name="btn" value="Eliminar" id="btnEliminar" class="btn btn-danger d-none" onclick="return confirm('¿Eliminar este cliente?')">🗑️ Eliminar</button>
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
const modalCliente = new bootstrap.Modal(document.getElementById('modalCliente'));

// Nuevo cliente
function nuevoCliente(){
    $("#tituloModal").text("Nuevo Cliente");
    $("#formCliente")[0].reset();
    $("#id_cliente").val("");
    $("#btnGuardar").removeClass("d-none");
    $("#btnActualizar, #btnEliminar").addClass("d-none");
    $("#txt_fechaingreso").val(new Date().toISOString().slice(0,16)); // muestra hora actual
    modalCliente.show();
}

// Editar cliente
function editarCliente(fila){
    $("#tituloModal").text("Editar Cliente");
    $("#id_cliente").val(fila.dataset.id);
    $("#txt_nit").val(fila.dataset.nit);
    $("#txt_nombres").val(fila.dataset.nombres);
    $("#txt_apellidos").val(fila.dataset.apellidos);
    $("#txt_direccion").val(fila.dataset.direccion);
    $("#txt_telefono").val(fila.dataset.telefono);
    $("#txt_fn").val(fila.dataset.fn);
    $("#txt_correo").val(fila.dataset.correo);
    $("#txt_genero").val(fila.dataset.genero);
    $("#txt_fechaingreso").val(fila.dataset.fechaingreso.replace(' ', 'T'));
    $("#btnGuardar").addClass("d-none");
    $("#btnActualizar, #btnEliminar").removeClass("d-none");
    modalCliente.show();
}
</script>
</body>
</html>
