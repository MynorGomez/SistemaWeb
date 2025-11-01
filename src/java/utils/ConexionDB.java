package utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConexionDB {
    private static final String URL = "jdbc:mysql://127.0.0.1:3306/db_empresa";
    private static final String USER = "root";
    private static final String PASSWORD = "Minato15@"; // ⚠️ cambia si tu contraseña es diferente
    // No mantenemos una Connection en campo. Creamos y retornamos una nueva conexión por llamada.
        public ConexionDB() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            System.err.println("❌ Error: No se encontró el driver MySQL JDBC.");
        }
    }

    public Connection getConexion() throws SQLException {
        // Cada llamada crea y devuelve una nueva conexión. El llamador es responsable de cerrarla.
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    // Helper opcional para cerrar conexiones de forma segura
    public static void cerrar(Connection c) {
        if (c != null) {
            try {
                if (!c.isClosed()) c.close();
            } catch (SQLException e) {
                System.err.println("⚠️ Error al cerrar conexión: " + e.getMessage());
            }
        }
    }
}
