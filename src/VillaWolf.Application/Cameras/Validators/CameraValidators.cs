using FluentValidation;
using VillaWolf.Application.Cameras.Dtos;

namespace VillaWolf.Application.Cameras.Validators;

public sealed class CreateCameraRequestValidator : AbstractValidator<CreateCameraRequest>
{
    public CreateCameraRequestValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(120);
        RuleFor(x => x.Location).NotEmpty().MaximumLength(80);
    }
}

public sealed class UpdateCameraRequestValidator : AbstractValidator<UpdateCameraRequest>
{
    public UpdateCameraRequestValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(120);
        RuleFor(x => x.Location).NotEmpty().MaximumLength(80);
    }
}

public sealed class ReportBatteryRequestValidator : AbstractValidator<ReportBatteryRequest>
{
    public ReportBatteryRequestValidator()
    {
        RuleFor(x => x.Level).InclusiveBetween(0, 100);
    }
}

public sealed class CreateMaintenanceRequestValidator : AbstractValidator<CreateMaintenanceRequest>
{
    public CreateMaintenanceRequestValidator()
    {
        RuleFor(x => x.Description).NotEmpty().MaximumLength(500);
    }
}
