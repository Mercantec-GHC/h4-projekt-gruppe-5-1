﻿using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using System.Text.RegularExpressions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
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
            .Select(user => new AllUsersDTO {
                ID = user.ID,
                Name = user.Name,
                Email = user.Email,
                Username = user.Username,
                PhoneNumber = user.PhoneNumber,
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

            List<AllRentalsDTO> rentals = await _context.Rentals
            .Where(r => r.UserID == user.ID)
            .Select(rental => new AllRentalsDTO {
                ID = rental.ID,
                Address = rental.Address,
                PriceDaily = rental.PriceDaily,
                AvailableFrom = rental.AvailableFrom,
                AvailableTo = rental.AvailableTo,
                ImageURL = rental.GalleryURLs.First()
            })
            .ToListAsync();

            var userdto = new UserDTO {
                ID = user.ID,
                Biography = user.Biography,
                Name = user.Name,
                Email = user.Email,
                Username = user.Username,
                PhoneNumber = user.PhoneNumber,
                Rentals = rentals,
                ProfilePictureURL = user.ProfilePictureURL
            };

            return userdto;
        }

        // ændrer brugerens email, brugernavn og telefon nummer
        [Authorize]
        [HttpPut("account/{id}")]
        public async Task<ActionResult> UserAccount(int id, EditUserAccountDTO editUser) {
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
                    user.Email = editUser.Email;
                    user.Username = editUser.Username;
                    user.PhoneNumber = editUser.PhoneNumber;
                    user.UpdatedAt = DateTime.UtcNow.AddHours(2);

                    _context.Entry(user).State = EntityState.Modified;

                    try {
                        await _context.SaveChangesAsync();
                    }
                    catch (DbUpdateConcurrencyException) {
                        if (!UserExists(id)) {
                            return NotFound();
                        }
                        else {
                            throw;
                        }
                    }

                    return new ObjectResult("ok") { StatusCode = 200 };
                }
                else {
                    return new ObjectResult("Jeg er en tekande. (Det er ikke din bruger profil)") { StatusCode = 418 };
                }
            }
            else {
                return Unauthorized();
            }
        }

        // ændrer brugerens biografi
        [Authorize]
        [HttpPut("biografi/{id}")]
        public async Task<ActionResult> UserBio(int id, BioDTO userBio) {
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
                    user.Biography = userBio.Biography;
                    user.UpdatedAt = DateTime.UtcNow.AddHours(2);


                    _context.Entry(user).State = EntityState.Modified;

                    try {
                        await _context.SaveChangesAsync();
                    }
                    catch (DbUpdateConcurrencyException) {
                        if (!UserExists(id)) {
                            return NotFound();
                        }
                        else {
                            throw;
                        }
                    }

                    return Ok(userBio);
                }
                else {
                    return new ObjectResult("Jeg er en tekande. (Det er ikke din brugerprofil)") { StatusCode = 418 };
                }
            }
            else {
                return Unauthorized();
            }
        }

        // andrer brugerens password
        [Authorize]
        [HttpPut("password/{id}")]
        public async Task<ActionResult> UserPassword(int id, PasswordDTO editUser) {
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
                    // ser om det gamle password der er sendt med passer med det i databasen inden det ændrers
                    if (!BCrypt.Net.BCrypt.Verify(editUser.OldPassword, user.HashedPassword)) {
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

                    try {
                        await _context.SaveChangesAsync();
                    }
                    catch (DbUpdateConcurrencyException) {
                        if (!UserExists(id)) {
                            return NotFound();
                        }
                        else {
                            throw;
                        }
                    }

                    return new ObjectResult(new { id }) { StatusCode = 200 };
                }
                else {
                    return new ObjectResult("Jeg er en tekande. (Det er ikke din bruger profil)") { StatusCode = 418 };
                }
            }
            else {
                return Unauthorized();
            }
        }

        // ændrer brugerens billede og navn
        [Authorize]
        [HttpPut("{id}")]
        public async Task<ActionResult> ProfilePicture(int id, EditUserProfileDTO editUser) {
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
                    string? pfpURL = null;
                    string? oldPFPURL = user.ProfilePictureURL;

                    /* ser om der bliver sendt et nyt billede med ellers bruger den det gamle
                       Hvis profilbillede er sendt med, uploades det til vores S3 bucket
                    */
                    if (editUser.ProfilePicture != null && editUser.ProfilePicture.Length > 0) {
                        try {
                            using (var fileStream = editUser.ProfilePicture.OpenReadStream()) {
                                var uid = Guid.NewGuid().ToString("N");
                                pfpURL = await _s3Service.UploadToS3(fileStream, uid, ImageDirectoryType.profile);
                            }
                        }
                        catch (Exception ex) {
                            return StatusCode(StatusCodes.Status500InternalServerError, $"Error uploading file: {ex.Message}");
                        }
                        user.ProfilePictureURL = pfpURL;
                    }
                    else {
                        user.ProfilePictureURL = editUser.ProfilePictureURL;
                    }

                    // Hvis brugeren allerede havde et profilbillede, slettes det fra vores S3 bucket
                    if (oldPFPURL != null) {
                        try {
                            await _s3Service.DeleteFromS3(oldPFPURL, ImageDirectoryType.profile);
                        }
                        catch (Exception ex) {
                            return StatusCode(StatusCodes.Status500InternalServerError, $"Error deleting file: {ex.Message}");
                        }
                        
                    }
                    // sætter navn som også er sendt med for at sikre at værdien ikke bliver null
                    user.Name = editUser.Name;
                    user.UpdatedAt = DateTime.UtcNow.AddHours(2);

                    _context.Entry(user).State = EntityState.Modified;

                    try {
                        await _context.SaveChangesAsync();
                    }
                    catch (DbUpdateConcurrencyException) {
                        if (!UserExists(id)) {
                            return NotFound();
                        }
                        else {
                            throw;
                        }
                    }

                    return new ObjectResult(new { id }) { StatusCode = 200 };
                }
                else {
                    return new ObjectResult("Jeg er en tekande. (Det er ikke din bruger profil)") { StatusCode = 418 };
                }
            }
            else {
                return Unauthorized();
            }
        }

        // opretter en ny bruger
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
                        pfpURL = await _s3Service.UploadToS3(fileStream, uid, ImageDirectoryType.profile);
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

        // Oversætter indsendt brugerinformation til anden, udvidet type
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
        //tjekker om password passer vores kriterier
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

        /* sletter brugeren
        // DELETE: api/Users/5*/
        [Authorize]
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteUser(int id) {
            var user = await _context.Users.FindAsync(id);
            if (user == null) {
                return NotFound();
            }
            var authHeader = HttpContext.Request.Headers["Authorization"].FirstOrDefault();

            if (authHeader != null && authHeader.StartsWith("Bearer ")) {
                authHeader = authHeader.Substring("Bearer ".Length).Trim();

                var handler = new JwtSecurityTokenHandler();
                var jwtSecurityToken = handler.ReadJwtToken(authHeader);
                //finder bruger typen som blev sat ind ved login
                var userType = jwtSecurityToken.Claims.FirstOrDefault(c => c.Type == "role")?.Value;
                // tjekker om det er bruger type 2 som er Admin
                if (userType == "2") {
                    _context.Users.Remove(user);
                    await _context.SaveChangesAsync();

                    return new ObjectResult("bruger slettet") { StatusCode = 200 };
                } else {
                    return new ObjectResult("Jeg er en tekande. (Du har ikke bruger rettigheder til dette)") { StatusCode = 418 };
                }
            }
            else {
                return Unauthorized();
            }

        }

        private bool UserExists(int id) {
            return _context.Users.Any(e => e.ID == id);
        }

        // logger brugeren ind
        // POST: api/Users/login
        [HttpPost("login")]
        public async Task<IActionResult> Login(LoginDTO login) {
            var user = await _context.Users.SingleOrDefaultAsync(u => u.Email == login.Email);
            if (user == null) {
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

            return Ok(new { token, user.Username, user.ID, user.Name, user.Email, user.UserType, user.PhoneNumber, user.ProfilePictureURL, user.Biography });
        }
        // laver en en ny JWT
        private string GenerateJwtToken(User user) {

            var claims = new[] {
                new Claim("role", user.UserType.ToString()),//laver en ny claim til payload så vi kan få bruger typen se slet bruger
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

    }
}