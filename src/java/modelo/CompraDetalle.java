package modelo;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import utils.ConexionDB;

public class CompraDetalle {
    private long id_compra_detalle;
    private int id_compra;
    private int id_producto;
    private int cantidad;
    private double precio_unitario;

    ConexionDB cn = new ConexionDB();

    public CompraDetalle() {}

    public CompraDetalle(long idDetalle, int idCompra, int idProducto, int cantidad, double precio) {
        this.id_compra_detalle = idDetalle;
        this.id_compra = idCompra;
        this.id_producto = idProducto;
        this.cantidad = cantidad;
        this.precio_unitario = precio;
    }

    // Getters y Setters
    public long getId_compra_detalle() { return id_compra_detalle; }
    public void setId_compra_detalle(long id) { this.id_compra_detalle = id; }
    public int getId_compra() { return id_compra; }
    public void setId_compra(int id) { this.id_compra = id; }
    public int getId_producto() { return id_producto; }
    public void setId_producto(int id) { this.id_producto = id; }
    public int getCantidad() { return cantidad; }
    public void setCantidad(int c) { this.cantidad = c; }
    public double getPrecio_unitario() { return precio_unitario; }
    public void setPrecio_unitario(double p) { this.precio_unitario = p; }

    public boolean agregar() {
        String query = "INSERT INTO compras_detalle (id_compra, id_producto, cantidad, precio_unitario) VALUES (?, ?, ?, ?)";
        try (Connection con = cn.getConexion(); PreparedStatement ps = con.prepareStatement(query)) {
            ps.setInt(1, id_compra);
            ps.setInt(2, id_producto);
            ps.setInt(3, cantidad);
            ps.setDouble(4, precio_unitario);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.out.println("❌ Error al agregar detalle: " + e.getMessage());
            return false;
        }
    }

    public List<CompraDetalle> leerPorCompra(int idCompra) {
        List<CompraDetalle> lista = new ArrayList<>();
        String query = "SELECT * FROM compras_detalle WHERE id_compra=?";
        try (Connection con = cn.getConexion(); PreparedStatement ps = con.prepareStatement(query)) {
            ps.setInt(1, idCompra);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                lista.add(new CompraDetalle(
                    rs.getLong("id_compra_detalle"),
                    rs.getInt("id_compra"),
                    rs.getInt("id_producto"),
                    rs.getInt("cantidad"),
                    rs.getDouble("precio_unitario")
                ));
            }
        } catch (SQLException e) {
            System.out.println("❌ Error al leer detalles: " + e.getMessage());
        }
        return lista;
    }
}
