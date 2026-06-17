using Anitec.Platform.Subscriptions.Domain.Model.Entities;

namespace Anitec.Platform.Subscriptions.Application.QueryServices;

public interface IPaymentQueryService
{
    Task<IEnumerable<Payment>> Handle(int userId, CancellationToken cancellationToken);
}
