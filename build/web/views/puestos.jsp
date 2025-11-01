<%@ include file="../WEB-INF/jwtFilter.jsp" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="modelo.Puesto, java.util.List" %>
<%@ include file="../includes/menu.jsp" %>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Mantenimiento de Puestos</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style>
        body { background-color: #f8f9fa; }
        .main-content { margin-left: 110px; padding: 25px; }
        tr:hover { background-color: #eef6ff; cursor: pointer; }
    </style>
</head>

<body>
<div class="main-content">
    <div class="card shadow-lg">
        <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
            <h4 class="mb-0"><i class="bi bi-briefcase"></i> Mantenimiento de Puestos</h4>
            <button class="btn btn-success" onclick="nuevoPuesto()">
                <i class="bi bi-plus-circle"></i> Nuevo Puesto
            </button>
        </div>

        <div class="card-body">
            <div id="alertContainer"></div>

            <div class="table-responsive" id="tablaContainer">
                <table class="table table-hover table-striped text-center align-middle">
                    <thead class="table-dark">
                        <tr>
                            <th>ID</th>
                            <th>Puesto</th>
                        </tr>
                    </thead>
                    <tbody id="tablaPuestos">
                        <%
                            Puesto puesto = new Puesto();
                            List<Puesto> puestos = puesto.leer();
                            for (Puesto p : puestos) {
                        %>
                        <tr class="fila-puesto"
                            data-id="<%= p.getId_puesto() %>"
                            data-nombre="<%= p.getPuesto() %>">
                            <td><%= p.getId_puesto() %></td>
                            <td><%= p.getPuesto() %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- 🧾 MODAL FORMULARIO -->
<div class="modal fade" id="modalPuesto" tabindex="-1" data-bs-backdrop="static">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form id="formPuesto">
                <div class="modal-header bg-success text-white">
                    <h5 class="modal-title" id="tituloModal"><i class="bi bi-briefcase"></i> Nuevo Puesto</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">
                    <input type="hidden" name="id_puesto" id="id_puesto">
                    <input type="hidden" name="accion" id="accion">

                    <div class="mb-3">
                        <label class="form-label">Nombre del Puesto</label>
                        <input type="text" class="form-control" id="txt_puesto" name="txt_puesto" placeholder="Ejemplo: Gerente, Cajero..." required>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="submit" class="btn btn-primary" data-accion="Agregar" id="btnGuardar">💾 Guardar</button>
                    <button type="submit" class="btn btn-warning d-none" data-accion="Actualizar" id="btnActualizar">🔄 Actualizar</button>
                    <button type="submit" class="btn btn-danger d-none" data-accion="Eliminar" id="btnEliminar">🗑️ Eliminar</button>
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
const modalPuesto = new bootstrap.Modal(document.getElementById('modalPuesto'));

// ✅ Detectar qué acción se envía
$("#formPuesto button[type='submit']").on("click", function() {
    const accion = $(this).data("accion");
    $("#accion").val(accion);
});

// 🟢 Nuevo puesto
function nuevoPuesto() {
    $("#tituloModal").text("Nuevo Puesto");
    $("#accion").val("Agregar");
    $("#formPuesto")[0].reset();
    $("#btnGuardar").removeClass("d-none");
    $("#btnActualizar, #btnEliminar").addClass("d-none");
    modalPuesto.show();
}

// ✏️ Clic en fila → editar
$(document).on("click", ".fila-puesto", function() {
    const id = $(this).data("id");
    const nombre = $(this).data("nombre");

    $("#id_puesto").val(id);
    $("#txt_puesto").val(nombre);
    $("#accion").val("Actualizar");
    $("#tituloModal").text("Editar Puesto #" + id);
    $("#btnGuardar").addClass("d-none");
    $("#btnActualizar, #btnEliminar").removeClass("d-none");
    modalPuesto.show();
});

// 💾 Guardar, Actualizar o Eliminar (AJAX)
$("#formPuesto").on("submit", function(e) {
    e.preventDefault();
    const accion = $("#accion").val();
    const puesto = $("#txt_puesto").val().trim();

    if (puesto === "" && accion !== "Eliminar") {
        mostrarAlerta("⚠️ El nombre del puesto no puede estar vacío.", "warning");
        return;
    }

    $.ajax({
        url: "../sr_puesto",
        type: "POST",
        data: $(this).serialize(),
        success: function() {
            modalPuesto.hide();
            recargarTabla();
            mostrarAlerta(`✅ Puesto ${accion.toLowerCase()} correctamente.`, "success");
        },
        error: function() {
            mostrarAlerta("❌ Error al procesar la solicitud.", "danger");
        }
    });
});

// 🔄 Recargar tabla después de cambios
function recargarTabla() {
    $("#tablaPuestos").load(location.href + " #tablaPuestos>*", "");
}

// ⚠️ Mostrar alerta (Bootstrap)
function mostrarAlerta(mensaje, tipo) {
    const alerta = `
        <div class="alert alert-${tipo} alert-dismissible fade show mt-3" role="alert">
            ${mensaje}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>`;
    $("#alertContainer").html(alerta);
    setTimeout(() => { $(".alert").alert('close'); }, 4000);
}
</script>
</body>
</html>
