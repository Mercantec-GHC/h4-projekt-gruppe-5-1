using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using SKSBookingAPI.Context;

namespace SKSBookingAPI.Controllers {
    [Route("api/[controller]")] // = api/controllernavn (præfix) -> api/status
    [ApiController]
    public class StatusController : ControllerBase {
        private readonly AppDBContext _context;

        public StatusController(AppDBContext context) {
            _context = context;
        }

        [HttpGet]
        public IActionResult GetStatus() {
            return Ok("The server is live!");
        }

        [HttpGet("db")]
        public IActionResult GetStatusDB() {
            if (_context.Database.CanConnect()) {
                return Ok("The database and server are live!");
            }
            else return NotFound();
        }
    }

    [HttpGet]
    public async Task<ActilResult<IEnumerable<UserDTO>>> GetUsers() {
        var users = await _context.Users
            .Select(users => new UserDTO {
                Id = users.Id,
                Email = users.Email,
                Username = users.Username
            })
            .ToListAsync();
        
        return Ok(users);
    }
}
