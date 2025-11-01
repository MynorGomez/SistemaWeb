<%@ page import="java.sql.*, utils.ConexionDB" %>
<%@ page contentType="text/plain;charset=UTF-8" %>

<%
    // Obtenemos el parámetro NIT desde la URL
    String nit = request.getParameter("nit");
    String respuesta = "";

    if (nit != null && !nit.isEmpty()) {
        try (Connection con = new ConexionDB().getConexion();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT id_cliente, nombres, apellidos, direccion, telefono " +
                 "FROM clientes WHERE nit = ?")) {

            ps.setString(1, nit);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                // Enviamos los datos separados por "|"
                respuesta = rs.getInt("id_cliente") + "|" +
                            rs.getString("nombres") + "|" +
                            rs.getString("apellidos") + "|" +
                            rs.getString("direccion") + "|" +
                            rs.getString("telefono");
            }
        } catch (Exception e) {
            respuesta = "ERROR|" + e.getMessage();
        }
    }

    out.print(respuesta);
%>
