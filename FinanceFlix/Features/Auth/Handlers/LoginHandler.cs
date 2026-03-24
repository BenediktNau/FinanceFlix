using FinanceFlix.Features.Auth.Commands;
using FinanceFlix.Models.Common;
using FinanceFlix.Repositories.Auth;
using FinanceFlix.Services.Auth;
using Mediator;

namespace FinanceFlix.Features.Auth.Handlers;

public class LoginHandler(IUserRepository userRepository, ITokenService tokenService)
    : IRequestHandler<LoginCommand, Result<string>>
{
    public async ValueTask<Result<string>> Handle(
        LoginCommand request, CancellationToken cancellationToken)
    {
        try
        {
            var user = await userRepository.GetByEmailAsync(request.Email, cancellationToken);
            if (user is null)
                return Result<string>.Failure("Invalid email or password.");

            if (!BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
                return Result<string>.Failure("Invalid email or password.");

            var token = tokenService.GenerateToken(user.Id.ToString(), user.Email);
            return Result<string>.Success(token);
        }
        catch (Exception ex)
        {
            return Result<string>.Failure(ex.Message);
        }
    }
}
