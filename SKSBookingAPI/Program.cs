
using Microsoft.EntityFrameworkCore;
using SKSBookingAPI.Context;
using System;

namespace SKSBookingAPI
{
    public class Program {
        public static void Main(string[] args) {
            var builder = WebApplication.CreateBuilder(args);

            // Add services to the container.
            IConfiguration Configuration = builder.Configuration;

            string connectionString = Configuration.GetConnectionString("DefaultConnection")
            ?? Environment.GetEnvironmentVariable("DefaultConnection");

            builder.Services.AddDbContext<AppDBContext>(options => {
                options.UseNpgsql(connectionString);
            });

            builder.Services.AddControllers();
            // Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
            builder.Services.AddEndpointsApiExplorer();
            builder.Services.AddSwaggerGen();

            var app = builder.Build();

            // Configure the HTTP request pipeline.
            app.UseSwagger();
            app.UseSwaggerUI();

            /*
            if (app.Environment.IsDevelopment()) {
                app.UseSwagger();
                app.UseSwaggerUI();
            }
            */

            app.UseHttpsRedirection();

            app.UseAuthorization();

            app.MapControllers();

            app.Run();
        }
    }
}
