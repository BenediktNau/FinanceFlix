namespace FinanceFlix.Models.Auth;

public class AuthSettings
{
    public const string SectionName = "Auth";
    public string Mode { get; set; } = "BuiltIn";
    public JwtSettings Jwt { get; set; } = new();
    public SsoSettings Sso { get; set; } = new();
}

public class JwtSettings
{
    public string Secret { get; set; } = string.Empty;
    public string Issuer { get; set; } = "FinanceFlix";
    public string Audience { get; set; } = "FinanceFlix";
    public int ExpirationMinutes { get; set; } = 60;
}

public class SsoSettings
{
    public string Authority { get; set; } = string.Empty;
    public string Audience { get; set; } = string.Empty;
}
