using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using SKSBookingAPI.Context;

namespace SKSBookingAPI.Controllers {
    [Route("api/[controller]")]
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

        [HttpGet("DB")]
        public IActionResult GetStatusDB() {
            if (_context.Database.CanConnect()) {
                return Ok("The database and server are live!");
            }
            else return NotFound();
        }
    }
}
