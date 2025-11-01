using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// ================================
// 🔹 1️⃣ CONFIGURACIÓN GENERAL
// ================================
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

// ================================
// 🔹 2️⃣ CORS (permite JSP en Tomcat)
// ================================
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowJSP", policy =>
    {
        policy.WithOrigins("http://localhost:8080") // JSP corre en Tomcat
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

// ================================
// 🔹 3️⃣ SWAGGER + AUTH CONFIG
// ================================
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "API Auth JWT", Version = "v1" });

    // Configuración para probar JWT desde Swagger
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
var key = Encoding.UTF8.GetBytes("CLAVE_SUPER_SECRETA_JWT_123456"); // cambia esto

builder.Services.AddAuthentication(opt =>
{
    opt.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    opt.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(opt =>
{
    opt.RequireHttpsMetadata = false; // 🔸 para desarrollo (HTTP)
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
// 🔹 5️⃣ CONSTRUIR APLICACIÓN
// ================================
var app = builder.Build();

// ================================
// 🔹 6️⃣ MIDDLEWARES
// ================================
// ❌ Quitamos redirección a HTTPS (causa warning)
 // app.UseHttpsRedirection();

app.UseCors("AllowJSP");
app.UseAuthentication();
app.UseAuthorization();

// ================================
// 🔹 7️⃣ SWAGGER UI
// ================================
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// ================================
// 🔹 8️⃣ MAPEO DE CONTROLADORES
// ================================
app.MapControllers();

// ================================
// 🔹 9️⃣ INICIAR SERVIDOR
// ================================
app.Run();
