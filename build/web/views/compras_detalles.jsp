<%@ include file="../WEB-INF/jwtFilter.jsp" %>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*,java.util.*,utils.ConexionDB" %>
<%
    int id_compra = 0;
    try {
        id_compra = Integer.parseInt(request.getParameter("id_compra"));
    } catch (Exception e) { id_compra = 0; }
%>

<%
    if (id_compra > 0) {
        ConexionDB cn = new ConexionDB();
        Connection con = cn.getConexion();

        String queryCabecera = 
            "SELECT c.negorden_compra, c.fecha_gridem, c.fecha_ingreso, p.proveedor, p.nit " +
            "FROM compras c INNER JOIN proveedores p ON c.id_proveedor = p.id_proveedor " +
            "WHERE c.id_compra = ?";
        PreparedStatement psCab = con.prepareStatement(queryCabecera);
        psCab.setInt(1, id_compra);
        ResultSet rsCab = psCab.executeQuery();

        if (rsCab.next()) {
%>

<div class="container-fluid">
    <div class="card shadow-sm border-0 mb-3">
        <div class="card-body">
            <h5 class="card-title text-primary"><i class="bi bi-receipt"></i> Datos de la Compra</h5>
            <div class="row mt-3">
                <div class="col-md-3">
                    <p><strong>No. Orden:</strong> <%= rsCab.getInt("negorden_compra") %></p>
                </div>
                <div class="col-md-3">
                    <p><strong>Fecha Orden:</strong> <%= rsCab.getDate("fecha_gridem") %></p>
                </div>
                <div class="col-md-3">
                    <p><strong>Ingreso:</strong> <%= rsCab.getTimestamp("fecha_ingreso") %></p>
                </div>
                <div class="col-md-3">
                    <p><strong>Proveedor:</strong> <%= rsCab.getString("proveedor") %></p>
                </div>
            </div>
            <p><strong>NIT:</strong> <%= rsCab.getString("nit") %></p>
        </div>
    </div>

    <div class="table-responsive">
        <table class="table table-bordered table-hover align-middle">
            <thead class="table-success text-center">
                <tr>
                    <th>Producto</th>
                    <th>Cantidad</th>
                    <th>Precio Costo Unitario</th>
                    <th>Precio Venta Unitario</th>
                    <th>Subtotal</th>
                    <th>Fecha Ingreso</th>
                </tr>
            </thead>
            <tbody>
                <%
                    String queryDet = 
                        "SELECT pr.producto, pr.fecha_ingreso, d.cantidad, d.precio_unitario " +
                        "FROM compras_detalle d " +
                        "INNER JOIN productos pr ON d.id_producto = pr.id_producto " +
                        "WHERE d.id_compra = ?";
                    PreparedStatement psDet = con.prepareStatement(queryDet);
                    psDet.setInt(1, id_compra);
                    ResultSet rsDet = psDet.executeQuery();

                    double total = 0;
                    while (rsDet.next()) {
                        double precioCosto = rsDet.getDouble("precio_unitario");
                        double precioVenta = precioCosto * 1.25;
                        double subtotal = rsDet.getInt("cantidad") * precioCosto;
                        total += subtotal;
                %>
                <tr>
                    <td><%= rsDet.getString("producto") %></td>
                    <td class="text-center"><%= rsDet.getInt("cantidad") %></td>
                    <td class="text-end">Q <%= String.format("%.2f", precioCosto) %></td>
                    <td class="text-end">Q <%= String.format("%.2f", precioVenta) %></td>
                    <td class="text-end">Q <%= String.format("%.2f", subtotal) %></td>
                    <td class="text-center"><%= rsDet.getTimestamp("fecha_ingreso") %></td>
                </tr>
                <% } rsDet.close(); psDet.close(); %>
            </tbody>
            <tfoot>
                <tr class="table-dark">
                    <th colspan="4" class="text-end">Total:</th>
                    <th class="text-end">Q <%= String.format("%.2f", total) %></th>
                    <th></th>
                </tr>
            </tfoot>
        </table>
    </div>
</div>

<%
        } else {
%>
<div class="alert alert-warning text-center">
    ⚠️ No se encontró la compra con ID <%= id_compra %>.
</div>
<%
        }
        rsCab.close();
        psCab.close();
        con.close();
    } else {
%>
<div class="alert alert-danger text-center">
    ❌ Parámetro <strong>id_compra</strong> no válido.
</div>
<%
    }
%>
