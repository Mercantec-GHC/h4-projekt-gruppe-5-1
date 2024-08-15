using Microsoft.EntityFrameworkCore;
using SKSBookingAPI.Models;

namespace SKSBookingAPI.Context
{
    public class AppDBContext : DbContext
    {
        public DbSet<User> Users { get; set; }
        public DbSet<Rental> Rentals { get; set; }
        public DbSet<Booking> Bookings { get; set; }

        public AppDBContext(DbContextOptions<AppDBContext> options) : base(options) {
        }
        public DbSet<SKSBookingAPI.Models.Rental> Rental { get; set; } = default!;
    }
}
