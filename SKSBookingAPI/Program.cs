using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using SKSBookingAPI.Context;
using SKSBookingAPI.Service;
using System;
using System.Text;

namespace SKSBookingAPI {
    public class Program {
        public static void Main(string[] args) {
            var MyAllowSpecificOrigins = "_myAllowSpecificOrigins";
            var builder = WebApplication.CreateBuilder(args);
            builder.Services.AddCors(options =>
            {
                options.AddPolicy(
                    name: MyAllowSpecificOrigins,
                    policy =>
                    {
                        policy.WithOrigins("*").AllowAnyMethod().AllowAnyHeader();
                    }
                );
            });

            // Add services to the container.
            IConfiguration Configuration = builder.Configuration;

            // Configure JWT Authentication
            builder.Services.AddAuthentication(x => {
                x.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
                x.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
                x.DefaultScheme = JwtBearerDefaults.AuthenticationScheme;
            })
            .AddJwtBearer(x => {
                x.TokenValidationParameters = new TokenValidationParameters {
                    ValidIssuer = Configuration["JwtSettings:Issuer"] ?? Environment.GetEnvironmentVariable("Issuer"),
                    ValidAudience = Configuration["JwtSettings:Audience"] ?? Environment.GetEnvironmentVariable("Audience"),
                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(Configuration["JwtSettings:Key"] ?? Environment.GetEnvironmentVariable("Key"))),
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidateLifetime = true,
                    ValidateIssuerSigningKey = true
                };
            });

            // Configure connection string
            string connectionString = Configuration.GetConnectionString("DefaultConnection") ?? Environment.GetEnvironmentVariable("DefaultConnection");

            builder.Services.AddDbContext<AppDBContext>(options => {
                options.UseNpgsql(connectionString);
            });

            var accessKey = Configuration["S3ServiceSettings:AccessKey"] ?? Environment.GetEnvironmentVariable("ACCESS_KEY");
            var secretKey = Configuration["S3ServiceSettings:SecretKey"] ?? Environment.GetEnvironmentVariable("SECRET_KEY");

            builder.Services.AddSingleton(new S3BucketConfig {
                AccessKey = accessKey,
                SecretKey = secretKey
            });

            builder.Services.AddControllers();
            builder.Services.AddEndpointsApiExplorer();
            builder.Services.AddSwaggerGen();

            var app = builder.Build();

            // Configure the HTTP request pipeline.
            app.UseSwagger();
            app.UseSwaggerUI();

            app.UseCors(MyAllowSpecificOrigins);
            app.UseHttpsRedirection();
            app.UseAuthorization();
            app.MapControllers();
            app.Run();
        }
    }
}
