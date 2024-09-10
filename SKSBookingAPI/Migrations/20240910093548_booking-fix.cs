using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SKSBookingAPI.Migrations
{
    /// <inheritdoc />
    public partial class bookingfix : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Bookings_Rental_RentalID",
                table: "Bookings");

            migrationBuilder.DropForeignKey(
                name: "FK_Bookings_Users_UserRentingID",
                table: "Bookings");

            migrationBuilder.DropIndex(
                name: "IX_Bookings_RentalID",
                table: "Bookings");

            migrationBuilder.DropIndex(
                name: "IX_Bookings_UserRentingID",
                table: "Bookings");

            migrationBuilder.RenameColumn(
                name: "UserRentingID",
                table: "Bookings",
                newName: "UserID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "UserID",
                table: "Bookings",
                newName: "UserRentingID");

            migrationBuilder.CreateIndex(
                name: "IX_Bookings_RentalID",
                table: "Bookings",
                column: "RentalID");

            migrationBuilder.CreateIndex(
                name: "IX_Bookings_UserRentingID",
                table: "Bookings",
                column: "UserRentingID");

            migrationBuilder.AddForeignKey(
                name: "FK_Bookings_Rental_RentalID",
                table: "Bookings",
                column: "RentalID",
                principalTable: "Rental",
                principalColumn: "ID",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Bookings_Users_UserRentingID",
                table: "Bookings",
                column: "UserRentingID",
                principalTable: "Users",
                principalColumn: "ID",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
