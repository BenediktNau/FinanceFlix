using FinanceFlix.Models.Auth;

namespace FinanceFlix.Repositories.Auth;

public interface IUserRepository
{
    Task<User?> GetByEmailAsync(string email, CancellationToken ct = default);
    Task<bool> CreateAsync(User user, CancellationToken ct = default);
}
