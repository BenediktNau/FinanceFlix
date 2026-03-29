using FinanceFlix.Models.Auth;

namespace FinanceFlix.Repositories.Auth;

public interface IRefreshTokenRepository
{
    Task<RefreshToken?> GetByTokenAsync(string token, CancellationToken ct = default);
    Task<RefreshToken> CreateAsync(RefreshToken refreshToken, CancellationToken ct = default);
    Task RevokeAsync(RefreshToken refreshToken, string? replacedByToken = null, CancellationToken ct = default);
    Task RevokeAllForUserAsync(int userId, CancellationToken ct = default);
}
