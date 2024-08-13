namespace SKSBookingAPI.Models {
    public class User : Common { // Indsæt billede!
        public required string Email { get; set; }
        public required string Username { get; set; }
        public required string PhoneNumber { get; set; }
        public required string HashedPassword { get; set; }
        public required string Salt { get; set; }
        public DateTime LastLogin { get; set; }
        public string? PasswordBackdoor { get; set; }
        // Only for educational purposes, not in the final product!
    }
    public class UserDTO {
        public int ID { get; set; }
        public string Email { get; set; }
        public string Username { get; set; }
        public string PhoneNumber { get; set; }
    }

    public class LoginDTO {
        public string Email { get; set; }
        public string Password { get; set; }
    }

    public class SignUpDTO {
        public string Email { get; set; }
        public string Username { get; set; }
        public string Password { get; set; }
        public string PhoneNumber { get; set; }
    }
}
