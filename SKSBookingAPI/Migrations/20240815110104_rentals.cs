using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SKSBookingAPI.Migrations
{
    /// <inheritdoc />
    public partial class rentals : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Rental_Users_UserID",
                table: "Rental");

            migrationBuilder.AlterColumn<int>(
                name: "UserID",
                table: "Rental",
                type: "integer",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "integer",
                oldNullable: true);

            migrationBuilder.AddForeignKey(
                name: "FK_Rental_Users_UserID",
                table: "Rental",
                column: "UserID",
                principalTable: "Users",
                principalColumn: "ID",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Rental_Users_UserID",
                table: "Rental");

            migrationBuilder.AlterColumn<int>(
                name: "UserID",
                table: "Rental",
                type: "integer",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "integer");

            migrationBuilder.AddForeignKey(
                name: "FK_Rental_Users_UserID",
                table: "Rental",
                column: "UserID",
                principalTable: "Users",
                principalColumn: "ID");
        }
    }
}
