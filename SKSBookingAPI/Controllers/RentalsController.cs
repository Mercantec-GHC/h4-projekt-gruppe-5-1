using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Threading.Tasks;
using Amazon.Runtime.Internal;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SKSBookingAPI.Context;
using SKSBookingAPI.Migrations;
using SKSBookingAPI.Models;
using SKSBookingAPI.Service;

namespace SKSBookingAPI.Controllers {
    [Route("api/[controller]")]
    [ApiController]
    public class RentalsController : ControllerBase {
        private readonly AppDBContext _context;
        private readonly string _accessKey;
        private readonly string _secretKey;
        private readonly S3Service _s3Service;

        public RentalsController(AppDBContext context, S3BucketConfig config) {
            _context = context;

            _accessKey = config.AccessKey;
            _secretKey = config.SecretKey;

            _s3Service = new S3Service(_accessKey, _secretKey);
        }

        // GET: api/Rentals
        [HttpGet]
        public async Task<ActionResult<IEnumerable<AllRentalsDTO>>> GetRental() {
            var rentals = await _context.Rental
            .Select(rental => new AllRentalsDTO {
                ID = rental.ID,
                Address = rental.Address,
                PriceDaily = rental.PriceDaily,
                AvailableFrom = rental.AvailableFrom,
                AvailableTo = rental.AvailableTo,
                ImageURL = rental.GalleryURLs.First()
            })
            .ToListAsync();

            return Ok(rentals);
        }


        // GET: api/Rentals/5
        [HttpGet("{id}")]
        public async Task<ActionResult<RentalDTO>> GetRental(int id) {
            var rental = await _context.Rental.FindAsync(id);

            if (rental == null) {
                return NotFound();
            }

            var user = await _context.Users.FindAsync(rental.UserID);

            if (user == null) {
                return NotFound();
            }

            UserRentingDTO userdto = new UserRentingDTO {
                ID = user.ID,
                Name = user.Name,
                Email = user.Email,
                ProfilePictureURL = user.ProfilePictureURL
            };

            var rentalDto = new RentalDTO {
                Title = rental.Title,
                Address = rental.Address,
                Description = rental.Description,
                PriceDaily = rental.PriceDaily,
                AvailableFrom = rental.AvailableFrom,
                AvailableTo = rental.AvailableTo,
                Owner = userdto,
                GalleryURLs = rental.GalleryURLs
            };

            return rentalDto;
        }


        // PUT: api/Rentals/5
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("{id}")]
        public async Task<IActionResult> PutRental(int id, Rental rental) {
            if (id != rental.ID) {
                return BadRequest();
            }

            _context.Entry(rental).State = EntityState.Modified;

            try {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException) {
                if (!RentalExists(id)) {
                    return NotFound();
                }
                else {
                    throw;
                }
            }

            return NoContent();
        }


        // POST: api/Rentals
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost]
        public async Task<ActionResult<Rental>> PostRental([FromForm] CreateRentalDTO rental) {
            List<string> rentalImages = new();

            if (rental.GalleryImages != null && rental.GalleryImages.Length > 0) {
                foreach (IFormFile file in rental.GalleryImages) {
                    
                    if (file != null && file.Length > 0) {
                        try {
                            using (var fileStream = file.OpenReadStream()) {
                                var uid = Guid.NewGuid().ToString("N");
                                rentalImages.Add(await _s3Service.UploadToS3(fileStream, uid, ImageUploadType.rental));
                            }
                        }
                        catch (Exception ex) {
                            return StatusCode(StatusCodes.Status500InternalServerError, $"Error uploading file: {ex.Message}");
                        }
                    }
                }
            }

            Rental nyRental = new Rental {
                Title = rental.Title,
                Address = rental.Address,
                Description = rental.Description,
                PriceDaily = rental.PriceDaily,
                IsVisibleToGuests = rental.IsVisibleToGuests,
                AvailableFrom = rental.AvailableFrom,
                AvailableTo = rental.AvailableTo,
                UserID = rental.UserID,
                CreatedAt = DateTime.UtcNow.AddHours(2),
                UpdatedAt = DateTime.UtcNow.AddHours(2),
                GalleryURLs = rentalImages.ToArray()
            };

            _context.Rental.Add(nyRental);
            await _context.SaveChangesAsync();

            return CreatedAtAction("GetRental", new { id = nyRental.ID }, nyRental);
        }


        // DELETE: api/Rentals/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteRental(int id) {
            var rental = await _context.Rental.FindAsync(id);
            if (rental == null) {
                return NotFound();
            }

            _context.Rental.Remove(rental);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool RentalExists(int id) {
            return _context.Rental.Any(e => e.ID == id);
        }



        // AUTH TEST

        [HttpGet("authtest/{id}")]
        public async Task<ActionResult<RentalDTO>> GetRental(int id, byte? authID) {
            var rental = await _context.Rental.FindAsync(id);
            if (rental == null) {
                return NotFound();
            }

            if (rental.IsVisibleToGuests == false && authID == null) {
                return Forbid();
            }

            var user = await _context.Users.FindAsync(rental.UserID);
            if (user == null) {
                return NotFound();
            }

            UserRentingDTO userdto = new UserRentingDTO {
                ID = user.ID,
                Name = user.Name,
                Email = user.Email
            };

            RentalDTO rentalDTO = new RentalDTO {
                Address = rental.Address,
                PriceDaily = rental.PriceDaily,
                Description = rental.Description,
                AvailableFrom = rental.AvailableFrom,
                AvailableTo = rental.AvailableTo,
                Owner = userdto
            };

            return rentalDTO;
        }


        [HttpPost("authtest")]
        public async Task<ActionResult<Rental>> PostRental(CreateRentalDTO rental, byte? authID) {
            if (authID != 1 && authID != 2) {
                return Forbid();
            }

            Rental nyRental = new Rental {
                Title = rental.Title,
                Address = rental.Address,
                Description = rental.Description,
                PriceDaily = rental.PriceDaily,
                IsVisibleToGuests = rental.IsVisibleToGuests,
                AvailableFrom = rental.AvailableFrom,
                AvailableTo = rental.AvailableTo,
                UserID = rental.UserID,
                CreatedAt = DateTime.UtcNow.AddHours(2),
                UpdatedAt = DateTime.UtcNow.AddHours(2)
            };

            _context.Rental.Add(nyRental);
            await _context.SaveChangesAsync();

            return CreatedAtAction("GetRental", new { id = nyRental.ID }, nyRental);
        }
    }
}
