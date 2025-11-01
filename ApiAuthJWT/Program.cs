using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using ApiAuthJWT.Data;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// ================================
// 🔹 1️⃣ CONFIGURACIÓN GENERAL
// ================================
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

// ================================
// 🔹 2️⃣ CORS (permite JSP y acceso externo)
// ================================
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowJSP", policy =>
    {
        policy
            .WithOrigins(
                "http://localhost:8080",          // Para Tomcat local
                "http://18.118.129.255:8080"      // IP pública de tu servidor AWS
            )
            .AllowAnyHeader()
            .AllowAnyMethod();
    });

    // 🔸 Política general (para pruebas o Swagger)
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader();
    });
});

// ================================
// 🔹 3️⃣ SWAGGER + AUTH CONFIG
// ================================
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "API Auth JWT", Version = "v1" });

    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Introduce el token en el formato: Bearer {tu token}"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" }
            },
            Array.Empty<string>()
        }
    });
});

// ================================
// 🔹 4️⃣ JWT CONFIG
// ================================
var key = Encoding.UTF8.GetBytes("CLAVE_SUPER_SECRETA_JWT_123456");

builder.Services.AddAuthentication(opt =>
{
    opt.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    opt.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(opt =>
{
    opt.RequireHttpsMetadata = false; // 🔸 Solo para desarrollo
    opt.SaveToken = true;
    opt.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = false,
        ValidateAudience = false,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(key)
    };
});

// ================================
// 🔹 5️⃣ CONEXIÓN A BASE DE DATOS (MySQL)
// ================================
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseMySql(
        builder.Configuration.GetConnectionString("DefaultConnection"),
        ServerVersion.AutoDetect(builder.Configuration.GetConnectionString("DefaultConnection"))
    )
);

// ================================
// 🔹 6️⃣ CONSTRUIR APLICACIÓN
// ================================
var app = builder.Build();

// ================================
// 🔹 7️⃣ MIDDLEWARES
// ================================
// Usa AllowAll durante pruebas para evitar CORS
app.UseCors("AllowAll"); // ← cambiar a "AllowJSP" si quieres restringirlo luego
app.UseAuthentication();
app.UseAuthorization();

// ================================
// 🔹 8️⃣ SWAGGER UI
// ================================
app.UseSwagger();
app.UseSwaggerUI();

// ================================
// 🔹 9️⃣ MAPEO DE CONTROLADORES
// ================================
app.MapControllers();

// ================================
// 🔹 🔟 INICIAR SERVIDOR
// ================================
app.Run();
