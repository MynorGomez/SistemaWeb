<%@ include file="../WEB-INF/jwtFilter.jsp" %>

<%@ page import="java.sql.*, utils.ConexionDB" %>
<%@ page contentType="text/plain;charset=UTF-8" %>

<%
    String idProd = request.getParameter("id_producto");
    if (idProd != null && !idProd.isEmpty()) {
        try (Connection con = new ConexionDB().getConexion();
             PreparedStatement ps = con.prepareStatement("SELECT existencia FROM productos WHERE id_producto = ?")) {
            ps.setInt(1, Integer.parseInt(idProd));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                out.print(rs.getInt("existencia"));
            } else {
                out.print("0");
            }
        } catch (Exception e) {
            out.print("error");
        }
    } else {
        out.print("0");
    }
%>
