package modelo;

import java.sql.*;
import java.util.*;
import utils.ConexionDB;

public class Menu {
    private int id_menu;
    private String nombre;
    private String url;
    private Integer id_padre;

    // ✅ Getters y setters
    public int getId_menu() { return id_menu; }
    public void setId_menu(int id_menu) { this.id_menu = id_menu; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getUrl() { return url; }
    public void setUrl(String url) { this.url = url; }

    public Integer getId_padre() { return id_padre; }
    public void setId_padre(Integer id_padre) { this.id_padre = id_padre; }

    // ✅ Método para leer todos los menús
    public List<Menu> leer() {
        List<Menu> lista = new ArrayList<>();
        ConexionDB cn = new ConexionDB();

        try (Connection con = cn.getConexion()) {
            String query = "SELECT id_menu, nombre, url, id_padre FROM menus ORDER BY id_padre, id_menu";
            PreparedStatement ps = con.prepareStatement(query);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Menu m = new Menu();
                m.setId_menu(rs.getInt("id_menu"));
                m.setNombre(rs.getString("nombre"));
                m.setUrl(rs.getString("url"));
                m.setId_padre(rs.getObject("id_padre") != null ? rs.getInt("id_padre") : null);
                lista.add(m);
            }

            System.out.println("✅ Se cargaron " + lista.size() + " menús desde la base de datos.");

        } catch (SQLException e) {
            System.err.println("❌ Error en Menu.leer(): " + e.getMessage());
        }

        return lista;
    }
}
