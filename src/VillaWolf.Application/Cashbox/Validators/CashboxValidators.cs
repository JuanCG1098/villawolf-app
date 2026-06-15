using FluentValidation;
using VillaWolf.Application.Cashbox.Dtos;

namespace VillaWolf.Application.Cashbox.Validators;

public sealed class CreatePaymentRequestValidator : AbstractValidator<CreatePaymentRequest>
{
    public CreatePaymentRequestValidator()
    {
        RuleFor(x => x.Amount).GreaterThanOrEqualTo(0);
        RuleFor(x => x.DiscountAmount).GreaterThanOrEqualTo(0);
    }
}
