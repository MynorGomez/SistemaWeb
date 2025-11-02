    <%@ page contentType="text/html;charset=UTF-8" %>
    <!DOCTYPE html>
    <html lang="es">
    <head>
      <meta charset="UTF-8">
      <title>Crear Cuenta - Sistema</title>
      <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
      <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

      <style>
        body {
          font-family: 'Poppins', sans-serif;
          background: url("assets/img/login/a.jpg") no-repeat center center fixed;
          background-size: cover;
          min-height: 100vh;
          display: flex;
          align-items: center;
          justify-content: center;
          margin: 0;
        }

        body::before {
          content: "";
          position: fixed;
          inset: 0;
          background: rgba(0,0,0,0.55);
          z-index: 0;
        }

        .register-card {
          position: relative;
          z-index: 1;
          width: 100%;
          max-width: 400px;
          background: rgba(255, 255, 255, 0.92);
          border-radius: 20px;
          box-shadow: 0 8px 25px rgba(0,0,0,0.3);
          padding: 2rem 1.5rem;
          text-align: center;
          backdrop-filter: blur(8px);
          animation: fadeIn 1s ease;
          margin: 1rem;
        }

        @keyframes fadeIn {
          from { opacity: 0; transform: translateY(20px); }
          to { opacity: 1; transform: translateY(0); }
        }

        .rocket {
          width: 90px;
          max-width: 25%;
          margin-bottom: 1rem;
          animation: float 3s ease-in-out infinite;
          filter: drop-shadow(0 0 10px #00f2fe);
          transition: transform 1s ease-in-out;
        }

        @keyframes float {
          0% { transform: translateY(0); }
          50% { transform: translateY(-10px); }
          100% { transform: translateY(0); }
        }

        .launch {
          animation: launch 1.2s ease-in forwards;
        }

        @keyframes launch {
          0% { transform: translateY(0) scale(1); opacity: 1; }
          30% { transform: translateY(-40px) scale(1.1); }
          60% { transform: translateY(-200px) scale(0.9); opacity: 0.9; }
          100% { transform: translateY(-600px) scale(0.6); opacity: 0; }
        }

        .form-control {
          border-radius: 25px;
          border: 2px solid #ccd1ff;
          padding: 10px 15px;
          margin-bottom: 1rem;
          transition: all 0.3s ease;
        }

        .form-control:focus {
          border-color: #5271ff;
          box-shadow: 0 0 8px rgba(82,113,255,0.3);
        }

        .btn-register {
          width: 100%;
          border-radius: 25px;
          background-color: #5271ff;
          color: #fff;
          border: none;
          padding: 10px;
          font-weight: 600;
          transition: 0.3s ease;
        }

        .btn-register:hover {
          background-color: #4158d0;
          transform: scale(1.03);
        }

        a {
          color: #5271ff;
          text-decoration: none;
          font-size: 0.9rem;
        }

        a:hover {
          text-decoration: underline;
        }

        #msg {
          text-align: center;
          font-size: 0.9rem;
          margin-top: 10px;
        }

        /* 📱 Responsive ajustes pequeños */
        @media (max-width: 480px) {
          .register-card {
            padding: 1.5rem 1rem;
          }
          .rocket {
            width: 70px;
          }
          h3 {
            font-size: 1.2rem;
          }
        }
      </style>
    </head>

    <body>
      <div class="register-card">
        <img src="assets/img/login/cohete.png" alt="Rocket" class="rocket" id="rocket">
        <h3>Crear Cuenta</h3>
        <div id="msg"></div>

        <form id="registerForm">
          <input type="text" name="nombre" class="form-control" placeholder="Nombre completo" required>
          <input type="text" name="usuario" class="form-control" placeholder="Usuario" required>
          <input type="email" name="email" class="form-control" placeholder="Correo electrónico" required>
          <input type="password" name="clave" class="form-control" placeholder="Contraseña" required>
          <select name="rol" class="form-control" required>
            <option value="">Selecciona un rol...</option>
            <option value="admin">Administrador</option>
            <option value="empleado" selected>Empleado</option>
            <option value="invitado">Invitado</option>
          </select>
          <button type="submit" class="btn-register mt-3">Registrar</button>
        </form>

        <div class="mt-3">
          <a href="login.jsp">¿Ya tienes cuenta? Inicia sesión</a>
        </div>
      </div>
<script>
$("#registerForm").submit(async function(e){
  e.preventDefault();
  const rocket = document.getElementById("rocket");
  $("#msg").html("<div class='text-muted'>Creando cuenta...</div>");

  const data = {
    nombre: $("[name='nombre']").val().trim(),
    usuario: $("[name='usuario']").val().trim(),
    email: $("[name='email']").val().trim(),
    clave: $("[name='clave']").val().trim(),
    rol: $("[name='rol']").val()
  };

  // Validar campos antes de enviar
  if (!data.nombre || !data.usuario || !data.email || !data.clave) {
    $("#msg").html("<div class='alert alert-warning mt-3'>Por favor completa todos los campos.</div>");
    return;
  }

  try {
    const res = await fetch("http://18.118.129.255:5119/api/Auth/register", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(data)
    });

    // Si el API devuelve error
    if (!res.ok) {
      if (res.status === 409) {
        $("#msg").html("<div class='alert alert-warning mt-3'>El usuario ya existe ⚠️</div>");
      } else {
        $("#msg").html("<div class='alert alert-danger mt-3'>Error en el registro (código: " + res.status + ")</div>");
      }
      return;
    }

    // Convertir respuesta a JSON
    const json = await res.json();

    // Si todo salió bien
    if (json.success || json.message) {
      rocket.classList.add("launch");
      $("#msg").html("<div class='text-success mt-2'>Cuenta creada correctamente 🚀</div>");
      setTimeout(() => { window.location = "login.jsp"; }, 1500);
    } else {
      $("#msg").html("<div class='alert alert-danger mt-3 text-center'>No se pudo crear la cuenta</div>");
    }
  } catch (error) {
    console.error(error);
    $("#msg").html("<div class='alert alert-danger mt-3 text-center'>Error al conectar con el servidor 😢</div>");
  }
});
</script>

    </body>
    </html>
