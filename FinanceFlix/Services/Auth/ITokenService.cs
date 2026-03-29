using FinanceFlix.Models.Auth;

namespace FinanceFlix.Services.Auth;

public interface ITokenService
{
    int ExpirationSeconds { get; }
    string GenerateToken(string userId, string email);
    RefreshToken GenerateRefreshToken(int userId);
}
