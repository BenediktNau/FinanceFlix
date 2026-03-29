using FinanceFlix.Features.Auth.Commands;
using FinanceFlix.Models.Auth;
using FinanceFlix.Models.Common;
using FinanceFlix.Repositories.Auth;
using FinanceFlix.Services.Auth;
using Mediator;

namespace FinanceFlix.Features.Auth.Handlers;

public class LoginHandler(IUserRepository userRepository, ITokenService tokenService, IRefreshTokenRepository refreshTokenRepository)
    : IRequestHandler<LoginCommand, Result<LoginResponse>>
{
    public async ValueTask<Result<LoginResponse>> Handle(
        LoginCommand request, CancellationToken cancellationToken)
    {
        try
        {
            var user = await userRepository.GetByEmailAsync(request.Email, cancellationToken);
            if (user is null)
                return Result<LoginResponse>.Failure("Invalid email or password.");

            if (!BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
                return Result<LoginResponse>.Failure("Invalid email or password.");

            var accessToken = tokenService.GenerateToken(user.Id.ToString(), user.Email);
            var refreshToken = tokenService.GenerateRefreshToken(user.Id);
            await refreshTokenRepository.CreateAsync(refreshToken, cancellationToken);

            return Result<LoginResponse>.Success(new LoginResponse
            {
                AccessToken = accessToken,
                RefreshToken = refreshToken.Token,
                ExpiresIn = tokenService.ExpirationSeconds
            });
        }
        catch (Exception ex)
        {
            return Result<LoginResponse>.Failure(ex.Message);
        }
    }
}
