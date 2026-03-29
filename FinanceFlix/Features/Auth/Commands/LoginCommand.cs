using FinanceFlix.Models.Auth;
using FinanceFlix.Models.Common;
using Mediator;

namespace FinanceFlix.Features.Auth.Commands;

public class LoginCommand(string email, string password) : IRequest<Result<LoginResponse>>
{
    public string Email { get; } = email;
    public string Password { get; } = password;
}
