using FinanceFlix.Models.Common;
using Mediator;

namespace FinanceFlix.Features.Auth.Commands;

public class LoginCommand(string email, string password) : IRequest<Result<string>>
{
    public string Email { get; } = email;
    public string Password { get; } = password;
}
