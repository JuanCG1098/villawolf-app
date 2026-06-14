using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace VillaWolf.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddOverbooking : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsOverbooking",
                table: "Appointments",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            // Recreate the no-overlap exclusion constraint so admin-authorized overbookings
            // (IsOverbooking = true) are excluded from it and may legitimately share a slot.
            migrationBuilder.Sql(@"ALTER TABLE ""Appointments"" DROP CONSTRAINT IF EXISTS ""ex_appointments_no_overlap"";");
            migrationBuilder.Sql(@"
                ALTER TABLE ""Appointments""
                ADD CONSTRAINT ""ex_appointments_no_overlap""
                EXCLUDE USING gist (
                    ""EmployeeId"" WITH =,
                    tstzrange(""StartUtc"", ""EndUtc"") WITH &&
                ) WHERE (""Status"" NOT IN ('Cancelled', 'NoShow') AND ""IsOverbooking"" = false);");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"ALTER TABLE ""Appointments"" DROP CONSTRAINT IF EXISTS ""ex_appointments_no_overlap"";");
            migrationBuilder.Sql(@"
                ALTER TABLE ""Appointments""
                ADD CONSTRAINT ""ex_appointments_no_overlap""
                EXCLUDE USING gist (
                    ""EmployeeId"" WITH =,
                    tstzrange(""StartUtc"", ""EndUtc"") WITH &&
                ) WHERE (""Status"" NOT IN ('Cancelled', 'NoShow'));");

            migrationBuilder.DropColumn(
                name: "IsOverbooking",
                table: "Appointments");
        }
    }
}
