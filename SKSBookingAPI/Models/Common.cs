using System.ComponentModel.DataAnnotations;

namespace SKSBookingAPI.Models {
    public class Common {
        [Key]
        public int ID { get; set; } // Kan erstattes med "int Id"
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }
}
