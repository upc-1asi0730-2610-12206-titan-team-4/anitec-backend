namespace Cortex.Mediator.Commands;

public interface ICommand
{
}

public delegate Task CommandHandlerDelegate();

public interface ICommandPipelineBehavior<in TCommand>
    where TCommand : ICommand
{
    Task Handle(TCommand command, CommandHandlerDelegate next, CancellationToken cancellationToken);
}
