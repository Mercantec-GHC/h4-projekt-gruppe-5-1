using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace SKSBookingAPI.Models {
    public class Booking {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int BookingID { get; set; }
        public required int UserID { get; set; }
        public required int RentalID { get; set; }
        public required DateTime BookedFrom { get; set; }
        public required DateTime BookedUntil { get; set; }
    }

    public class UserBookingDTO {
        public RentalDTO Rental { get; set; }
        public DateTime BookedFrom { get; set; }
        public DateTime BookedUntil { get; set; }
    }

    public class RenterBookingDTO {
        public UserRentingDTO User { get; set; }
        public RentalDTO Rental { get; set; }
        public DateTime BookedFrom { get; set; }
        public DateTime BookedUntil { get; set; }
    }

    public class CreateBookingDTO {
        public required int UserID { get; set; }
        public required int RentalID { get; set; }
        public required DateTime BookedFrom { get; set; }
        public required DateTime BookedUntil { get; set; }
    }
}
