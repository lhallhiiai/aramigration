namespace ARA.Application.Common;

/// <summary>
/// Represents the outcome of a service operation, carrying either a success value or an error message.
/// Use this as the return type for all service methods instead of throwing exceptions for business rule failures.
/// </summary>
/// <typeparam name="T">The type of the value returned on success.</typeparam>
public sealed class Result<T>
{
    private Result(T? value, string? error, bool isSuccess)
    {
        Value = value;
        Error = error;
        IsSuccess = isSuccess;
    }

    /// <summary>Gets a value indicating whether the operation succeeded.</summary>
    public bool IsSuccess { get; }

    /// <summary>Gets a value indicating whether the operation failed.</summary>
    public bool IsFailure => !IsSuccess;

    /// <summary>Gets the success value. Only valid when <see cref="IsSuccess"/> is true.</summary>
    public T? Value { get; }

    /// <summary>Gets the error message. Only valid when <see cref="IsFailure"/> is true.</summary>
    public string? Error { get; }

    /// <summary>Creates a successful result carrying the given value.</summary>
    /// <param name="value">The value to carry.</param>
    public static Result<T> Success(T value) => new(value, null, true);

    /// <summary>Creates a failed result carrying the given error message.</summary>
    /// <param name="error">A human-readable description of the failure.</param>
    public static Result<T> Failure(string error) => new(default, error, false);
}

/// <summary>
/// Non-generic result for operations that do not return a value.
/// </summary>
public sealed class Result
{
    private Result(string? error, bool isSuccess)
    {
        Error = error;
        IsSuccess = isSuccess;
    }

    /// <summary>Gets a value indicating whether the operation succeeded.</summary>
    public bool IsSuccess { get; }

    /// <summary>Gets a value indicating whether the operation failed.</summary>
    public bool IsFailure => !IsSuccess;

    /// <summary>Gets the error message. Only valid when <see cref="IsFailure"/> is true.</summary>
    public string? Error { get; }

    /// <summary>Creates a successful result.</summary>
    public static Result Success() => new(null, true);

    /// <summary>Creates a failed result carrying the given error message.</summary>
    /// <param name="error">A human-readable description of the failure.</param>
    public static Result Failure(string error) => new(error, false);
}
