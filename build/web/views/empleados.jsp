<%@ include file="../WEB-INF/jwtFilter.jsp" %>
<%@ include file="../includes/menu.jsp" %>
<%@ page import="modelo.Puesto,modelo.Empleado,java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Mantenimiento de Empleados</title>
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
            <h4 class="mb-0"><i class="bi bi-people-fill"></i> Empleados</h4>
            <button class="btn btn-success" onclick="nuevoEmpleado()">
                <i class="bi bi-plus-circle"></i> Nuevo Empleado
            </button>
        </div>

        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover table-striped align-middle text-center" id="tablaEmpleados">
                    <thead class="table-dark">
                        <tr>
                            <th>Código</th>
                            <th>Nombres</th>
                            <th>Apellidos</th>
                            <th>Dirección</th>
                            <th>Teléfono</th>
                            <th>Fecha Nac.</th>
                            <th>Género</th>
                            <th>Inicio Labores</th>
                            <th>Registro</th>
                            <th>Puesto</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Empleado e = new Empleado();
                            List<Empleado> lista = e.leer();
                            for (Empleado emp : lista) {
                        %>
                        <tr onclick="editarEmpleado(this)"
                            data-id="<%= emp.getId_empleado() %>"
                            data-codigo="<%= emp.getCodigo() %>"
                            data-nombres="<%= emp.getNombres() %>"
                            data-apellidos="<%= emp.getApellidos() %>"
                            data-direccion="<%= emp.getDireccion() %>"
                            data-telefono="<%= emp.getTelefono() %>"
                            data-fn="<%= emp.getFecha_nacimiento() %>"
                            data-genero="<%= emp.getGenero() %>"
                            data-fecha_inicio="<%= emp.getFecha_inicio_labores() %>"
                            data-fechaingreso="<%= emp.getFechaingreso() %>"
                            data-puesto="<%= emp.getId_puesto() %>">
                            <td><%= emp.getCodigo() %></td>
                            <td><%= emp.getNombres() %></td>
                            <td><%= emp.getApellidos() %></td>
                            <td><%= emp.getDireccion() %></td>
                            <td><%= emp.getTelefono() %></td>
                            <td><%= emp.getFecha_nacimiento() %></td>
                            <td><%= emp.getGenero() ? "Femenino" : "Masculino" %></td>
                            <td><%= emp.getFecha_inicio_labores() %></td>
                            <td><%= emp.getFechaingreso() %></td>
                            <td><%= emp.getPuesto() %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- 🧾 MODAL EMPLEADO -->
<div class="modal fade" id="modalEmpleado" tabindex="-1" data-bs-backdrop="static">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <form action="../sr_empleado" method="post" id="formEmpleado">
                <div class="modal-header bg-success text-white">
                    <h5 class="modal-title" id="tituloModal"><i class="bi bi-person-fill-add"></i> Nuevo Empleado</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">
                    <input type="hidden" name="id_empleado" id="id_empleado">

                    <div class="row g-3">
                        <div class="col-md-4">
                            <label class="form-label fw-bold">Código</label>
                            <input type="text" name="txt_codigo" id="txt_codigo" class="form-control" placeholder="Código" required>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-bold">Nombres</label>
                            <input type="text" name="txt_nombres" id="txt_nombres" class="form-control" placeholder="Nombres" required>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-bold">Apellidos</label>
                            <input type="text" name="txt_apellidos" id="txt_apellidos" class="form-control" placeholder="Apellidos" required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-bold">Dirección</label>
                            <input type="text" name="txt_direccion" id="txt_direccion" class="form-control" placeholder="Dirección" required>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-bold">Teléfono</label>
                            <input type="text" name="txt_telefono" id="txt_telefono" class="form-control" placeholder="Teléfono" required>
                        </div>

                        <div class="col-md-3">
                            <label class="form-label fw-bold">Fecha de Nacimiento</label>
                            <input type="date" name="txt_fn" id="txt_fn" class="form-control" required>
                            <small class="text-muted">Nacimiento del empleado</small>
                        </div>

                        <div class="col-md-3">
                            <label class="form-label fw-bold">Género</label>
                            <select name="txt_genero" id="txt_genero" class="form-select" required>
                                <option value="false">Masculino</option>
                                <option value="true">Femenino</option>
                            </select>
                        </div>

                        <div class="col-md-3">
                            <label class="form-label fw-bold">Inicio de Labores</label>
                            <input type="date" name="txt_fecha_inicio_labores" id="txt_fecha_inicio_labores" class="form-control" required>
                            <small class="text-muted">Inicio laboral</small>
                        </div>

                        <div class="col-md-3">
                            <label class="form-label fw-bold">Fecha de Registro</label>
                            <input type="datetime-local" id="txt_fechaingreso" class="form-control" readonly>
                            <small class="text-muted">Generada automáticamente</small>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-bold">Puesto</label>
                            <select name="drop_puesto" id="drop_puesto" class="form-select" required>
                                <option value="">Seleccione un puesto</option>
                                <%
                                    Puesto p = new Puesto();
                                    List<Puesto> puestos = p.leer();
                                    for (Puesto item : puestos) {
                                %>
                                    <option value="<%= item.getId_puesto() %>"><%= item.getPuesto() %></option>
                                <% } %>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="submit" name="btn" value="Agregar" id="btnGuardar" class="btn btn-primary">💾 Guardar</button>
                    <button type="submit" name="btn" value="Actualizar" id="btnActualizar" class="btn btn-warning d-none">🔄 Actualizar</button>
                    <button type="submit" name="btn" value="Eliminar" id="btnEliminar" class="btn btn-danger d-none" onclick="return confirm('¿Eliminar este empleado?')">🗑️ Eliminar</button>
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
const modalEmpleado = new bootstrap.Modal(document.getElementById('modalEmpleado'));

// 🟢 Nuevo empleado
function nuevoEmpleado(){
    $("#tituloModal").text("Nuevo Empleado");
    $("#formEmpleado")[0].reset();
    $("#id_empleado").val("");
    $("#btnGuardar").removeClass("d-none");
    $("#btnActualizar, #btnEliminar").addClass("d-none");

    // Mostrar fecha actual (solo visual)
    const now = new Date();
    $("#txt_fechaingreso").val(now.toISOString().slice(0,16));
    $("#txt_fechaingreso").prop("disabled", true);

    modalEmpleado.show();
}

// 🟡 Editar empleado
function editarEmpleado(fila){
    $("#tituloModal").text("Editar Empleado");
    $("#id_empleado").val(fila.dataset.id);
    $("#txt_codigo").val(fila.dataset.codigo);
    $("#txt_nombres").val(fila.dataset.nombres);
    $("#txt_apellidos").val(fila.dataset.apellidos);
    $("#txt_direccion").val(fila.dataset.direccion);
    $("#txt_telefono").val(fila.dataset.telefono);
    $("#txt_fn").val(fila.dataset.fn);
    $("#txt_genero").val(fila.dataset.genero);
    $("#txt_fecha_inicio_labores").val(fila.dataset.fecha_inicio);
    if (fila.dataset.fechaingreso) {
        $("#txt_fechaingreso").val(fila.dataset.fechaingreso.replace(' ', 'T'));
    } else {
        $("#txt_fechaingreso").val('');
    }
    $("#txt_fechaingreso").prop("disabled", true);
    $("#drop_puesto").val(fila.dataset.puesto);
    $("#btnGuardar").addClass("d-none");
    $("#btnActualizar, #btnEliminar").removeClass("d-none");
    modalEmpleado.show();
}
</script>
</body>
</html>
