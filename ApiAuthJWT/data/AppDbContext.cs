using Microsoft.EntityFrameworkCore;

namespace ApiAuthJWT.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options)
            : base(options)
        {
        }

        // 🔹 Aquí defines las tablas (DbSet) que quieres mapear
        // Ejemplo:
        // public DbSet<Usuario> Usuarios { get; set; }
    }
}
