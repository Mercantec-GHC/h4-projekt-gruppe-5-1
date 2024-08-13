namespace SKSBookingAPI.Models {
    public class Rental : Common {
        public required string Address { get; set; }
        public required float PriceDaily { get; set; }
        public required string Description { get; set; }
        public required bool IsVisibleToGuests { get; set; }
        public DateTime AvailableFrom { get; set; }
        public DateTime AvailableTo { get; set; }
        //public required User Owner { get; set; }
    }
}
