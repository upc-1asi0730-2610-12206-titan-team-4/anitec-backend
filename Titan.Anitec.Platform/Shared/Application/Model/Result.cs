// Added for Enum

namespace Anitec.Platform.Shared.Application.Model;

/// <summary>
///     Generic Result class for Command Handlers in the Application Layer.
/// </summary>
/// <typeparam name="T">The type of the result value.</typeparam>
public class Result<T>
{
    // Modified constructor to include message and Enum? error
    protected Result(bool isSuccess, T? value, string message, Enum? error)
    {
        IsSuccess = isSuccess;
        Value = value;
        Message = message;
        Error = error;
    }

  
}

/// <summary>
///     Non-generic Result class for Command Handlers.
/// </summary>

public class Result : Result<object>
{
    // Modified constructor to match the base Result<object> constructor
    private Result(bool isSuccess, string message, Enum? error) : base(isSuccess, null, message, error)
    {
    }

    // Modified Success method to match new constructor
    public static Result Success()
    {
        return new Result(true, string.Empty, null);
    }

    // New Failure method using Enum? and string message
    public new static Result Failure(Enum error, string message)
    {
        return new Result(false, message, error);
    }

    // Removed old Failure(Error error) and Failure(string code, string message) methods.
}
