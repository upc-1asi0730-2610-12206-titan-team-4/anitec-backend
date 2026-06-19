
namespace Anitec.Platform.Activities.Application.CommandServices;

public interface IFarmActivityCommandService
{
    Task<Result<FarmActivity>> Handle(CreateFarmActivityCommand command, CancellationToken cancellationToken);
    Task<Result<FarmActivity>> Handle(UpdateFarmActivityCommand command, CancellationToken cancellationToken);
    Task<Result> Handle(DeleteFarmActivityCommand command, CancellationToken cancellationToken);
}
