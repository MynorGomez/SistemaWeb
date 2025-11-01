package modelo;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import utils.ConexionDB;

public class Compra {
    private int id_compra;
    private int negorden_compra;
    private int id_proveedor;
    private Date fecha_gridem;
    private Timestamp fecha_ingreso;
    private String proveedor;

    ConexionDB cn = new ConexionDB();

    public Compra() {}

    public Compra(int id, int orden, int idProv, Date gridem, Timestamp ingreso, String prov) {
        this.id_compra = id;
        this.negorden_compra = orden;
        this.id_proveedor = idProv;
        this.fecha_gridem = gridem;
        this.fecha_ingreso = ingreso;
        this.proveedor = prov;
    }

    // Getters y setters
    public int getId_compra() { return id_compra; }
    public void setId_compra(int id) { this.id_compra = id; }

    public int getNegorden_compra() { return negorden_compra; }
    public void setNegorden_compra(int orden) { this.negorden_compra = orden; }

    public int getId_proveedor() { return id_proveedor; }
    public void setId_proveedor(int idProv) { this.id_proveedor = idProv; }

    public Date getFecha_gridem() { return fecha_gridem; }
    public void setFecha_gridem(Date f) { this.fecha_gridem = f; }

    public Timestamp getFecha_ingreso() { return fecha_ingreso; }
    public void setFecha_ingreso(Timestamp f) { this.fecha_ingreso = f; }

    public String getProveedor() { return proveedor; }
    public void setProveedor(String p) { this.proveedor = p; }

    // ======================================================
    // CRUD
    // ======================================================
    public boolean agregar() {
        String query = "INSERT INTO compras (negorden_compra, id_proveedor, fecha_gridem, fecha_ingreso) VALUES (?, ?, ?, ?)";
        try (Connection con = cn.getConexion(); PreparedStatement ps = con.prepareStatement(query)) {
            ps.setInt(1, negorden_compra);
            ps.setInt(2, id_proveedor);
            ps.setDate(3, fecha_gridem);
            ps.setTimestamp(4, fecha_ingreso);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.out.println("❌ Error al agregar compra: " + e.getMessage());
            return false;
        }
    }

    public List<Compra> leer() {
        List<Compra> lista = new ArrayList<>();
        
        String query = "SELECT c.id_compra, c.negorden_compra, c.id_proveedor, " +
                      "c.fecha_gridem, c.fecha_ingreso, p.proveedor " +
                      "FROM compras c " +
                      "INNER JOIN proveedores p ON c.id_proveedor = p.id_proveedor";
                      
        try (Connection con = cn.getConexion(); PreparedStatement ps = con.prepareStatement(query)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                lista.add(new Compra(
                    rs.getInt("id_compra"),
                    rs.getInt("negorden_compra"),
                    rs.getInt("id_proveedor"),
                    rs.getDate("fecha_gridem"),
                    rs.getTimestamp("fecha_ingreso"),
                    rs.getString("proveedor")
                ));
            }
        } catch (SQLException e) {
            System.out.println("❌ Error al leer compras: " + e.getMessage());
        }
        return lista;
    }
}
