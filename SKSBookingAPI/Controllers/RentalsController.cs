﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SKSBookingAPI.Context;
using SKSBookingAPI.Models;

namespace SKSBookingAPI.Controllers {
    [Route("api/[controller]")]
    [ApiController]
    public class RentalsController : ControllerBase {
        private readonly AppDBContext _context;

        public RentalsController(AppDBContext context) {
            _context = context;
        }

        // GET: api/Rentals
        [HttpGet]
        public async Task<ActionResult<IEnumerable<RentalDTO>>> GetRental() {
            var rentals = await _context.Rental
            .Select(rental => new RentalDTO {
                Address = rental.Address,
                Description = rental.Description,
                AvailableFrom = rental.AvailableFrom,
                AvailableTo = rental.AvailableTo,
                //Owner = rental.Owner,
            })
            .ToListAsync();

            return Ok(rentals);
        }


        // GET: api/Rentals/5
        [HttpGet("{id}")]
        public async Task<ActionResult<Rental>> GetRental(int id) {
            var rental = await _context.Rental.FindAsync(id);

            if (rental == null) {
                return NotFound();
            }

            return rental;
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
        public async Task<ActionResult<Rental>> PostRental(CreateRentalDTO rental) {

            Rental nyRental = new Rental {
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

            var user = await _context.Users.FindAsync(rental.UserID);
            if (user == null) {
                return NotFound();
            }

            if (rental.IsVisibleToGuests == false && authID == null) {
                return Forbid();
            }

            UserRentingDTO userdto = new UserRentingDTO {
                Name = user.Name,
                Email = user.Email,
                PhoneNumber = user.PhoneNumber
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
