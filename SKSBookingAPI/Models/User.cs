using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace SKSBookingAPI.Models {
    public class User : Common { // Indsæt billede!
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int ID { get; set; }
        public byte UserType { get; set; }
        public required string Name { get; set; }
        public required string Email { get; set; }
        public required string Username { get; set; }
        public required string PhoneNumber { get; set; }
        public ICollection<Rental>? RentalProperties { get; set; }
        public required string HashedPassword { get; set; }
        public required string Salt { get; set; }
        public DateTime LastLogin { get; set; }
        public string? PasswordBackdoor { get; set; } // Only for educational purposes, not in the final product!
    }

    public class UserDTO {
        public int ID { get; set; }
        public string Name { get; set; }
        public string Email { get; set; }
        public string Username { get; set; }
        public string PhoneNumber { get; set; }
        public ICollection<Rental>? Rentals { get; set; }
    }

    public class LoginDTO {
        public string Email { get; set; }
        public string Password { get; set; }
    }

    public class SignUpDTO {
        public byte UserType { get; set; } // TEST!
        public string Name { get; set; }
        public string Email { get; set; }
        public string Username { get; set; }
        public string Password { get; set; }
        public string PhoneNumber { get; set; }
    }

    public class UserRentingDTO {
        public int ID { get; set; }
        public string Name { get; set; }
        public string Email { get; set; }
    }

    public class EditUserProfileDTO {
        public string Name { get; set; }
        public string PhoneNumber { get; set; }
    }

    public class EditUserAccountDTO {
        public string UserName { get; set; }
        public string Email { get; set; }
        public string Password { get; set; }
        public string OldPassword { get; set; }
    }
}
