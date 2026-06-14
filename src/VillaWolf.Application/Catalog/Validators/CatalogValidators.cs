using FluentValidation;
using VillaWolf.Application.Catalog.Dtos;

namespace VillaWolf.Application.Catalog.Validators;

public sealed class CreateCategoryRequestValidator : AbstractValidator<CreateCategoryRequest>
{
    public CreateCategoryRequestValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(80);
        RuleFor(x => x.DisplayOrder).GreaterThanOrEqualTo(0);
    }
}

public sealed class CreateServiceRequestValidator : AbstractValidator<CreateServiceRequest>
{
    public CreateServiceRequestValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(120);
        RuleFor(x => x.DurationMinutes).GreaterThan(0);
        RuleFor(x => x.BasePrice).GreaterThanOrEqualTo(0);
        RuleFor(x => x.CategoryId).NotEmpty();
    }
}

public sealed class UpdateServiceRequestValidator : AbstractValidator<UpdateServiceRequest>
{
    public UpdateServiceRequestValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(120);
        RuleFor(x => x.DurationMinutes).GreaterThan(0);
        RuleFor(x => x.BasePrice).GreaterThanOrEqualTo(0);
        RuleFor(x => x.CategoryId).NotEmpty();
    }
}

public sealed class CreateAddonRequestValidator : AbstractValidator<CreateAddonRequest>
{
    public CreateAddonRequestValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(120);
        RuleFor(x => x.ExtraDurationMinutes).GreaterThanOrEqualTo(0);
        RuleFor(x => x.ExtraPrice).GreaterThanOrEqualTo(0);
    }
}

public sealed class UpdateAddonRequestValidator : AbstractValidator<UpdateAddonRequest>
{
    public UpdateAddonRequestValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(120);
        RuleFor(x => x.ExtraDurationMinutes).GreaterThanOrEqualTo(0);
        RuleFor(x => x.ExtraPrice).GreaterThanOrEqualTo(0);
    }
}
