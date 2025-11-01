package modelo;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import utils.ConexionDB;

public class Cliente {
    private int id_cliente;
    private String nit, nombres, apellidos, direccion, telefono, fecha_nacimiento;
    private String correo_electronico;
    private boolean genero;
    private String fechaingreso;

    ConexionDB cn = new ConexionDB();

    // ======================================================
    // Constructores
    // ======================================================

    public Cliente() {}

    public Cliente(int id, String n, String nom, String ape, String dir, String tel,
                   String fn, String correo, boolean gen, String fing) {
        this.id_cliente = id;
        this.nit = n;
        this.nombres = nom;
        this.apellidos = ape;
        this.direccion = dir;
        this.telefono = tel;
        this.fecha_nacimiento = fn;
        this.correo_electronico = correo;
        this.genero = gen;
        this.fechaingreso = fing;
    }

    // ======================================================
    // Getters y Setters
    // ======================================================

    public int getId_cliente() { return id_cliente; }
    public void setId_cliente(int id_cliente) { this.id_cliente = id_cliente; }

    public String getNit() { return nit; }
    public void setNit(String nit) { this.nit = nit; }

    public String getNombres() { return nombres; }
    public void setNombres(String nombres) { this.nombres = nombres; }

    public String getApellidos() { return apellidos; }
    public void setApellidos(String apellidos) { this.apellidos = apellidos; }

    public String getDireccion() { return direccion; }
    public void setDireccion(String direccion) { this.direccion = direccion; }

    public String getTelefono() { return telefono; }
    public void setTelefono(String telefono) { this.telefono = telefono; }

    public String getFecha_nacimiento() { return fecha_nacimiento; }
    public void setFecha_nacimiento(String fecha_nacimiento) { this.fecha_nacimiento = fecha_nacimiento; }

    public String getCorreo_electronico() { return correo_electronico; }
    public void setCorreo_electronico(String correo_electronico) { this.correo_electronico = correo_electronico; }

    public boolean getGenero() { return genero; }
    public void setGenero(boolean genero) { this.genero = genero; }

    public String getFechaingreso() { return fechaingreso; }
    public void setFechaingreso(String fechaingreso) { this.fechaingreso = fechaingreso; }

    // ======================================================
    // CRUD
    // ======================================================

    public List<Cliente> leer() {
        List<Cliente> lista = new ArrayList<>();
        try (Connection conn = cn.getConexion();
             PreparedStatement ps = conn.prepareStatement("SELECT * FROM clientes;");
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                lista.add(new Cliente(
                    rs.getInt("id_cliente"),
                    rs.getString("nit"),
                    rs.getString("nombres"),
                    rs.getString("apellidos"),
                    rs.getString("direccion"),
                    rs.getString("telefono"),
                    rs.getString("fecha_nacimiento"),
                    rs.getString("correo_electronico"),
                    rs.getBoolean("genero"),
                    rs.getString("fechaingreso")
                ));
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al leer clientes: " + e.getMessage());
        }
        return lista;
    }

    public boolean agregar() {
        try (Connection conn = cn.getConexion();
             PreparedStatement ps = conn.prepareStatement(
                 "INSERT INTO clientes (nit, nombres, apellidos, direccion, telefono, fecha_nacimiento, correo_electronico, genero, fechaingreso) " +
                 "VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW());")) {

            ps.setString(1, nit);
            ps.setString(2, nombres);
            ps.setString(3, apellidos);
            ps.setString(4, direccion);
            ps.setString(5, telefono);
            ps.setString(6, fecha_nacimiento);
            ps.setString(7, correo_electronico);
            ps.setBoolean(8, genero);

            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.err.println("❌ Error al agregar cliente: " + e.getMessage());
            return false;
        }
    }

    public boolean actualizar() {
        try (Connection conn = cn.getConexion();
             PreparedStatement ps = conn.prepareStatement(
                 "UPDATE clientes SET nit=?, nombres=?, apellidos=?, direccion=?, telefono=?, fecha_nacimiento=?, correo_electronico=?, genero=? WHERE id_cliente=?;")) {

            ps.setString(1, nit);
            ps.setString(2, nombres);
            ps.setString(3, apellidos);
            ps.setString(4, direccion);
            ps.setString(5, telefono);
            ps.setString(6, fecha_nacimiento);
            ps.setString(7, correo_electronico);
            ps.setBoolean(8, genero);
            ps.setInt(9, id_cliente);

            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.err.println("❌ Error al actualizar cliente: " + e.getMessage());
            return false;
        }
    }

    public boolean eliminar() {
        try (Connection conn = cn.getConexion();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM clientes WHERE id_cliente=?;")) {

            ps.setInt(1, id_cliente);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.err.println("❌ Error al eliminar cliente: " + e.getMessage());
            return false;
        }
    }
}
