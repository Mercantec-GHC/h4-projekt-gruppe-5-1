namespace SKSBookingAPI.Models {
    public class Rental : Common {
        public required string Address { get; set; }
        public required int PriceDaily { get; set; }
        public required string Description { get; set; }
        public required bool IsVisibleToGuests { get; set; }
        //public required User Owner { get; set; }
    }
}
