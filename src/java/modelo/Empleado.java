package modelo;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import utils.ConexionDB;

public class Empleado {
    private int id_empleado;
    private String codigo, nombres, apellidos, direccion, telefono, fecha_nacimiento;
    private int id_puesto;
    private String puesto; // para mostrar el nombre en la vista
    private boolean genero;
    private String fecha_inicio_labores;
    private String fechaingreso;

    ConexionDB cn = new ConexionDB();

    // ======================================================
    // Constructores
    // ======================================================

    public Empleado() {}

    public Empleado(int id, String c, String n, String a, String d, String t, String f, 
                    int idp, String p, boolean g, String fil, String fi) {
        this.id_empleado = id;
        this.codigo = c;
        this.nombres = n;
        this.apellidos = a;
        this.direccion = d;
        this.telefono = t;
        this.fecha_nacimiento = f;
        this.id_puesto = idp;
        this.puesto = p;
        this.genero = g;
        this.fecha_inicio_labores = fil;
        this.fechaingreso = fi;
    }

    // ======================================================
    // Getters y Setters
    // ======================================================

    public int getId_empleado() { return id_empleado; }
    public void setId_empleado(int id_empleado) { this.id_empleado = id_empleado; }

    public String getCodigo() { return codigo; }
    public void setCodigo(String codigo) { this.codigo = codigo; }

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

    public int getId_puesto() { return id_puesto; }
    public void setId_puesto(int id_puesto) { this.id_puesto = id_puesto; }

    public String getPuesto() { return puesto; }
    public void setPuesto(String puesto) { this.puesto = puesto; }

    public boolean getGenero() { return genero; }
    public void setGenero(boolean genero) { this.genero = genero; }

    public String getFecha_inicio_labores() { return fecha_inicio_labores; }
    public void setFecha_inicio_labores(String fecha_inicio_labores) { this.fecha_inicio_labores = fecha_inicio_labores; }

    public String getFechaingreso() { return fechaingreso; }
    public void setFechaingreso(String fechaingreso) { this.fechaingreso = fechaingreso; }

    // ======================================================
    // CRUD
    // ======================================================

    public List<Empleado> leer() {
        List<Empleado> lista = new ArrayList<>();
        String sql = "SELECT e.id_empleado, e.codigo, e.nombres, e.apellidos, e.direccion, e.telefono, " +
                     "e.fecha_nacimiento, e.id_puesto, p.puesto, e.genero, e.fecha_inicio_labores, e.fechaingreso " +
                     "FROM empleados e INNER JOIN puestos p ON e.id_puesto = p.id_puesto;";
        try (Connection conn = cn.getConexion();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                lista.add(new Empleado(
                    rs.getInt("id_empleado"),
                    rs.getString("codigo"),
                    rs.getString("nombres"),
                    rs.getString("apellidos"),
                    rs.getString("direccion"),
                    rs.getString("telefono"),
                    rs.getString("fecha_nacimiento"),
                    rs.getInt("id_puesto"),
                    rs.getString("puesto"),
                    rs.getBoolean("genero"),
                    rs.getString("fecha_inicio_labores"),
                    rs.getString("fechaingreso")
                ));
            }
        } catch (SQLException e) {
            System.err.println("❌ Error al leer empleados: " + e.getMessage());
        }
        return lista;
    }

    public boolean agregar() {
        String sql = "INSERT INTO empleados (codigo, nombres, apellidos, direccion, telefono, fecha_nacimiento, id_puesto, genero, fecha_inicio_labores, fechaingreso) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW());";
        try (Connection conn = cn.getConexion();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, codigo);
            ps.setString(2, nombres);
            ps.setString(3, apellidos);
            ps.setString(4, direccion);
            ps.setString(5, telefono);
            ps.setString(6, fecha_nacimiento);
            ps.setInt(7, id_puesto);
            ps.setBoolean(8, genero);
            ps.setString(9, fecha_inicio_labores);

            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.err.println("❌ Error al agregar empleado: " + e.getMessage());
            return false;
        }
    }

    public boolean actualizar() {
        String sql = "UPDATE empleados SET codigo=?, nombres=?, apellidos=?, direccion=?, telefono=?, fecha_nacimiento=?, " +
                     "id_puesto=?, genero=?, fecha_inicio_labores=? WHERE id_empleado=?;";
        try (Connection conn = cn.getConexion();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, codigo);
            ps.setString(2, nombres);
            ps.setString(3, apellidos);
            ps.setString(4, direccion);
            ps.setString(5, telefono);
            ps.setString(6, fecha_nacimiento);
            ps.setInt(7, id_puesto);
            ps.setBoolean(8, genero);
            ps.setString(9, fecha_inicio_labores);
            ps.setInt(10, id_empleado);

            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.err.println("❌ Error al actualizar empleado: " + e.getMessage());
            return false;
        }
    }

    public boolean eliminar() {
        String sql = "DELETE FROM empleados WHERE id_empleado=?;";
        try (Connection conn = cn.getConexion();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id_empleado);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.err.println("❌ Error al eliminar empleado: " + e.getMessage());
            return false;
        }
    }
}
