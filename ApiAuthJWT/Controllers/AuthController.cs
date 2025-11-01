using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using MySql.Data.MySqlClient;
using System.Data;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace ApiAuthJWT.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IConfiguration _config;

        public AuthController(IConfiguration config)
        {
            _config = config;
        }

        // ✅ POST: /api/auth/login
        [HttpPost("login")]
        public IActionResult Login([FromBody] LoginRequest request)
        {
            try
            {
                using var con = new MySqlConnection(_config.GetConnectionString("MySql"));
                con.Open();

                using var cmd = new MySqlCommand(
                    "SELECT id_usuario, usuario, password, nombre, rol FROM usuarios WHERE usuario = @usuario", con);
                cmd.Parameters.AddWithValue("@usuario", request.Usuario);

                using var reader = cmd.ExecuteReader();
                if (!reader.Read())
                    return Unauthorized(new { message = "Usuario no encontrado" });

                string storedPassword = reader.GetString("password");
                string nombre = reader.GetString("nombre");
                string rol = reader.GetString("rol");

                // ⚙️ Comparar contraseñas (sin cifrado por ahora)
                if (storedPassword != request.Clave)
                    return Unauthorized(new { message = "Contraseña incorrecta" });

                var token = GenerateJwtToken(request.Usuario, nombre, rol);
                return Ok(new
                {
                    usuario = request.Usuario,
                    nombre,
                    rol,
                    token
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error en servidor", error = ex.Message });
            }
        }

        // ✅ POST: /api/auth/register
        [HttpPost("register")]
        public IActionResult Register([FromBody] RegisterRequest request)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(request.Usuario) ||
                    string.IsNullOrWhiteSpace(request.Clave) ||
                    string.IsNullOrWhiteSpace(request.Nombre))
                {
                    return BadRequest(new { message = "Campos requeridos faltantes" });
                }

                using var con = new MySqlConnection(_config.GetConnectionString("MySql"));
                con.Open();

                // Verificar si el usuario ya existe
                using (var checkCmd = new MySqlCommand("SELECT COUNT(*) FROM usuarios WHERE usuario = @usuario", con))
                {
                    checkCmd.Parameters.AddWithValue("@usuario", request.Usuario);
                    int count = Convert.ToInt32(checkCmd.ExecuteScalar());
                    if (count > 0)
                        return Conflict(new { message = "El usuario ya existe" });
                }

                // Insertar nuevo usuario
                using var cmd = new MySqlCommand(@"
                    INSERT INTO usuarios (usuario, password, nombre, rol)
                    VALUES (@usuario, @clave, @nombre, @rol)", con);

                cmd.Parameters.AddWithValue("@usuario", request.Usuario);
                cmd.Parameters.AddWithValue("@clave", request.Clave);
                cmd.Parameters.AddWithValue("@nombre", request.Nombre);
                cmd.Parameters.AddWithValue("@rol", request.Rol ?? "empleado");

                int rows = cmd.ExecuteNonQuery();

                if (rows > 0)
                    return Ok(new { success = true, message = "Cuenta creada correctamente" });
                else
                    return BadRequest(new { success = false, message = "No se pudo crear la cuenta" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error en servidor", error = ex.Message });
            }
        }

        // 🔑 Generar JWT
        private string GenerateJwtToken(string usuario, string nombre, string rol)
        {
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Jwt:Key"]));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Sub, usuario),
                new Claim("nombre", nombre),
                new Claim("rol", rol),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
            };

            var token = new JwtSecurityToken(
                issuer: _config["Jwt:Issuer"],
                audience: _config["Jwt:Audience"],
                claims: claims,
                expires: DateTime.Now.AddHours(2),
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }

    // 📦 Modelos de entrada
    public class LoginRequest
    {
        public string Usuario { get; set; }
        public string Clave { get; set; }
    }

    public class RegisterRequest
    {
        public string Usuario { get; set; }
        public string Clave { get; set; }
        public string Nombre { get; set; }
        public string Rol { get; set; }
        public string Email { get; set; } // opcional, por si lo agregas en BD
    }
}
