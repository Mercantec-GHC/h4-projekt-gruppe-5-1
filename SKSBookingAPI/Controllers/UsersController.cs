﻿using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using BCrypt.Net;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Newtonsoft.Json.Linq;
using NuGet.Common;
using NuGet.Protocol;
using SKSBookingAPI.Context;
using SKSBookingAPI.Models;
using SKSBookingAPI.Service;

namespace SKSBookingAPI.Controllers {
    [Route("api/[controller]")]
    [ApiController]
    public class UsersController : ControllerBase {
        private readonly AppDBContext _context;
        private readonly IConfiguration _configuration;
        private readonly string _accessKey;
        private readonly string _secretKey;
        private readonly S3Service _s3Service;

        public UsersController(AppDBContext context, IConfiguration configuration, S3BucketConfig config) {
            _context = context;
            _configuration = configuration;

            _accessKey = config.AccessKey;
            _secretKey = config.SecretKey;

            _s3Service = new S3Service(_accessKey, _secretKey);
        }

        // GET: api/Users
        [Authorize]
        [HttpGet]
        public async Task<ActionResult<IEnumerable<UserDTO>>> GetUsers() {
            var users = await _context.Users
            .Select(user => new UserDTO {
                ID = user.ID,
                Name = user.Name,
                Email = user.Email,
                Username = user.Username,
                PhoneNumber = user.PhoneNumber,
                Rentals = user.RentalProperties,
                ProfilePictureURL = user.ProfilePictureURL
            })
            .ToListAsync();

            return Ok(users);
        }


        // GET: api/Users/5
        [HttpGet("{id}")]
        public async Task<ActionResult<UserDTO>> GetUser(int id) {
            var user = await _context.Users.FindAsync(id);

            if (user == null) {
                return NotFound();
            }

            var userdto = new UserDTO {
                ID = user.ID,
                Name = user.Name,
                Email = user.Email,
                Username = user.Username,
                PhoneNumber = user.PhoneNumber,
                Rentals = user.RentalProperties,
                ProfilePictureURL = user.ProfilePictureURL
            };

            return userdto;
        }


        // PUT: api/Users/5 
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [Authorize]
        [HttpPut("{id}")]
        public async Task<ActionResult> UserProfile(int id, EditUserProfileDTO editUser) {
            var user = await _context.Users.FindAsync(id);

            if (user == null) {
                return NotFound();
            }

            var authHeader = HttpContext.Request.Headers["Authorization"].FirstOrDefault();

            if (authHeader != null && authHeader.StartsWith("Bearer ")) {
                authHeader = authHeader.Substring("Bearer ".Length).Trim();

                var handler = new JwtSecurityTokenHandler();
                var jwtSecurityToken = handler.ReadJwtToken(authHeader);

                if (jwtSecurityToken.Payload.Sub == id.ToString()) {
                    user.Name = editUser.Name;
                    user.PhoneNumber = editUser.PhoneNumber;
                    user.UpdatedAt = DateTime.UtcNow.AddHours(2);

                    _context.Entry(user).State = EntityState.Modified;

                    try {
                        await _context.SaveChangesAsync();
                    } catch (DbUpdateConcurrencyException) {
                        if (!UserExists(id)) {
                            return NotFound();
                        } else {
                            throw;
                        }
                    }

                    return Ok("User profile updated successfully.");
                } else {
                    return new ObjectResult("Jeg er en tekande. (Det er ikke din bruger profil)") { StatusCode = 418 };
                }
            } else {
                return Unauthorized();
            }
        }

        //ikke færdigt endnu
        /*[Authorize]
        [HttpPut("account/{id}")]
        public async Task<ActionResult> UserAccount(int id, EditUserAccountDTO editUser)
        {
            var user = await _context.Users.FindAsync(id);

            if (user == null)
            {
                return NotFound();
            }

            var authHeader = HttpContext.Request.Headers["Authorization"].FirstOrDefault();

            if (authHeader != null && authHeader.StartsWith("Bearer "))
            {
                authHeader = authHeader.Substring("Bearer ".Length).Trim();

                var handler = new JwtSecurityTokenHandler();
                var jwtSecurityToken = handler.ReadJwtToken(authHeader);

                if (jwtSecurityToken.Payload.Sub == id.ToString())
                {
                    
                    if(editUser.Password != null)
                    {
                        if(!BCrypt.Net.BCrypt.Verify(editUser.OldPassword, user.HashedPassword))
                        {

                        }
                        string hashedPassword = BCrypt.Net.BCrypt.HashPassword(editUser.Password);

                        user.Name = editUser.Name;
                        user.PhoneNumber = editUser.PhoneNumber;
                        user.UpdatedAt = DateTime.UtcNow.AddHours(2);
                    }
                    user.Name = editUser.Name;
                    user.PhoneNumber = editUser.PhoneNumber;
                    user.UpdatedAt = DateTime.UtcNow.AddHours(2);

                    _context.Entry(user).State = EntityState.Modified;

                    try
                    {
                        await _context.SaveChangesAsync();
                    }
                    catch (DbUpdateConcurrencyException)
                    {
                        if (!UserExists(id))
                        {
                            return NotFound();
                        }
                        else
                        {
                            throw;
                        }
                    }

                    return Ok("User profile updated successfully.");
                }
                else
                {
                    return new ObjectResult("Jeg er en tekande. (Det er ikke din bruger profil)") { StatusCode = 418 };
                }
            }
            else
            {
                return Unauthorized();
            }
        }//*/


        // POST: api/Users
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost]
        public async Task<ActionResult<User>> PostUser([FromForm] SignUpDTO signup) {
            if (await _context.Users.AnyAsync(u => u.Email == signup.Email)) {
                return new ObjectResult("Jeg er en tekande. (Email allerede i brug.)") { StatusCode = 418 };
            }
            if (await _context.Users.AnyAsync(u => u.Username == signup.Username)) {
                return new ObjectResult("Jeg er en tekande. (Brugernavn allerede i brug.)") { StatusCode = 418 };
            }
            if (!IsPasswordSecure(signup.Password)) {
                return new ObjectResult("Jeg er en tekande. (Adgangskoder skal indholde store og små bogstaver, tal, specielle karakerer og være mindst 8 tegn langt.)") { StatusCode = 418 };
            }

            string? pfpURL = null;
            if (signup.ProfilePicture != null && signup.ProfilePicture.Length > 0) {

                try {
                    using (var fileStream = signup.ProfilePicture.OpenReadStream()) {
                        var uid = Guid.NewGuid().ToString("N");
                        pfpURL = await _s3Service.UploadToS3(fileStream, uid, ImageUploadType.profile);
                    }
                }
                catch (Exception ex) {
                    return StatusCode(StatusCodes.Status500InternalServerError, $"Error uploading file: {ex.Message}");
                }
            }

            User user = MapSignUpDTOToUser(signup, ref pfpURL);

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            return CreatedAtAction("GetUser", new { id = user.ID }, user);
        }

        private User MapSignUpDTOToUser(SignUpDTO signUpDTO, ref string? pfpURL) {
            string hashedPassword = BCrypt.Net.BCrypt.HashPassword(signUpDTO.Password);
            string salt = hashedPassword.Substring(0, 29);

            return new User {
                UserType = signUpDTO.UserType,
                Name = signUpDTO.Name,
                Biography = "",
                ProfilePictureURL = pfpURL,
                Email = signUpDTO.Email,
                Username = signUpDTO.Username,
                PhoneNumber = signUpDTO.PhoneNumber,
                HashedPassword = hashedPassword,
                Salt = salt,
                PasswordBackdoor = signUpDTO.Password, // Only for educational purposes, not in the final product!
                CreatedAt = DateTime.UtcNow.AddHours(2),
                UpdatedAt = DateTime.UtcNow.AddHours(2),
                LastLogin = DateTime.UtcNow.AddHours(2)
            };
        }

        private bool IsPasswordSecure(string password) {
            var hasUpperCase = new Regex(@"[A-Z]+");
            var hasLowerCase = new Regex(@"[a-z]+");
            var hasDigits = new Regex(@"[0-9]+");
            var hasSpecialChar = new Regex(@"[\W_]+");
            var hasMinimum8Chars = new Regex(@".{8,}");

            return hasUpperCase.IsMatch(password)
                   && hasLowerCase.IsMatch(password)
                   && hasDigits.IsMatch(password)
                   && hasSpecialChar.IsMatch(password)
                   && hasMinimum8Chars.IsMatch(password);
        }


        // DELETE: api/Users/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteUser(int id) {
            var user = await _context.Users.FindAsync(id);
            if (user == null) {
                return NotFound();
            }

            _context.Users.Remove(user);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool UserExists(int id) {
            return _context.Users.Any(e => e.ID == id);
        }


        // POST: api/Users/login
        [HttpPost("login")]
        public async Task<IActionResult> Login(LoginDTO login) {
            var user = await _context.Users.SingleOrDefaultAsync(u => u.Email == login.Email);
            if (user == null || !BCrypt.Net.BCrypt.Verify(login.Password, user.HashedPassword)) {
                return Unauthorized(new { message = "Invalid email or password." });
            }
            var token = GenerateJwtToken(user);

            return Ok(new { token, user.Username, user.ID });
        }

        private string GenerateJwtToken(User user) {
            var claims = new[] {
                new Claim(JwtRegisteredClaimNames.Sub, user.ID.ToString()),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
                new Claim(ClaimTypes.Name, user.Username)
            };

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["JwtSettings:Key"] ?? Environment.GetEnvironmentVariable("Key")));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                _configuration["JwtSettings:Issuer"] ?? Environment.GetEnvironmentVariable("Issuer"),
                _configuration["JwtSettings:Audience"] ?? Environment.GetEnvironmentVariable("Audience"),
                claims,
                expires: DateTime.Now.AddMinutes(30),
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }


        // TODO Fredag - Indsæt test rolletjek, og juster hvad test endpoints giver afhængigt af det, fx kan brugere ikke lave lejligheder, og kun admins se liste af brugere
        // Idéen er til sidst få det bundet til brugertokens i stedet for en HTML parameter/hente brugertype fra DB ud fra login
        // Der er gentaget kode her, lad være med at tænke over det :)

        [HttpGet("testauth")]
        public async Task<ActionResult<IEnumerable<UserDTO>>> GetUsers(byte? authID) {
            if (authID != 2) {
                return Forbid();
            }

            var users = await _context.Users
            .Select(user => new UserDTO {
                ID = user.ID,
                Name = user.Name,
                Email = user.Email,
                Username = user.Username,
                PhoneNumber = user.PhoneNumber,
                Rentals = user.RentalProperties
            })
            .ToListAsync();

            return Ok(users);
        }

        /*
        [HttpPost("testauth")]
        public async Task<ActionResult<User>> PostUser(SignUpDTO signup, byte? authID) {
            
            if (signup.UserType != 0 && authID != 2) {
                return Forbid();
            }
            if (await _context.Users.AnyAsync(u => u.Email == signup.Email)) {
                return new ObjectResult("Jeg er en tekande. (Email allerede i brug.)") { StatusCode = 418 };
            }
            if (await _context.Users.AnyAsync(u => u.Username == signup.Username)) {
                return new ObjectResult("Jeg er en tekande. (Brugernavn allerede i brug.)") { StatusCode = 418 };
            }
            if (!IsPasswordSecure(signup.Password)) {
                return new ObjectResult("Jeg er en tekande. (Adgangskoder skal indholde store og små bogstaver, tal, specielle karakerer og være mindst 8 tegn langt.)") { StatusCode = 418 };
            }

            User user = MapSignUpDTOToUser(signup);

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            return CreatedAtAction("GetUser", new { id = user.ID }, user);
        }

        [HttpDelete("testauth/{id}")]
        public async Task<IActionResult> DeleteUser(int id, byte? authID) {
            if (authID != 2) {
                return Forbid();
            }

            var user = await _context.Users.FindAsync(id);
            if (user == null) {
                return NotFound();
            }

            _context.Users.Remove(user);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        [HttpGet("testauthtoken")]
        public async Task<ActionResult<string>> GetIDFromToken(string token) {
            //TokenValidationParameters parameters = new TokenValidationParameters();
            //new JwtSecurityTokenHandler().ValidateToken(token, , out SecurityToken validatedToken);

            // Token skal nok valideres først
            SecurityToken readToken = new JwtSecurityTokenHandler().ReadToken(token);
            string attachedID = (readToken as JwtSecurityToken).Claims.First(c => c.Type == "sub").Value;

            return attachedID;
        }
        */
    }
}
