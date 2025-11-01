<%@ include file="../WEB-INF/jwtFilter.jsp" %>

<%@ page import="java.sql.*, org.json.simple.JSONObject, utils.ConexionDB" %>
<%@ page contentType="application/json;charset=UTF-8" %>

<%
    String idVenta = request.getParameter("id_venta");
    JSONObject obj = new JSONObject();

    if (idVenta != null && !idVenta.isEmpty()) {
        try (Connection con = new ConexionDB().getConexion();
             PreparedStatement ps = con.prepareStatement(
                "SELECT v.id_venta, v.no_factura, v.serie, v.id_cliente, v.id_empleado, " +
                "c.nit, c.nombres, c.apellidos, c.direccion, c.telefono " +
                "FROM ventas v INNER JOIN clientes c ON v.id_cliente = c.id_cliente " +
                "WHERE v.id_venta = ?")) {

            ps.setInt(1, Integer.parseInt(idVenta));
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                obj.put("id_venta", rs.getInt("id_venta"));
                obj.put("no_factura", rs.getString("no_factura"));
                obj.put("serie", rs.getString("serie"));
                obj.put("id_cliente", rs.getInt("id_cliente"));
                obj.put("id_empleado", rs.getInt("id_empleado"));
                obj.put("nit", rs.getString("nit"));
                obj.put("nombres", rs.getString("nombres"));
                obj.put("apellidos", rs.getString("apellidos"));
                obj.put("direccion", rs.getString("direccion"));
                obj.put("telefono", rs.getString("telefono"));
            }
        } catch (Exception e) {
            obj.put("error", e.getMessage());
        }
    }

    out.print(obj.toJSONString());
%>
