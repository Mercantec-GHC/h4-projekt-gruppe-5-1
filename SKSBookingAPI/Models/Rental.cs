using System.Collections;

namespace SKSBookingAPI.Models {
    public class Rental : Common {
        public required string Address { get; set; }
        public required float PriceDaily { get; set; }
        public required string Description { get; set; }
        public required bool IsVisibleToGuests { get; set; }
        public DateTime AvailableFrom { get; set; }
        public DateTime AvailableTo { get; set; }
        public required int UserID { get; set; }
        //public required User Owner { get; set; }
    }

    public class RentalDTO {
        public string Address { get; set; }
        public string Description { get; set; }
        public float PriceDaily { get; set; }
        public DateTime AvailableFrom { get; set; }
        public DateTime AvailableTo { get; set; }
        public UserRentingDTO Owner { get; set; }
        // public ICollection<RentalImage> RentalImages { get; set; }
    }

    public class AllRentalsDTO {
        public int ID { get; set; }
        public string Address { get; set; }
        public float PriceDaily { get; set; }
        public DateTime AvailableFrom { get; set; }
        public DateTime AvailableTo { get; set; }
        // public ICollection<RentalImage> RentalImages { get; set; }
    }

    public class CreateRentalDTO {
        public required string Address { get; set; }
        public required float PriceDaily { get; set; }
        public required string Description { get; set; }
        public required bool IsVisibleToGuests { get; set; }
        public DateTime AvailableFrom { get; set; }
        public DateTime AvailableTo { get; set; }
        public required int UserID { get; set; }
    }

    //public class RentalImage
    //{
    //public string Image { get; set; }
    //}
}
