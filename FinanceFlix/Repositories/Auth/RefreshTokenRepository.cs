using FinanceFlix.Models.Auth;
using Microsoft.EntityFrameworkCore;

namespace FinanceFlix.Repositories.Auth;

public class RefreshTokenRepository(DBContext db) : IRefreshTokenRepository
{
    public async Task<RefreshToken?> GetByTokenAsync(string token, CancellationToken ct = default)
        => await db.RefreshTokens.Include(rt => rt.User).FirstOrDefaultAsync(rt => rt.Token == token, ct);

    public async Task<RefreshToken> CreateAsync(RefreshToken refreshToken, CancellationToken ct = default)
    {
        db.RefreshTokens.Add(refreshToken);
        await db.SaveChangesAsync(ct);
        return refreshToken;
    }

    public async Task RevokeAsync(RefreshToken refreshToken, string? replacedByToken = null, CancellationToken ct = default)
    {
        refreshToken.IsRevoked = true;
        refreshToken.ReplacedByToken = replacedByToken;
        await db.SaveChangesAsync(ct);
    }

    public async Task RevokeAllForUserAsync(int userId, CancellationToken ct = default)
    {
        await db.RefreshTokens
            .Where(rt => rt.UserId == userId && !rt.IsRevoked)
            .ExecuteUpdateAsync(s => s.SetProperty(rt => rt.IsRevoked, true), ct);
    }
}
