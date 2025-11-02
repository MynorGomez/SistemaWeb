package controlador;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;
import java.net.*;
import org.json.JSONObject;

@WebServlet(name = "sr_login", urlPatterns = {"/sr_login"})
public class sr_login extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String usuario = request.getParameter("usuario");
        String clave = request.getParameter("clave");

        // 🧩 URL del endpoint de login en tu API .NET
        String apiUrl = "http://18.118.129.255:5119/api/Auth/login";

        // 📦 Crear el JSON de envío
        JSONObject jsonBody = new JSONObject();
        jsonBody.put("usuario", usuario);
        jsonBody.put("clave", clave);

        // ⚙️ Conexión HTTP a la API
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

        int code = con.getResponseCode();

        if (code == 200) {
            // 📥 Leer respuesta del API
            StringBuilder responseStr = new StringBuilder();
            try (BufferedReader br = new BufferedReader(
                    new InputStreamReader(con.getInputStream(), "utf-8"))) {
                String responseLine;
                while ((responseLine = br.readLine()) != null) {
                    responseStr.append(responseLine.trim());
                }
            }

            // 🔍 Convertir respuesta a JSON
            JSONObject jsonResponse = new JSONObject(responseStr.toString());

            // ✅ Extraer datos
            String token = jsonResponse.getString("token");
            String nombre = jsonResponse.optString("nombre", usuario);
            String rol = jsonResponse.optString("rol", "empleado");

            // 🧠 Crear sesión
            HttpSession sesion = request.getSession();
            sesion.setAttribute("jwt", token);
            sesion.setAttribute("usuario", usuario);
            sesion.setAttribute("nombre", nombre);
            sesion.setAttribute("rol", rol);
            sesion.setMaxInactiveInterval(30 * 60);

            // 🔁 Redirigir al panel principal
            response.sendRedirect("views/index.jsp");

        } else {
            // ❌ Error (usuario o contraseña incorrectos)
            request.setAttribute("error", "Credenciales inválidas o servidor no disponible.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}
