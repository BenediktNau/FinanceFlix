using FinanceFlix.Models.Auth;
using FinanceFlix.Models.Common;
using Mediator;

namespace FinanceFlix.Features.Auth.Commands;

public class RefreshCommand(string refreshToken) : IRequest<Result<LoginResponse>>
{
    public string RefreshToken { get; } = refreshToken;
}
