using Microsoft.AspNetCore.Mvc;
using VillaWolf.Domain.Common;

namespace VillaWolf.Api.Common;

/// <summary>Maps the domain <see cref="Result"/> type onto HTTP responses with ProblemDetails.</summary>
public static class ResultExtensions
{
    public static IActionResult ToActionResult<T>(this Result<T> result, ControllerBase controller)
        => result.IsSuccess
            ? controller.Ok(result.Value)
            : controller.Problem(
                title: result.Error.Code,
                detail: result.Error.Message,
                statusCode: StatusFor(result.Error.Type));

    public static IActionResult ToActionResult(this Result result, ControllerBase controller)
        => result.IsSuccess
            ? controller.NoContent()
            : controller.Problem(
                title: result.Error.Code,
                detail: result.Error.Message,
                statusCode: StatusFor(result.Error.Type));

    private static int StatusFor(ErrorType type) => type switch
    {
        ErrorType.Validation => StatusCodes.Status400BadRequest,
        ErrorType.NotFound => StatusCodes.Status404NotFound,
        ErrorType.Conflict => StatusCodes.Status409Conflict,
        ErrorType.Unauthorized => StatusCodes.Status401Unauthorized,
        _ => StatusCodes.Status500InternalServerError
    };
}
