using FinanceFlix.Features.Auth.Commands;
using FinanceFlix.Models.Auth;
using FinanceFlix.Models.Common;
using FinanceFlix.Repositories.Auth;
using FinanceFlix.Services.Auth;
using Mediator;

namespace FinanceFlix.Features.Auth.Handlers;

public class RefreshHandler(IRefreshTokenRepository refreshTokenRepository, ITokenService tokenService)
    : IRequestHandler<RefreshCommand, Result<LoginResponse>>
{
    public async ValueTask<Result<LoginResponse>> Handle(
        RefreshCommand request, CancellationToken cancellationToken)
    {
        try
        {
            var storedToken = await refreshTokenRepository.GetByTokenAsync(request.RefreshToken, cancellationToken);
            if (storedToken is null)
                return Result<LoginResponse>.Failure("Invalid refresh token.");

            // Reuse detection: if token was already revoked, revoke ALL tokens for this user
            if (storedToken.IsRevoked)
            {
                await refreshTokenRepository.RevokeAllForUserAsync(storedToken.UserId, cancellationToken);
                return Result<LoginResponse>.Failure("Refresh token has been revoked. Please login again.");
            }

            if (storedToken.ExpiresAt < DateTime.UtcNow)
                return Result<LoginResponse>.Failure("Refresh token has expired. Please login again.");

            // Token rotation: revoke old, create new
            var newRefreshToken = tokenService.GenerateRefreshToken(storedToken.UserId);
            await refreshTokenRepository.RevokeAsync(storedToken, newRefreshToken.Token, cancellationToken);
            await refreshTokenRepository.CreateAsync(newRefreshToken, cancellationToken);

            var accessToken = tokenService.GenerateToken(
                storedToken.User.Id.ToString(),
                storedToken.User.Email);

            return Result<LoginResponse>.Success(new LoginResponse
            {
                AccessToken = accessToken,
                RefreshToken = newRefreshToken.Token,
                ExpiresIn = tokenService.ExpirationSeconds
            });
        }
        catch (Exception ex)
        {
            return Result<LoginResponse>.Failure(ex.Message);
        }
    }
}
