namespace SKSBookingAPI.Models {
    public class Booking {
        public required int BookingID { get; set; }
        public required User UserRenting { get; set; }
        public required Rental Rental { get; set; }
        public required DateTime BookedFrom { get; set; }
        public required DateTime BookedUntil { get; set; }
    }

    public class BookingDTO
    {
        public int BookingID { get; set; }
        public Rental Rental { get; set; }
        public DateTime BookedFrom { get; set; }
        public DateTime BookedUntil { get; set; }
    }
}
