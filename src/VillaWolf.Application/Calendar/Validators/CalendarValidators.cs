using FluentValidation;
using VillaWolf.Application.Calendar.Dtos;

namespace VillaWolf.Application.Calendar.Validators;

public sealed class ConnectCalendarRequestValidator : AbstractValidator<ConnectCalendarRequest>
{
    public ConnectCalendarRequestValidator()
    {
        RuleFor(x => x.GoogleCalendarId).NotEmpty().MaximumLength(200);
    }
}
