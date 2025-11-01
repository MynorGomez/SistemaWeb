<%@ include file="../WEB-INF/jwtFilter.jsp" %>
<%@ page import="modelo.Producto,modelo.Marca,java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../includes/menu.jsp" %>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Mantenimiento de Productos</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <style>
        body { background-color: #f8f9fa; }
        .main-content { margin-left: 110px; padding: 25px; }
        tr:hover { background-color: #e8f4ff; cursor: pointer; }
        .product-img { max-width: 80px; height: 80px; object-fit: cover; border-radius: 8px; }
        .product-img-preview { max-width: 200px; max-height: 200px; border-radius: 10px; margin-top: 10px; }
    </style>
</head>

<body>
<%
    // 🔹 Contexto del proyecto (por ejemplo /Sistema)
    String path = request.getContextPath();
%>

<div class="main-content">
    <div class="card shadow-lg">
        <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
            <h4 class="mb-0"><i class="bi bi-box-seam"></i> Productos</h4>
            <button class="btn btn-success" onclick="nuevoProducto()">
                <i class="bi bi-plus-circle"></i> Nuevo Producto
            </button>
        </div>

        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover table-striped align-middle text-center" id="tablaProductos">
                    <thead class="table-dark">
                        <tr>
                            <th>ID</th>
                            <th>Imagen</th>
                            <th>Producto</th>
                            <th>Marca</th>
                            <th>Descripción</th>
                            <th>Precio Costo</th>
                            <th>Precio Venta</th>
                            <th>Existencia</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Producto p = new Producto();
                            List<Producto> lista = p.leer();
                            for (Producto prod : lista) {
                        %>
                        <tr onclick="editarProducto(this)"
                            data-id="<%= prod.getId_producto() %>"
                            data-producto="<%= prod.getProducto() %>"
                            data-marca="<%= prod.getId_marca() %>"
                            data-descripcion="<%= prod.getDescripcion() %>"
                            data-imagen="<%= prod.getImagen_url() %>"
                            data-costo="<%= prod.getPrecio_costo() %>"
                            data-venta="<%= prod.getPrecio_venta() %>"
                            data-existencia="<%= prod.getExistencia() %>">
                            <td><%= prod.getId_producto() %></td>
                            <td>
                                <% if (prod.getImagen_url() != null && !prod.getImagen_url().isEmpty()) { %>
                                    <img src="<%= path + "/" + prod.getImagen_url() %>" class="product-img" alt="<%= prod.getProducto() %>">
                                <% } else { %>
                                    <span class="text-muted">Sin imagen</span>
                                <% } %>
                            </td>
                            <td><%= prod.getProducto() %></td>
                            <td><%= prod.getMarca() %></td>
                            <td><%= prod.getDescripcion() %></td>
                            <td>Q<%= String.format("%.2f", prod.getPrecio_costo()) %></td>
                            <td>Q<%= String.format("%.2f", prod.getPrecio_venta()) %></td>
                            <td><%= prod.getExistencia() %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- 🧾 MODAL PRODUCTO -->
<div class="modal fade" id="modalProducto" tabindex="-1" data-bs-backdrop="static">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <!-- enctype agregado -->
            <form action="../sr_producto" method="post" id="formProducto" enctype="multipart/form-data">
                <div class="modal-header bg-success text-white">
                    <h5 class="modal-title" id="tituloModal"><i class="bi bi-box-seam"></i> Nuevo Producto</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">
                    <input type="hidden" name="id_producto" id="id_producto">
                    <input type="hidden" name="txt_imagen_actual" id="txt_imagen_actual">

                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label">Nombre del Producto</label>
                            <input type="text" name="txt_producto" id="txt_producto" class="form-control" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Marca</label>
                            <select name="drop_marca" id="drop_marca" class="form-select" required>
                                <option value="">Seleccione una marca</option>
                                <%
                                    Marca m = new Marca();
                                    List<Marca> marcas = m.leer();
                                    for (Marca marca : marcas) {
                                %>
                                    <option value="<%= marca.getId_marca() %>"><%= marca.getMarca() %></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-md-12">
                            <label class="form-label">Descripción</label>
                            <textarea name="txt_descripcion" id="txt_descripcion" class="form-control" rows="3"></textarea>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Imagen del Producto</label>
                            <input type="file" name="file_imagen" id="file_imagen" class="form-control" accept="image/*">
                            <img id="imgPreview" class="product-img-preview d-none">
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">Precio Costo</label>
                            <input type="number" name="txt_costo" id="txt_costo" class="form-control" step="0.01" min="0" required>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">Precio Venta</label>
                            <input type="number" name="txt_venta" id="txt_venta" class="form-control" step="0.01" min="0" required>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">Existencia</label>
                            <input type="number" name="txt_existencia" id="txt_existencia" class="form-control" min="0" required>
                        </div>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="submit" name="btn" value="Agregar" id="btnGuardar" class="btn btn-primary">💾 Guardar</button>
                    <button type="submit" name="btn" value="Actualizar" id="btnActualizar" class="btn btn-warning d-none">🔄 Actualizar</button>
                    <button type="submit" name="btn" value="Eliminar" id="btnEliminar" class="btn btn-danger d-none" onclick="return confirm('¿Eliminar este producto?')">🗑️ Eliminar</button>
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
const modalProducto = new bootstrap.Modal(document.getElementById('modalProducto'));

// 🟢 Nuevo producto
function nuevoProducto(){
    $("#tituloModal").text("Nuevo Producto");
    $("#formProducto")[0].reset();
    $("#id_producto").val("");
    $("#txt_imagen_actual").val("");
    $("#imgPreview").addClass("d-none");
    $("#btnGuardar").removeClass("d-none");
    $("#btnActualizar, #btnEliminar").addClass("d-none");
    modalProducto.show();
}

// 🟡 Editar producto
function editarProducto(fila){
    $("#tituloModal").text("Editar Producto");
    $("#id_producto").val(fila.dataset.id);
    $("#txt_producto").val(fila.dataset.producto);
    $("#drop_marca").val(fila.dataset.marca);
    $("#txt_descripcion").val(fila.dataset.descripcion);
    $("#txt_imagen_actual").val(fila.dataset.imagen);
    $("#txt_costo").val(fila.dataset.costo);
    $("#txt_venta").val(fila.dataset.venta);
    $("#txt_existencia").val(fila.dataset.existencia);

    // Vista previa de imagen con contextPath
    const imgUrl = fila.dataset.imagen;
    if(imgUrl)
        $("#imgPreview").attr("src", "<%= path %>/" + imgUrl).removeClass("d-none");
    else
        $("#imgPreview").addClass("d-none");

    $("#btnGuardar").addClass("d-none");
    $("#btnActualizar, #btnEliminar").removeClass("d-none");
    modalProducto.show();
}

// 🖼️ Vista previa de imagen subida
$("#file_imagen").on("change", function(){
    const file = this.files[0];
    if(file){
        const reader = new FileReader();
        reader.onload = function(e){
            $("#imgPreview").attr("src", e.target.result).removeClass("d-none");
        }
        reader.readAsDataURL(file);
    } else {
        $("#imgPreview").addClass("d-none");
    }
});
</script>
</body>
</html>
