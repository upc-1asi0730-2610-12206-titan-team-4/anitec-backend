using System.Net.Mime;
using Anitec.Platform.Subscriptions.Application.CommandServices;
using Anitec.Platform.Subscriptions.Application.QueryServices;
using Anitec.Platform.Subscriptions.Domain.Model.Commands;
using Anitec.Platform.Subscriptions.Domain.Model.Queries;
using Anitec.Platform.Subscriptions.Interfaces.Rest.Resources;
using Anitec.Platform.Subscriptions.Interfaces.Rest.Transform;
using Microsoft.AspNetCore.Mvc;
using Swashbuckle.AspNetCore.Annotations;

namespace Anitec.Platform.Subscriptions.Interfaces.Rest;

[ApiController]
[Route("api/v1/subscriptions")]
[Produces(MediaTypeNames.Application.Json)]
[SwaggerTag("Available Subscriptions endpoints")]
public class SubscriptionsController(
    ISubscriptionCommandService commandService,
    ISubscriptionQueryService queryService,
    IPaymentCommandService paymentCommandService,
    IPaymentQueryService paymentQueryService) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        var result = await queryService.Handle(new GetAllSubscriptionsQuery(), cancellationToken);
        return Ok(result.Select(SubscriptionResourceFromEntityAssembler.ToResourceFromEntity));
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id, CancellationToken cancellationToken)
    {
        var result = await queryService.Handle(new GetSubscriptionByIdQuery(id), cancellationToken);
        if (result is null) return NotFound();
        return Ok(SubscriptionResourceFromEntityAssembler.ToResourceFromEntity(result));
    }

    [HttpPost]
    public async Task<IActionResult> Create(CreateSubscriptionResource resource, CancellationToken cancellationToken)
    {
        var command = CreateSubscriptionCommandFromResourceAssembler.ToCommandFromResource(resource);
        var result = await commandService.Handle(command, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = result.Value!.Id },
            SubscriptionResourceFromEntityAssembler.ToResourceFromEntity(result.Value));
    }

    [HttpGet("users/{userId:int}/active")]
    public async Task<IActionResult> GetActiveByUser(int userId, CancellationToken cancellationToken)
    {
        var subscriptions = await queryService.Handle(new GetAllSubscriptionsQuery(), cancellationToken);
        var subscription = subscriptions
            .Where(item => item.UserId == userId)
            .Where(item => item.Status.Equals("Active", StringComparison.OrdinalIgnoreCase))
            .OrderByDescending(item => item.StartedAt)
            .FirstOrDefault();

        if (subscription is null) return NotFound();

        return Ok(SubscriptionResourceFromEntityAssembler.ToResourceFromEntity(subscription));
    }

    [HttpGet("users/{userId:int}/payments")]
    public async Task<IActionResult> GetPaymentsByUser(int userId, CancellationToken cancellationToken)
    {
        var payments = await paymentQueryService.Handle(userId, cancellationToken);
        return Ok(payments.Select(PaymentResourceFromEntityAssembler.ToResourceFromEntity));
    }

    [HttpPost("mock-checkout")]
    public async Task<IActionResult> MockCheckout(MockCheckoutResource resource, CancellationToken cancellationToken)
    {
        var subscriptionCommand = new CreateSubscriptionCommand(
            resource.UserId,
            resource.PlanId,
            $"mock_customer_{resource.UserId}",
            $"mock_subscription_{Guid.NewGuid():N}",
            "Active",
            DateOnly.FromDateTime(DateTime.UtcNow),
            null);

        var subscriptionResult = await commandService.Handle(subscriptionCommand, cancellationToken);
        if (subscriptionResult.IsFailure) return BadRequest(new { message = subscriptionResult.Message });

        var paymentCommand = new CreatePaymentCommand(
            resource.UserId,
            subscriptionResult.Value!.Id,
            resource.Amount,
            resource.Currency,
            "MockStripe",
            $"mock_payment_{Guid.NewGuid():N}",
            "Paid",
            DateTime.UtcNow);

        var paymentResult = await paymentCommandService.Handle(paymentCommand, cancellationToken);
        if (paymentResult.IsFailure) return BadRequest(new { message = paymentResult.Message });

        return Ok(new MockCheckoutResultResource(
            SubscriptionResourceFromEntityAssembler.ToResourceFromEntity(subscriptionResult.Value),
            PaymentResourceFromEntityAssembler.ToResourceFromEntity(paymentResult.Value!)));
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, CreateSubscriptionResource resource, CancellationToken cancellationToken)
    {
        var command = UpdateSubscriptionCommandFromResourceAssembler.ToCommandFromResource(id, resource);
        var result = await commandService.Handle(command, cancellationToken);
        if (result.IsFailure) return NotFound();
        return Ok(SubscriptionResourceFromEntityAssembler.ToResourceFromEntity(result.Value!));
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id, CancellationToken cancellationToken)
    {
        var result = await commandService.Handle(new DeleteSubscriptionCommand(id), cancellationToken);
        if (result.IsFailure) return NotFound();
        return NoContent();
    }
}
