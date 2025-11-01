package modelo;

import java.sql.*;
import java.util.*;
import utils.ConexionDB;

public class Producto {

    private int id_producto;
    private String producto;
    private int id_marca;
    private String descripcion;
    private String imagen_url; // Ruta relativa (assets/img/productos/...)
    private double precio_costo;
    private double precio_venta;
    private int existencia;
    private String marca; // Nombre de la marca
    private ConexionDB cn;

    // 🔹 Constructor
    public Producto() {
        cn = new ConexionDB();
    }

    // 🔹 Constructor con parámetros
    public Producto(int id_producto, String producto, int id_marca, String descripcion, String imagen_url,
                    double precio_costo, double precio_venta, int existencia, String marca) {
        this.id_producto = id_producto;
        this.producto = producto;
        this.id_marca = id_marca;
        this.descripcion = descripcion;
        this.imagen_url = imagen_url;
        this.precio_costo = precio_costo;
        this.precio_venta = precio_venta;
        this.existencia = existencia;
        this.marca = marca;
        this.cn = new ConexionDB();
    }

    // ==========================================================
    // Getters y Setters
    // ==========================================================
    public int getId_producto() { return id_producto; }
    public void setId_producto(int id_producto) { this.id_producto = id_producto; }

    public String getProducto() { return producto; }
    public void setProducto(String producto) { this.producto = producto; }

    public int getId_marca() { return id_marca; }
    public void setId_marca(int id_marca) { this.id_marca = id_marca; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public String getImagen_url() { return imagen_url; }
    public void setImagen_url(String imagen_url) { this.imagen_url = imagen_url; }

    public double getPrecio_costo() { return precio_costo; }
    public void setPrecio_costo(double precio_costo) { this.precio_costo = precio_costo; }

    public double getPrecio_venta() { return precio_venta; }
    public void setPrecio_venta(double precio_venta) { this.precio_venta = precio_venta; }

    public int getExistencia() { return existencia; }
    public void setExistencia(int existencia) { this.existencia = existencia; }

    public String getMarca() { return marca; }
    public void setMarca(String marca) { this.marca = marca; }

    // ==========================================================
    // MÉTODOS CRUD
    // ==========================================================

    /** 🔹 INSERTAR PRODUCTO */
    public HashMap<String, String> insertar() {
        HashMap<String, String> resultado = new HashMap<>();
        try {
            String sql = "INSERT INTO productos " +
                    "(producto, id_marca, descripcion, imagen_url, precio_costo, precio_venta, existencia) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement ps = cn.getConexion().prepareStatement(sql);
            ps.setString(1, getProducto());
            ps.setInt(2, getId_marca());
            ps.setString(3, getDescripcion());
            ps.setString(4, getImagen_url());
            ps.setDouble(5, getPrecio_costo());
            ps.setDouble(6, getPrecio_venta());
            ps.setInt(7, getExistencia());
            ps.executeUpdate();

            resultado.put("resultado", "1");
            resultado.put("mensaje", "Producto agregado correctamente");
        } catch (SQLException e) {
            resultado.put("resultado", "0");
            resultado.put("mensaje", "Error al insertar producto: " + e.getMessage());
        }
        return resultado;
    }

    /** 🔹 ACTUALIZAR PRODUCTO */
    public HashMap<String, String> actualizar() {
        HashMap<String, String> resultado = new HashMap<>();
        try {
            String sql = "UPDATE productos SET producto=?, id_marca=?, descripcion=?, imagen_url=?, " +
                    "precio_costo=?, precio_venta=?, existencia=? WHERE id_producto=?";
            PreparedStatement ps = cn.getConexion().prepareStatement(sql);
            ps.setString(1, getProducto());
            ps.setInt(2, getId_marca());
            ps.setString(3, getDescripcion());
            ps.setString(4, getImagen_url());
            ps.setDouble(5, getPrecio_costo());
            ps.setDouble(6, getPrecio_venta());
            ps.setInt(7, getExistencia());
            ps.setInt(8, getId_producto());
            ps.executeUpdate();

            resultado.put("resultado", "1");
            resultado.put("mensaje", "Producto actualizado correctamente");
        } catch (SQLException e) {
            resultado.put("resultado", "0");
            resultado.put("mensaje", "Error al actualizar producto: " + e.getMessage());
        }
        return resultado;
    }

    /** 🔹 ELIMINAR PRODUCTO */
    public HashMap<String, String> eliminar() {
        HashMap<String, String> resultado = new HashMap<>();
        try {
            String sql = "DELETE FROM productos WHERE id_producto=?";
            PreparedStatement ps = cn.getConexion().prepareStatement(sql);
            ps.setInt(1, getId_producto());
            ps.executeUpdate();

            resultado.put("resultado", "1");
            resultado.put("mensaje", "Producto eliminado correctamente");
        } catch (SQLException e) {
            resultado.put("resultado", "0");
            resultado.put("mensaje", "Error al eliminar producto: " + e.getMessage());
        }
        return resultado;
    }

    /** 🔹 LEER TODOS LOS PRODUCTOS */
    public List<Producto> leer() {
    List<Producto> lista = new ArrayList<>();
    try {
        String sql = "SELECT p.*, m.marca FROM productos p " +
                     "LEFT JOIN marcas m ON p.id_marca = m.id_marca " +
                     "ORDER BY p.id_producto";
        Statement st = cn.getConexion().createStatement();
        ResultSet rs = st.executeQuery(sql);

        while (rs.next()) {
            Producto prod = new Producto();
            prod.setId_producto(rs.getInt("id_producto"));
            prod.setProducto(rs.getString("producto"));
            prod.setId_marca(rs.getInt("id_marca"));
            prod.setDescripcion(rs.getString("descripcion"));
            prod.setPrecio_costo(rs.getDouble("precio_costo"));
            prod.setPrecio_venta(rs.getDouble("precio_venta"));
            prod.setExistencia(rs.getInt("existencia"));
            prod.setMarca(rs.getString("marca"));

            // 🔸 Obtener ruta de imagen y asegurar accesibilidad
            String img = rs.getString("imagen_url");
            if (img != null && !img.isEmpty()) {
                // Si ya viene con "assets/img", usarla directo
                if (img.startsWith("assets/") || img.startsWith("../assets/")) {
                    prod.setImagen_url(img.replace("\\", "/"));
                } else {
                    // Caso contrario, agregar el prefijo correcto
                    prod.setImagen_url("assets/img/productos/" + img.replace("\\", "/"));
                }
            } else {
                // Si no hay imagen, ruta a una imagen genérica
                prod.setImagen_url("assets/img/productos/no-image.png");
            }

            lista.add(prod);
        }

        rs.close();
        st.close();
    } catch (SQLException e) {
        System.out.println("Error al leer productos: " + e.getMessage());
    }
    return lista;
}
}