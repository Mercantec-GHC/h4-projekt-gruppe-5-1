using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SKSBookingAPI.Migrations
{
    /// <inheritdoc />
    public partial class gallerifotos : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string[]>(
                name: "GalleryURLs",
                table: "Rental",
                type: "text[]",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "GalleryURLs",
                table: "Rental");
        }
    }
}
