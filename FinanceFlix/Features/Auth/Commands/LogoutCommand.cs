using FinanceFlix.Models.Common;
using Mediator;

namespace FinanceFlix.Features.Auth.Commands;

public class LogoutCommand(string refreshToken) : IRequest<Result<bool>>
{
    public string RefreshToken { get; } = refreshToken;
}
