package utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConexionDB {
    private Connection conexion;

    // ✅ URL con parámetros recomendados
    private final String url = "jdbc:mysql://127.0.0.1:3306/db_empresa?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    private final String usuario = "root";
    private final String clave = "Minato2025@";
    private final String driver = "com.mysql.cj.jdbc.Driver";

    public ConexionDB() {
        try {
            Class.forName(driver);
            conexion = DriverManager.getConnection(url, usuario, clave);
            System.out.println("✅ Conexión a MySQL exitosa.");
        } catch (ClassNotFoundException | SQLException e) {
            System.err.println("❌ Error de conexión a MySQL: " + e.getMessage());
        }
    }

    public Connection getConexion() {
        return conexion;
    }

    public void cerrarConexion() {
        try {
            if (conexion != null && !conexion.isClosed()) {
                conexion.close();
                System.out.println("🔒 Conexión cerrada correctamente.");
            }
        } catch (SQLException e) {
            System.err.println("❌ Error al cerrar conexión: " + e.getMessage());
        }
    }
}
