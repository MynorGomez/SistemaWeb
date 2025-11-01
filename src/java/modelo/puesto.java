package modelo;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.sql.PreparedStatement;
import java.sql.Connection;
import utils.ConexionDB;

public class Puesto {
    private int id_puesto;
    private String puesto;

    ConexionDB cn = new ConexionDB();

    // Constructores
    public Puesto() {}
    public Puesto(int id_puesto, String puesto) {
        this.id_puesto = id_puesto;
        this.puesto = puesto;
    }

    // Getters y setters
    public int getId_puesto() { return id_puesto; }
    public void setId_puesto(int id_puesto) { this.id_puesto = id_puesto; }
    public String getPuesto() { return puesto; }
    public void setPuesto(String puesto) { this.puesto = puesto; }

    // ======================================================
    // CRUD
    // ======================================================

    public List<Puesto> leer() {
        List<Puesto> lista = new ArrayList<>();
        try {
            Connection conn = cn.getConexion();
            String query = "SELECT * FROM puestos;";
            PreparedStatement ps = conn.prepareStatement(query);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                lista.add(new Puesto(
                    rs.getInt("id_puesto"),
                    rs.getString("puesto")
                ));
            }
            rs.close();
            ps.close();
        } catch (SQLException e) {
            System.err.println("❌ Error al leer puestos: " + e.getMessage());
        }
        return lista;
    }

    public boolean agregar() {
        try {
            Connection conn = cn.getConexion();
            String query = "INSERT INTO puestos (puesto) VALUES (?);";
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setString(1, this.puesto);
            ps.executeUpdate();
            ps.close();
            return true;
        } catch (SQLException e) {
            System.err.println("❌ Error al agregar puesto: " + e.getMessage());
            return false;
        }
    }

    public boolean actualizar() {
        try {
            Connection conn = cn.getConexion();
            String query = "UPDATE puestos SET puesto=? WHERE id_puesto=?;";
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setString(1, this.puesto);
            ps.setInt(2, this.id_puesto);
            ps.executeUpdate();
            ps.close();
            return true;
        } catch (SQLException e) {
            System.err.println("❌ Error al actualizar puesto: " + e.getMessage());
            return false;
        }
    }

    public boolean eliminar() {
        try {
            Connection conn = cn.getConexion();
            String query = "DELETE FROM puestos WHERE id_puesto=?;";
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setInt(1, this.id_puesto);
            ps.executeUpdate();
            ps.close();
            return true;
        } catch (SQLException e) {
            System.err.println("❌ Error al eliminar puesto: " + e.getMessage());
            return false;
        }
    }
}
