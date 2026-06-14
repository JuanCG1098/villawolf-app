using FluentValidation;
using VillaWolf.Application.Scheduling.Dtos;

namespace VillaWolf.Application.Scheduling.Validators;

public sealed class CreateWorkingHourRequestValidator : AbstractValidator<CreateWorkingHourRequest>
{
    public CreateWorkingHourRequestValidator()
    {
        RuleFor(x => x.EndTime).GreaterThan(x => x.StartTime);
    }
}

public sealed class CreateTimeBlockRequestValidator : AbstractValidator<CreateTimeBlockRequest>
{
    public CreateTimeBlockRequestValidator()
    {
        RuleFor(x => x.EndUtc).GreaterThan(x => x.StartUtc);
    }
}
