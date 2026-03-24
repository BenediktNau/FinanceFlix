using FinanceFlix.Models.Common;
using Mediator;

namespace FinanceFlix.Features.Auth.Commands;

public class RegisterCommand(string email, string password) : IRequest<Result<bool>>
{
    public string Email { get; } = email;
    public string Password { get; } = password;
}
