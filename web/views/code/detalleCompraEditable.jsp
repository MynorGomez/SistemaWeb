<%@ page import="java.sql.*, utils.ConexionDB" %>
<%
    String idCompra = request.getParameter("id_compra");
    if (idCompra == null || idCompra.trim().isEmpty()) idCompra = "0";

    ConexionDB cn = new ConexionDB();
    Connection con = cn.getConexion();

    String query = "SELECT d.id_producto, p.producto, d.cantidad, d.precio_unitario " +
                   "FROM compras_detalle d INNER JOIN productos p ON d.id_producto = p.id_producto " +
                   "WHERE d.id_compra = ?";
    PreparedStatement ps = con.prepareStatement(query);
    ps.setInt(1, Integer.parseInt(idCompra));
    ResultSet rs = ps.executeQuery();
%>

<!-- ============================ -->
<!-- ? TABLA DETALLE DE PRODUCTOS -->
<!-- ============================ -->
<div class="table-responsive">
    <table class="table table-bordered text-center align-middle" id="tablaDetalle">
        <thead class="table-success">
            <tr>
                <th style="width: 35%">Producto</th>
                <th style="width: 15%">Cantidad</th>
                <th style="width: 20%">Precio Costo</th>
                <th style="width: 20%">Subtotal</th>
                <th style="width: 10%">Acción</th>
            </tr>
        </thead>
        <tbody id="detalleBody">
            <%
                boolean tieneRegistros = false;
                while (rs.next()) {
                    tieneRegistros = true;
            %>
            <tr>
                <td>
                    <select name="id_producto[]" class="form-select producto" required>
                        <%
                            PreparedStatement psProd = con.prepareStatement("SELECT id_producto, producto FROM productos");
                            ResultSet rsP = psProd.executeQuery();
                            while (rsP.next()) {
                                boolean selected = (rsP.getInt("id_producto") == rs.getInt("id_producto"));
                        %>
                            <option value="<%= rsP.getInt("id_producto") %>" <%= selected ? "selected" : "" %>>
                                <%= rsP.getString("producto") %>
                            </option>
                        <%
                            }
                            rsP.close();
                            psProd.close();
                        %>
                    </select>
                </td>
                <td><input type="number" name="cantidad[]" class="form-control cantidad" min="1" value="<%= rs.getInt("cantidad") %>" required></td>
                <td><input type="number" name="precio_unitario[]" class="form-control precio" step="0.01" min="0" value="<%= rs.getDouble("precio_unitario") %>" required></td>
                <td><input type="text" class="form-control subtotal" readonly></td>
                <td><button type="button" class="btn btn-danger btn-sm eliminarFila"><i class="bi bi-trash"></i></button></td>
            </tr>
            <%
                }
                if (!tieneRegistros) {
            %>
            <tr>
                <td>
                    <select name="id_producto[]" class="form-select producto" required>
                        <%
                            PreparedStatement psProd = con.prepareStatement("SELECT id_producto, producto FROM productos");
                            ResultSet rsP = psProd.executeQuery();
                            while (rsP.next()) {
                        %>
                            <option value="<%= rsP.getInt("id_producto") %>"><%= rsP.getString("producto") %></option>
                        <%
                            }
                            rsP.close();
                            psProd.close();
                        %>
                    </select>
                </td>
                <td><input type="number" name="cantidad[]" class="form-control cantidad" min="1" value="1" required></td>
                <td><input type="number" name="precio_unitario[]" class="form-control precio" step="0.01" min="0" value="0.00" required></td>
                <td><input type="text" class="form-control subtotal" readonly></td>
                <td><button type="button" class="btn btn-danger btn-sm eliminarFila"><i class="bi bi-trash"></i></button></td>
            </tr>
            <% } %>
        </tbody>
        <tfoot>
            <tr>
                <td colspan="3" class="text-end fw-bold">Total:</td>
                <td><input type="text" id="totalCompra" name="total" class="form-control text-center fw-bold" readonly></td>
                <td></td>
            </tr>
        </tfoot>
    </table>
</div>

<div class="d-flex justify-content-start mb-3">
    <button type="button" class="btn btn-success" id="btnAgregarProducto">
        <i class="bi bi-plus-lg"></i> Agregar producto
    </button>
</div>

<!-- ============================ -->
<!-- ?? SCRIPTS FUNCIONALES -->
<!-- ============================ -->
<script>
function calcularTotales() {
    let total = 0;
    $("#tablaDetalle tbody tr").each(function() {
        const cantidad = parseFloat($(this).find(".cantidad").val()) || 0;
        const precio = parseFloat($(this).find(".precio").val()) || 0;
        const subtotal = cantidad * precio;
        $(this).find(".subtotal").val(subtotal.toFixed(2));
        total += subtotal;
    });
    $("#totalCompra").val(total.toFixed(2));
}

// ? Agregar nueva fila
$("#btnAgregarProducto").click(function() {
    let nuevaFila = `
        <tr>
            <td>
                <select name="id_producto[]" class="form-select producto" required>
                    <% 
                        cn = new ConexionDB();
                        con = cn.getConexion();
                        ps = con.prepareStatement("SELECT id_producto, producto FROM productos");
                        rs = ps.executeQuery();
                        while (rs.next()) {
                    %>
                        <option value="<%= rs.getInt("id_producto") %>"><%= rs.getString("producto") %></option>
                    <% } con.close(); %>
                </select>
            </td>
            <td><input type="number" name="cantidad[]" class="form-control cantidad" min="1" value="1" required></td>
            <td><input type="number" name="precio_unitario[]" class="form-control precio" step="0.01" min="0" value="0.00" required></td>
            <td><input type="text" class="form-control subtotal" readonly></td>
            <td><button type="button" class="btn btn-danger btn-sm eliminarFila"><i class="bi bi-trash"></i></button></td>
        </tr>
    `;
    $("#tablaDetalle tbody").append(nuevaFila);
    calcularTotales();
});

// ?? Eliminar fila
$(document).on("click", ".eliminarFila", function() {
    $(this).closest("tr").remove();
    calcularTotales();
});

// ? Recalcular subtotal en cambios
$(document).on("input", ".cantidad, .precio", calcularTotales);

// ? Calcular totales al cargar
calcularTotales();
</script>

<%
    con.close();
%>
