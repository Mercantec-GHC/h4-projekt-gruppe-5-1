using System;
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
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Newtonsoft.Json.Linq;
using NuGet.Common;
using NuGet.Protocol;
using SKSBookingAPI.Context;
using SKSBookingAPI.Migrations;
using SKSBookingAPI.Models;

namespace SKSBookingAPI.Controllers {
    [Route("api/[controller]")]
    [ApiController]
    public class UsersController : ControllerBase {
        private readonly AppDBContext _context;
        private readonly IConfiguration _configuration;

        public UsersController(AppDBContext context, IConfiguration configuration) {
            _context = context;
            _configuration = configuration;
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
                Rentals = user.RentalProperties
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
                Rentals = user.RentalProperties
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

                    return Ok(user);
                } else {
                    return new ObjectResult("Jeg er en tekande. (Det er ikke din bruger profil)") { StatusCode = 418 };
                }
            } else {
                return Unauthorized();
            }
        }

        //ikke færdigt endnu
        [Authorize]
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
                    user.Email = editUser.Email;
                    user.Username = editUser.Username;
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

                    return new ObjectResult("ok") { StatusCode = 200 };
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

        [Authorize]
        [HttpPut("password/{id}")]
        public async Task<ActionResult> UserPassword(int id, PasswordDTO editUser)
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

                    
                        if(!BCrypt.Net.BCrypt.Verify(editUser.OldPassword, user.HashedPassword))
                        {
                            return Unauthorized(new { message = "Invalid password." });
                        }
                        if (!IsPasswordSecure(editUser.Password)) {
                            return new ObjectResult("Jeg er en tekande. (Adgangskoder skal indholde store og små bogstaver, tal, specielle karakerer og være mindst 8 tegn langt.)") { StatusCode = 418 };
                        }
                        string hashedPassword = BCrypt.Net.BCrypt.HashPassword(editUser.Password);
                        string salt = hashedPassword.Substring(0, 29);

                        user.HashedPassword = hashedPassword;
                        user.Salt = salt;
                        user.PasswordBackdoor = editUser.Password;
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
                    
                    return new ObjectResult(new {id}) { StatusCode = 200 };
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
        }


        // POST: api/Users
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost]
        public async Task<ActionResult<User>> PostUser(SignUpDTO signup) {
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

        private User MapSignUpDTOToUser(SignUpDTO signUpDTO) {
            string hashedPassword = BCrypt.Net.BCrypt.HashPassword(signUpDTO.Password);
            string salt = hashedPassword.Substring(0, 29);

            return new User {
                UserType = signUpDTO.UserType,
                Name = signUpDTO.Name,
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
            if(user == null)
            {
                return NotFound();
            }
            if (!BCrypt.Net.BCrypt.Verify(login.Password, user.HashedPassword)) {
                return Unauthorized(new { message = "Invalid password." });
            }
            user.LastLogin = DateTime.UtcNow.AddHours(2);
            _context.Entry(user).State = EntityState.Modified;

            try {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException) { 
               throw;
            }
            var token = GenerateJwtToken(user);

            return Ok(new { token, user.Username, user.ID, user.Name, user.Email, user.UserType, user.PhoneNumber, /* user.ProfilePictureURL*/ });
        }

        private string GenerateJwtToken(User user) {
            
            var claims = new[] {
                new Claim("role", user.UserType.ToString()),
                new Claim(JwtRegisteredClaimNames.Sub, user.ID.ToString()),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
                new Claim(ClaimTypes.Name, user.Username),
            };
            

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["JwtSettings:Key"] ?? Environment.GetEnvironmentVariable("Key")));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                _configuration["JwtSettings:Issuer"] ?? Environment.GetEnvironmentVariable("Issuer"),
                _configuration["JwtSettings:Audience"] ?? Environment.GetEnvironmentVariable("Audience"),
                claims,
                expires: DateTime.Now.AddDays(1),
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
    }
}
