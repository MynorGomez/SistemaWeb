package modelo;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import utils.ConexionDB;

public class Proveedor {
    private int id_proveedor;
    private String proveedor, nit, direccion, telefono;

    ConexionDB cn = new ConexionDB();

    // Constructores
    public Proveedor() {}
    public Proveedor(int id, String prov, String n, String dir, String tel) {
        this.id_proveedor = id;
        this.proveedor = prov;
        this.nit = n;
        this.direccion = dir;
        this.telefono = tel;
    }

    // Getters y setters
    public int getId_proveedor() { return id_proveedor; }
    public void setId_proveedor(int id) { id_proveedor = id; }
    public String getProveedor() { return proveedor; }
    public void setProveedor(String p) { proveedor = p; }
    public String getNit() { return nit; }
    public void setNit(String n) { nit = n; }
    public String getDireccion() { return direccion; }
    public void setDireccion(String d) { direccion = d; }
    public String getTelefono() { return telefono; }
    public void setTelefono(String t) { telefono = t; }

    // ======================================================
    // CRUD
    // ======================================================

    public List<Proveedor> leer() {
        List<Proveedor> lista = new ArrayList<>();
        try {
            Connection conn = cn.getConexion();
            String query = "SELECT * FROM proveedores;";
            PreparedStatement ps = conn.prepareStatement(query);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                lista.add(new Proveedor(
                    rs.getInt("id_proveedor"),
                    rs.getString("proveedor"),
                    rs.getString("nit"),
                    rs.getString("direccion"),
                    rs.getString("telefono")
                ));
            }
        } catch (SQLException e) {
            System.err.println("❌ Error al leer proveedores: " + e.getMessage());
        }
        return lista;
    }

    public boolean agregar() {
        try {
            Connection conn = cn.getConexion();
            String query = "INSERT INTO proveedores (proveedor, nit, direccion, telefono) VALUES (?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setString(1, proveedor);
            ps.setString(2, nit);
            ps.setString(3, direccion);
            ps.setString(4, telefono);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.err.println("❌ Error al agregar proveedor: " + e.getMessage());
            return false;
        }
    }

    public boolean actualizar() {
        try {
            Connection conn = cn.getConexion();
            String query = "UPDATE proveedores SET proveedor=?, nit=?, direccion=?, telefono=? WHERE id_proveedor=?";
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setString(1, proveedor);
            ps.setString(2, nit);
            ps.setString(3, direccion);
            ps.setString(4, telefono);
            ps.setInt(5, id_proveedor);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.err.println("❌ Error al actualizar proveedor: " + e.getMessage());
            return false;
        }
    }

    public boolean eliminar() {
        try {
            Connection conn = cn.getConexion();
            String query = "DELETE FROM proveedores WHERE id_proveedor=?";
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setInt(1, id_proveedor);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.err.println("❌ Error al eliminar proveedor: " + e.getMessage());
            return false;
        }
    }
}
