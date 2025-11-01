package modelo;

import java.sql.*;
import java.util.*;
import utils.ConexionDB;

public class VentaDAO {

    public static List<Map<String, Object>> obtenerVentasConTotales(String fechaInicio, String fechaFin) {
        List<Map<String, Object>> lista = new ArrayList<>();

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT v.id_venta, v.no_factura, v.serie, v.fecha_venta, ")
           .append("c.nombres AS cliente, v.total ")
           .append("FROM ventas v ")
           .append("INNER JOIN clientes c ON v.id_cliente = c.id_cliente ")
           .append("WHERE 1=1 ");

        if (fechaInicio != null && !fechaInicio.isEmpty() && fechaFin != null && !fechaFin.isEmpty()) {
            sql.append("AND DATE(v.fecha_venta) BETWEEN ? AND ? ");
        }

        sql.append("ORDER BY v.fecha_venta DESC");

        try (Connection con = new ConexionDB().getConexion();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            int index = 1;
            if (fechaInicio != null && !fechaInicio.isEmpty() && fechaFin != null && !fechaFin.isEmpty()) {
                ps.setString(index++, fechaInicio);
                ps.setString(index++, fechaFin);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> fila = new HashMap<>();
                    fila.put("id_venta", rs.getInt("id_venta"));
                    fila.put("no_factura", rs.getInt("no_factura"));
                    fila.put("serie", rs.getString("serie"));
                    fila.put("fecha_venta", rs.getTimestamp("fecha_venta"));
                    fila.put("cliente", rs.getString("cliente"));
                    fila.put("total", rs.getDouble("total"));
                    lista.add(fila);
                }
            }

        } catch (SQLException e) {
            System.out.println("❌ Error al obtener ventas: " + e.getMessage());
        }

        return lista;
    }
}
