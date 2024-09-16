using System.IdentityModel.Tokens.Jwt;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SKSBookingAPI.Context;
using SKSBookingAPI.Models;

namespace SKSBookingAPI.Controllers {
    [Route("api/[controller]")]
    [ApiController]
    public class BookingsController : ControllerBase {
        private readonly AppDBContext _context;

        public BookingsController(AppDBContext context) {
            _context = context;
        }

        // GET: api/Bookings
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Booking>>> GetBookings() {
            return await _context.Bookings.ToListAsync();
        }


        // GET: api/Bookings/5
        [HttpGet("{id}")]
        public async Task<ActionResult<Booking>> GetBooking(int id) {
            var booking = await _context.Bookings.FindAsync(id);

            if (booking == null) {
                return NotFound();
            }

            return booking;
        }


        // PUT: api/Bookings/5
        [HttpPut("{id}")]
        public async Task<IActionResult> PutBooking(int id, Booking booking) {
            if (id != booking.BookingID) {
                return BadRequest();
            }

            _context.Entry(booking).State = EntityState.Modified;

            try {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException) {
                if (!BookingExists(id)) {
                    return NotFound();
                }
                else {
                    throw;
                }
            }

            return NoContent();
        }


        // POST: api/Bookings
        [Authorize]
        [HttpPost]
        public async Task<ActionResult<Booking>> PostBooking(CreateBookingDTO booking) {
            if (!(booking.BookedFrom.Date < booking.BookedUntil.Date)) {
                return BadRequest("Booket starttid er før sluttid");
            }

            var authHeader = HttpContext.Request.Headers["Authorization"].FirstOrDefault();

            if (authHeader != null && authHeader.StartsWith("Bearer ")) {
                authHeader = authHeader.Substring("Bearer ".Length).Trim();

                var handler = new JwtSecurityTokenHandler();
                var jwtSecurityToken = handler.ReadJwtToken(authHeader);

                if (jwtSecurityToken.Payload.Sub == booking.UserID.ToString()) {
                    Booking nyBooking = new Booking {
                        UserID = booking.UserID,
                        RentalID = booking.RentalID,
                        BookedFrom = booking.BookedFrom,
                        BookedUntil = booking.BookedUntil,
                    };

                    _context.Bookings.Add(nyBooking);
                    await _context.SaveChangesAsync();

                    return CreatedAtAction("GetBooking", new { id = nyBooking.BookingID }, nyBooking);
                }
            }

            return Unauthorized();
        }

        // DELETE: api/Bookings/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteBooking(int id) {
            var booking = await _context.Bookings.FindAsync(id);
            if (booking == null) {
                return NotFound();
            }

            _context.Bookings.Remove(booking);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool BookingExists(int id) {
            return _context.Bookings.Any(e => e.BookingID == id);
        }
    }
}
