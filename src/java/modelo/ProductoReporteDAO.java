package modelo;

import java.sql.*;
import java.util.*;
import utils.ConexionDB;

public class ProductoReporteDAO {

    public static List<ProductoReporte> obtenerProductosMasVendidos() {
        List<ProductoReporte> lista = new ArrayList<>();
        String sql = "SELECT p.producto, SUM(vd.cantidad) AS total_vendido, "
                   + "SUM(vd.cantidad * vd.precio_unitario) AS total_q "
                   + "FROM ventas_detalle vd "
                   + "INNER JOIN productos p ON vd.id_producto = p.id_producto "
                   + "GROUP BY p.producto "
                   + "ORDER BY total_vendido DESC "
                   + "LIMIT 10;";

        try (Connection con = new ConexionDB().getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                ProductoReporte pr = new ProductoReporte();
                pr.setNombre(rs.getString("producto"));
                pr.setCantidad(rs.getInt("total_vendido"));
                pr.setTotal(rs.getDouble("total_q"));
                lista.add(pr);
            }

        } catch (SQLException e) {
            System.out.println("❌ Error al obtener productos más vendidos: " + e.getMessage());
        }

        return lista;
    }

    public static List<ProductoReporte> obtenerProductosMasComprados() {
        List<ProductoReporte> lista = new ArrayList<>();
        String sql = "SELECT p.producto, SUM(dc.cantidad) AS total_comprado, "
                   + "SUM(dc.cantidad * dc.precio_costo) AS total_q "
                   + "FROM detalle_compras dc "
                   + "INNER JOIN productos p ON dc.id_producto = p.id_producto "
                   + "GROUP BY p.producto "
                   + "ORDER BY total_comprado DESC "
                   + "LIMIT 10;";

        try (Connection con = new ConexionDB().getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                ProductoReporte pr = new ProductoReporte();
                pr.setNombre(rs.getString("producto"));
                pr.setCantidad(rs.getInt("total_comprado"));
                pr.setTotal(rs.getDouble("total_q"));
                lista.add(pr);
            }

        } catch (SQLException e) {
            System.out.println("❌ Error al obtener productos más comprados: " + e.getMessage());
        }

        return lista;
    }
}
