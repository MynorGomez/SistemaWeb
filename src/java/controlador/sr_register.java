package controlador;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;
import java.net.*;
import org.json.JSONObject;

@WebServlet(name = "sr_register", urlPatterns = {"/sr_register"})
public class sr_register extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 📥 Obtener datos del formulario JSP
        String usuario = request.getParameter("usuario");
        String clave = request.getParameter("clave");
        String nombre = request.getParameter("nombre");
        String rol = request.getParameter("rol");

        // 🧩 URL de tu API AuthJWT
        String apiUrl = "http://18.118.129.255:5119/api/Auth/register";

        // 📦 Crear JSON para enviar al API
        JSONObject jsonBody = new JSONObject();
        jsonBody.put("usuario", usuario);
        jsonBody.put("clave", clave);
        jsonBody.put("nombre", nombre);
        jsonBody.put("rol", rol != null ? rol : "empleado");

        try {
            // ⚙️ Conexión HTTP al API
            HttpURLConnection con = (HttpURLConnection) new URL(apiUrl).openConnection();
            con.setRequestMethod("POST");
            con.setRequestProperty("Content-Type", "application/json; utf-8");
            con.setRequestProperty("Accept", "application/json");
            con.setDoOutput(true);

            // 📨 Enviar JSON al API
            try (OutputStream os = con.getOutputStream()) {
                byte[] input = jsonBody.toString().getBytes("utf-8");
                os.write(input, 0, input.length);
            }

            // 📤 Leer código de respuesta
            int code = con.getResponseCode();

            if (code == 200 || code == 201) {
                // ✅ Registro exitoso
                StringBuilder responseStr = new StringBuilder();
                try (BufferedReader br = new BufferedReader(
                        new InputStreamReader(con.getInputStream(), "utf-8"))) {
                    String responseLine;
                    while ((responseLine = br.readLine()) != null) {
                        responseStr.append(responseLine.trim());
                    }
                }

                JSONObject jsonResponse = new JSONObject(responseStr.toString());
                String mensaje = jsonResponse.optString("message", "Cuenta creada correctamente");

                // 🔁 Redirigir al login con mensaje de éxito
                request.setAttribute("exito", mensaje);
                request.getRequestDispatcher("login.jsp").forward(request, response);

            } else if (code == 409) {
                // ⚠️ Usuario ya existe
                request.setAttribute("error", "El usuario ya existe. Intente con otro nombre.");
                request.getRequestDispatcher("register.jsp").forward(request, response);

            } else {
                // ❌ Error genérico
                request.setAttribute("error", "No se pudo crear la cuenta. Código: " + code);
                request.getRequestDispatcher("register.jsp").forward(request, response);
            }

        } catch (Exception e) {
            // ⚠️ Error de conexión o ejecución
            e.printStackTrace();
            request.setAttribute("error", "Error al conectar con el servidor: " + e.getMessage());
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }
}
