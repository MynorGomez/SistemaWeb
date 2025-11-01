<%@ include file="../WEB-INF/jwtFilter.jsp" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="modelo.Marca, java.util.List" %>
<%@ include file="../includes/menu.jsp" %>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Mantenimiento de Marcas</title>
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
            <h4 class="mb-0"><i class="bi bi-tags"></i> Mantenimiento de Marcas</h4>
            <button class="btn btn-success" onclick="nuevaMarca()">
                <i class="bi bi-plus-circle"></i> Nueva Marca
            </button>
        </div>

        <div class="card-body">
            <div id="alertContainer"></div>

            <div class="table-responsive" id="tablaContainer">
                <table class="table table-hover table-striped text-center align-middle">
                    <thead class="table-dark">
                        <tr>
                            <th>ID</th>
                            <th>Marca</th>
                        </tr>
                    </thead>
                    <tbody id="tablaMarcas">
                        <%
    Marca marca = new Marca();
    List<Marca> marcas = marca.leer();
    for (Marca marcaItem : marcas) {
%>
<tr class="fila-marca"
    data-id="<%= marcaItem.getId_marca() %>"
    data-nombre="<%= marcaItem.getMarca() %>">
    <td><%= marcaItem.getId_marca() %></td>
    <td><%= marcaItem.getMarca() %></td>
</tr>
<% } %>

                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- 🧾 MODAL FORMULARIO -->
<div class="modal fade" id="modalMarca" tabindex="-1" data-bs-backdrop="static">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form id="formMarca">
                <div class="modal-header bg-success text-white">
                    <h5 class="modal-title" id="tituloModal"><i class="bi bi-tags"></i> Nueva Marca</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">
                    <input type="hidden" name="id_marca" id="id_marca">
                    <input type="hidden" name="accion" id="accion">

                    <div class="mb-3">
                        <label class="form-label">Nombre de la Marca</label>
                        <input type="text" class="form-control" id="txt_marca" name="txt_marca" placeholder="Ejemplo: Pepsi, LG, Adidas..." required>
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
const modalMarca = new bootstrap.Modal(document.getElementById('modalMarca'));

// ✅ Detectar qué acción se envía
$("#formMarca button[type='submit']").on("click", function() {
    const accion = $(this).data("accion");
    $("#accion").val(accion);
});

// 🟢 Nueva Marca
function nuevaMarca() {
    $("#tituloModal").text("Nueva Marca");
    $("#accion").val("Agregar");
    $("#formMarca")[0].reset();
    $("#btnGuardar").removeClass("d-none");
    $("#btnActualizar, #btnEliminar").addClass("d-none");
    modalMarca.show();
}

// ✏️ Clic en fila → editar
$(document).on("click", ".fila-marca", function() {
    const id = $(this).data("id");
    const nombre = $(this).data("nombre");

    $("#id_marca").val(id);
    $("#txt_marca").val(nombre);
    $("#accion").val("Actualizar");
    $("#tituloModal").text("Editar Marca #" + id);
    $("#btnGuardar").addClass("d-none");
    $("#btnActualizar, #btnEliminar").removeClass("d-none");
    modalMarca.show();
});

// 💾 Guardar, Actualizar o Eliminar (AJAX)
$("#formMarca").on("submit", function(e) {
    e.preventDefault();
    const accion = $("#accion").val();
    const marca = $("#txt_marca").val().trim();

    if (marca === "" && accion !== "Eliminar") {
        mostrarAlerta("⚠️ El nombre de la marca no puede estar vacío.", "warning");
        return;
    }

    $.ajax({
        url: "../sr_marca",
        type: "POST",
        data: $(this).serialize(),
        success: function() {
            modalMarca.hide();
            recargarTabla();
            mostrarAlerta(`✅ Marca ${accion.toLowerCase()} correctamente.`, "success");
        },
        error: function() {
            mostrarAlerta("❌ Error al procesar la solicitud.", "danger");
        }
    });
});

// 🔄 Recargar tabla después de cambios
function recargarTabla() {
    $("#tablaMarcas").load(location.href + " #tablaMarcas>*", "");
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
