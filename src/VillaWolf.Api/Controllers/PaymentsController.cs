using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VillaWolf.Api.Common;
using VillaWolf.Application.Cashbox;
using VillaWolf.Application.Cashbox.Dtos;

namespace VillaWolf.Api.Controllers;

[ApiController]
[Route("api/payments")]
[Authorize(Roles = "Admin,Reception")]
public class PaymentsController : ControllerBase
{
    private readonly ICashboxService _cashbox;

    public PaymentsController(ICashboxService cashbox) => _cashbox = cashbox;

    [HttpGet]
    public async Task<IActionResult> List([FromQuery] DateTime? fromUtc, [FromQuery] DateTime? toUtc, CancellationToken ct)
        => Ok(await _cashbox.ListAsync(fromUtc, toUtc, ct));

    [HttpGet("summary")]
    public async Task<IActionResult> Summary([FromQuery] DateOnly? date, CancellationToken ct)
    {
        var day = date ?? DateOnly.FromDateTime(DateTime.UtcNow);
        return Ok(await _cashbox.GetSummaryAsync(day, ct));
    }

    [HttpPost]
    public async Task<IActionResult> Register([FromBody] CreatePaymentRequest request, CancellationToken ct)
        => (await _cashbox.RegisterAsync(request, CurrentUserId(), ct)).ToActionResult(this);

    private Guid? CurrentUserId()
    {
        var raw = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub");
        return Guid.TryParse(raw, out var id) ? id : null;
    }
}
