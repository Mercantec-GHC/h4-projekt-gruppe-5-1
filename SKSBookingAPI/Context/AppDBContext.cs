using Microsoft.EntityFrameworkCore;
using SKSBookingAPI.Models;

namespace SKSBookingAPI.Context
{
    public class AppDBContext : DbContext
    {
        public DbSet<User> Users { get; set; }

        public AppDBContext(DbContextOptions<AppDBContext> options)
            : base(options)
        {
        }
    }
}
