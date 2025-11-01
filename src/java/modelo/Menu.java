package modelo;

import java.sql.*;
import java.util.*;
import utils.ConexionDB;

public class Menu {
    private int id_menu;
    private String nombre;
    private String url;
    private Integer id_padre;

    ConexionDB cn = new ConexionDB();

    public Menu() {}
    public Menu(int id_menu, String nombre, String url, Integer id_padre) {
        this.id_menu = id_menu;
        this.nombre = nombre;
        this.url = url;
        this.id_padre = id_padre;
    }

    // Getters
    public int getId_menu() { return id_menu; }
    public String getNombre() { return nombre; }
    public String getUrl() { return url; }
    public Integer getId_padre() { return id_padre; }

    // Leer todos los menús
    public List<Menu> leer() {
        List<Menu> lista = new ArrayList<>();
        try (Connection con = cn.getConexion();
             PreparedStatement ps = con.prepareStatement("SELECT * FROM menus ORDER BY id_padre, nombre");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(new Menu(
                    rs.getInt("id_menu"),
                    rs.getString("nombre"),
                    rs.getString("url"),
                    rs.getObject("id_padre") != null ? rs.getInt("id_padre") : null
                ));
            }
        } catch (SQLException e) {
            System.err.println("❌ Error al leer menús: " + e.getMessage());
        }
        return lista;
    }
}
