using FinanceFlix.Features.Auth.Commands;
using FinanceFlix.Models.Auth;
using FinanceFlix.Models.Common;
using FinanceFlix.Repositories.Auth;
using Mediator;

namespace FinanceFlix.Features.Auth.Handlers;

public class RegisterHandler(IUserRepository userRepository)
    : IRequestHandler<RegisterCommand, Result<bool>>
{
    public async ValueTask<Result<bool>> Handle(
        RegisterCommand request, CancellationToken cancellationToken)
    {
        try
        {
            var existing = await userRepository.GetByEmailAsync(request.Email, cancellationToken);
            if (existing is not null)
                return Result<bool>.Failure("A user with this email already exists.");

            var user = new User
            {
                Email = request.Email,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
                CreatedAt = DateTime.UtcNow
            };

            var created = await userRepository.CreateAsync(user, cancellationToken);
            return Result<bool>.Success(created);
        }
        catch (Exception ex)
        {
            return Result<bool>.Failure(ex.Message);
        }
    }
}
