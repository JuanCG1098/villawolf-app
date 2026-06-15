using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VillaWolf.Application.Dashboard;

namespace VillaWolf.Api.Controllers;

[ApiController]
[Route("api/dashboard")]
[Authorize(Roles = "Admin,Reception")]
public class DashboardController : ControllerBase
{
    private readonly IDashboardService _dashboard;

    public DashboardController(IDashboardService dashboard) => _dashboard = dashboard;

    [HttpGet("summary")]
    public async Task<IActionResult> Summary([FromQuery] DateOnly? date, CancellationToken ct)
        => Ok(await _dashboard.GetSummaryAsync(date, ct));
}
