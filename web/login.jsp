<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Login - Sistema</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

  <style>
    body {
      font-family: 'Poppins', sans-serif;
      background: url("assets/img/login/ga.jpg") no-repeat center center fixed;
      background-size: cover;
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      margin: 0;
      overflow: hidden;
    }

    body::before {
      content: "";
      position: absolute;
      top: 0; left: 0; right: 0; bottom: 0;
      background: rgba(0,0,0,0.55);
      z-index: 0;
    }

    .login-card {
      position: relative;
      z-index: 1;
      width: 340px;
      background: rgba(255, 255, 255, 0.92);
      border-radius: 20px;
      box-shadow: 0 8px 25px rgba(0,0,0,0.3);
      padding: 2rem;
      text-align: center;
      backdrop-filter: blur(8px);
      animation: fadeIn 1s ease;
    }

    @keyframes fadeIn {
      from { opacity: 0; transform: translateY(20px); }
      to { opacity: 1; transform: translateY(0); }
    }

    .rocket {
      width: 100px;
      margin-bottom: 15px;
      animation: float 3s ease-in-out infinite;
      filter: drop-shadow(0 0 10px #00f2fe);
      transition: transform 1s ease-in-out;
    }

    @keyframes float {
      0% { transform: translateY(0); }
      50% { transform: translateY(-12px); }
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

    h3 {
      font-weight: 600;
      color: #333;
      margin-bottom: 1.5rem;
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

    .btn-login {
      width: 100%;
      border-radius: 25px;
      background-color: #5271ff;
      color: #fff;
      border: none;
      padding: 10px;
      font-weight: 600;
      transition: 0.3s ease;
    }

    .btn-login:hover {
      background-color: #4158d0;
      transform: scale(1.03);
    }

    .btn-create {
      width: 100%;
      border-radius: 25px;
      background-color: transparent;
      color: #5271ff;
      border: 2px solid #5271ff;
      padding: 10px;
      font-weight: 600;
      transition: 0.3s ease;
    }

    .btn-create:hover {
      background-color: #5271ff;
      color: #fff;
      transform: scale(1.03);
    }

    #msg {
      text-align: center;
      font-size: 0.9rem;
      margin-top: 10px;
    }
  </style>
</head>

<body>
  <div class="login-card">
    <!-- 🚀 Cohete -->
    <img src="assets/img/login/cohete.png" alt="Rocket" class="rocket" id="rocket">

    <h3>Iniciar Sesión</h3>
    <div id="msg"></div>

    <form id="loginForm">
      <input type="text" name="usuario" class="form-control" placeholder="Usuario" required>
      <input type="password" name="clave" class="form-control" placeholder="Contraseña" required>
      <button type="submit" class="btn-login">Entrar</button>
    </form>

    <div class="mt-3">
      <button type="button" class="btn-create" onclick="window.location='register.jsp'">
        Crear Cuenta
      </button>
    </div>
  </div>

  <script>
  $("#loginForm").submit(async function(e){
    e.preventDefault();
    const rocket = document.getElementById("rocket");
    $("#msg").html("<div class='text-muted'>Verificando credenciales...</div>");
    
    const data = {
      usuario: $("[name='usuario']").val(),
      clave: $("[name='clave']").val()
    };

    try {
      // 🔹 Llamada al API externo (.NET)
      const res = await fetch("http://18.118.129.255:5119/api/auth/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data)
      });

      if (!res.ok) throw new Error("Error de autenticación");

      const json = await res.json();
      if (json.token) {
        rocket.classList.add("launch");
        $("#msg").html("<div class='text-success mt-2'>Acceso concedido 🚀</div>");
        
        // 🔹 Guardar sesión en Tomcat
        setTimeout(() => {
          $.post("sr_login", { token: json.token, usuario: data.usuario }, function(){
            // ✅ Redirigir al panel principal
            window.location = "views/index.jsp";
          });
        }, 1000);
      } else {
        $("#msg").html("<div class='alert alert-danger mt-3 text-center'>Credenciales incorrectas</div>");
      }
    } catch (error) {
      $("#msg").html("<div class='alert alert-danger mt-3 text-center'>Error al conectar con el servidor</div>");
    }
  });
  </script>
</body>
</html>
