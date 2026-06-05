using Cortex.Mediator.Commands;

namespace Anitec.Platform.Shared.Infrastructure.Mediator.Cortex.Configuration;

public class LoggingCommandBehavior<TCommand>
    : ICommandPipelineBehavior<TCommand> where TCommand : ICommand
{
    
}
