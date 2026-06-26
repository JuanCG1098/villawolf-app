using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace VillaWolf.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class RemoveCameras : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "CameraMaintenanceLogs");

            migrationBuilder.DropTable(
                name: "CameraDevices");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "CameraDevices",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    BatteryLevel = table.Column<int>(type: "integer", nullable: true),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    ExternalStreamUrl = table.Column<string>(type: "text", nullable: true),
                    LastCheckedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    Location = table.Column<string>(type: "text", nullable: false),
                    Name = table.Column<string>(type: "text", nullable: false),
                    Notes = table.Column<string>(type: "text", nullable: true),
                    PowerType = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: false),
                    Status = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CameraDevices", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "CameraMaintenanceLogs",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    BatteryLevelAfter = table.Column<int>(type: "integer", nullable: true),
                    CameraDeviceId = table.Column<Guid>(type: "uuid", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    Description = table.Column<string>(type: "text", nullable: false),
                    PerformedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    PerformedBy = table.Column<string>(type: "text", nullable: true),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CameraMaintenanceLogs", x => x.Id);
                    table.ForeignKey(
                        name: "FK_CameraMaintenanceLogs_CameraDevices_CameraDeviceId",
                        column: x => x.CameraDeviceId,
                        principalTable: "CameraDevices",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_CameraMaintenanceLogs_CameraDeviceId",
                table: "CameraMaintenanceLogs",
                column: "CameraDeviceId");
        }
    }
}
