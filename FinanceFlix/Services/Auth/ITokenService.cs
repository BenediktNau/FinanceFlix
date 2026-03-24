namespace FinanceFlix.Services.Auth;

public interface ITokenService
{
    string GenerateToken(string userId, string email);
}
