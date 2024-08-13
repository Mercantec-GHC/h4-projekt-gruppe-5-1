using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SKSBookingAPI.Context;
using SKSBookingAPI.Models;

namespace SKSBookingAPI.Controllers {
    [Route("api/[controller]")]
    [ApiController]
    public class UsersController : ControllerBase {
        private readonly AppDBContext _context;

        public UsersController(AppDBContext context) {
            _context = context;
        }

        // GET: api/Users
        [HttpGet]
        public async Task<ActionResult<IEnumerable<UserDTO>>> GetUsers() {
            var users = await _context.Users
            .Select(user => new UserDTO {
                 ID = user.ID,
                 Email = user.Email,
                 Username = user.Username,
                 PhoneNumber = user.PhoneNumber
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
                Email = user.Email,
                Username = user.Username,
                PhoneNumber = user.PhoneNumber
            };

            return userdto;
        }

        // PUT: api/Users/5
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("{id}")]
        public async Task<IActionResult> PutUser(int id, User user) {
            if (id != user.ID) {
                return BadRequest();
            }

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

            return NoContent();
        }

        private User MapSignUpDTOToUser(SignUpDTO signUpDTO) {
            string hashedPassword = BCrypt.Net.BCrypt.HashPassword(signUpDTO.Password);
            string salt = hashedPassword.Substring(0, 29);

            return new User {
                Email = signUpDTO.Email,
                Username = signUpDTO.Username,
                PhoneNumber = signUpDTO.PhoneNumber,
                HashedPassword = hashedPassword,
                Salt = salt,
                PasswordBackdoor = signUpDTO.Password,
                CreatedAt = DateTime.UtcNow.AddHours(2),
                UpdatedAt = DateTime.UtcNow.AddHours(2),
                LastLogin = DateTime.UtcNow.AddHours(2)
                // Only for educational purposes, not in the final product!
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
    }
}
