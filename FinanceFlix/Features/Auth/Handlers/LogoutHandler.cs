using FinanceFlix.Features.Auth.Commands;
using FinanceFlix.Models.Common;
using FinanceFlix.Repositories.Auth;
using Mediator;

namespace FinanceFlix.Features.Auth.Handlers;

public class LogoutHandler(IRefreshTokenRepository refreshTokenRepository)
    : IRequestHandler<LogoutCommand, Result<bool>>
{
    public async ValueTask<Result<bool>> Handle(
        LogoutCommand request, CancellationToken cancellationToken)
    {
        try
        {
            var storedToken = await refreshTokenRepository.GetByTokenAsync(request.RefreshToken, cancellationToken);
            if (storedToken is null)
                return Result<bool>.Success(true); // Already gone, that's fine

            await refreshTokenRepository.RevokeAllForUserAsync(storedToken.UserId, cancellationToken);
            return Result<bool>.Success(true);
        }
        catch (Exception ex)
        {
            return Result<bool>.Failure(ex.Message);
        }
    }
}
