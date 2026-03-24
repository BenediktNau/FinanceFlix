using FinanceFlix.Models.Auth;
using Microsoft.EntityFrameworkCore;

namespace FinanceFlix.Repositories.Auth;

public class UserRepository(DBContext db) : IUserRepository
{
    public async Task<User?> GetByEmailAsync(string email, CancellationToken ct = default)
        => await db.Users.FirstOrDefaultAsync(u => u.Email == email, ct);

    public async Task<bool> CreateAsync(User user, CancellationToken ct = default)
    {
        db.Users.Add(user);
        return await db.SaveChangesAsync(ct) == 1;
    }
}
