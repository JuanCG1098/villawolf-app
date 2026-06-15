using FluentValidation;
using VillaWolf.Application.Notifications.Dtos;

namespace VillaWolf.Application.Notifications.Validators;

public sealed class CreateNotificationRequestValidator : AbstractValidator<CreateNotificationRequest>
{
    public CreateNotificationRequestValidator()
    {
        RuleFor(x => x.RecipientId).NotEmpty();
        RuleFor(x => x.Payload).NotEmpty().MaximumLength(1000);
    }
}
