using System.Text;
using System.Text.Json.Serialization;
using FinanceFlix;
using FinanceFlix.Extensions;
using FinanceFlix.Features.Accounts.Commands;
using FinanceFlix.Features.Accounts.Queries;
using FinanceFlix.Features.Auth.Commands;
using FinanceFlix.Features.MailInboxes.Commands;
using FinanceFlix.Features.MailInboxes.Queries;
using FinanceFlix.Features.Transactions.Commands;
using FinanceFlix.Features.Transactions.Queries;
using FinanceFlix.Models.Account;
using FinanceFlix.Models.Auth;
using FinanceFlix.Models.Common;
using FinanceFlix.Models.MailInbox;
using FinanceFlix.Models.Transaction;
using FinanceFlix.Pipeline;
using FinanceFlix.Repositories.Account;
using FinanceFlix.Repositories.Auth;
using FinanceFlix.Repositories.MailInbox;
using FinanceFlix.Repositories.Transaction;
using FinanceFlix.Services.AI;
using FinanceFlix.Services.Auth;
using Mediator;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateSlimBuilder(args);

builder.Services.ConfigureHttpJsonOptions(options =>
{
    options.SerializerOptions.TypeInfoResolverChain.Insert(0, AppJsonSerializerContext.Default);
});

// Auth configuration
var authSettings = builder.Configuration.GetSection(AuthSettings.SectionName).Get<AuthSettings>()
    ?? new AuthSettings();
builder.Services.Configure<AuthSettings>(builder.Configuration.GetSection(AuthSettings.SectionName));

if (authSettings.Mode == "Sso")
{
    builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
        .AddJwtBearer(options =>
        {
            options.Authority = authSettings.Sso.Authority;
            options.Audience = authSettings.Sso.Audience;
        });
}
else
{
    builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
        .AddJwtBearer(options =>
        {
            options.TokenValidationParameters = new TokenValidationParameters
            {
                ValidateIssuer = true,
                ValidateAudience = true,
                ValidateLifetime = true,
                ValidateIssuerSigningKey = true,
                ValidIssuer = authSettings.Jwt.Issuer,
                ValidAudience = authSettings.Jwt.Audience,
                IssuerSigningKey = new SymmetricSecurityKey(
                    Encoding.UTF8.GetBytes(authSettings.Jwt.Secret))
            };
        });

    builder.Services.AddScoped<IUserRepository, UserRepository>();
    builder.Services.AddScoped<ITokenService, TokenService>();
}

builder.Services.AddAuthorization();

builder.Services.AddOpenApi()
    .AddDbContext<DBContext>()
    .AddMediator(options => { options.ServiceLifetime = ServiceLifetime.Scoped; options.PipelineBehaviors = [typeof(LoggingBehaviour<,>)]; })
    .AddScoped<ITransactionRepository, TransactionRepository>()
    .AddScoped<IAccountRepository, AccountRepository>()
    .AddScoped<IMailInboxRepository, MailInboxRepository>()
    .AddScoped<ICategorizationService, CategorizationService>();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseAuthentication();
app.UseAuthorization();

// Public features endpoint — no auth required
var featuresConfig = builder.Configuration.GetSection("Features");
app.MapGet("/features", () => new ServerFeatures(
    featuresConfig.GetValue<bool>("AiEnabled"),
    featuresConfig.GetValue<bool>("MailInboxEnabled")
));

// Auth endpoints (only in BuiltIn mode)
if (authSettings.Mode != "Sso")
{
    var authApi = app.MapGroup("/auth");
    authApi.MapPost("/register", async (RegisterRequest req, IMediator mediator) =>
        await mediator.Send(new RegisterCommand(req.Email, req.Password)));
    authApi.MapPost("/login", async (LoginRequest req, IMediator mediator) =>
        await mediator.Send(new LoginCommand(req.Email, req.Password)));
}

var accountApi = app.MapGroup("/account").RequireAuthorization();
accountApi.MapGet("/", async (HttpContext ctx, IMediator mediator) =>
    await mediator.Send(new GetAccountsQuery(ctx.User.GetUserId())));
accountApi.MapPost("/", async (HttpContext ctx, CreateAccountRequest req, IMediator mediator) =>
    await mediator.Send(new CreateAccountCommand(ctx.User.GetUserId(), req.AccountName, req.Balance)));
accountApi.MapPut("/{id}", async (int id, UpdateAccountRequest req, IMediator mediator) =>
    await mediator.Send(new UpdateAccountCommand(id, req.AccountName, req.Balance)));
accountApi.MapDelete("/{id}", async (int id, IMediator mediator) =>
    await mediator.Send(new DeleteAccountCommand(id)));

var transactionApi = app.MapGroup("/transaction").RequireAuthorization();
transactionApi.MapGet("/", async (IMediator mediator) =>
    await mediator.Send(new GetAllTransactionsQuery()));
transactionApi.MapPost("/", async (CreateTransactionRequest req, IMediator mediator) =>
    await mediator.Send(new CreateTransactionCommand(req.AccountId, req.Amount, req.Category, req.Date)));
transactionApi.MapPut("/{id}", async (int id, UpdateTransactionRequest req, IMediator mediator) =>
    await mediator.Send(new UpdateTransactionCommand(id, req.Amount, req.Category, req.Date)));
transactionApi.MapDelete("/{id}", async (int id, IMediator mediator) =>
    await mediator.Send(new DeleteTransactionCommand(id)));

var mailInboxApi = app.MapGroup("/mailinbox").RequireAuthorization();
mailInboxApi.MapGet("/{accountId}", async (int accountId, IMediator mediator) =>
    await mediator.Send(new GetMailInboxesByAccountQuery(accountId)));
mailInboxApi.MapPost("/", async (CreateMailInboxRequest req, IMediator mediator) =>
    await mediator.Send(new CreateMailInboxCommand(req.AccountId, req.DisplayName, req.ImapHost, req.ImapPort, req.UseSsl, req.Username, req.Password, req.FolderName)));
mailInboxApi.MapDelete("/{id}", async (int id, IMediator mediator) =>
    await mediator.Send(new DeleteMailInboxCommand(id)));

app.Run("http://0.0.0.0:3000");

// Request body records for POST/PUT endpoints
record RegisterRequest(string Email, string Password);
record LoginRequest(string Email, string Password);
record CreateAccountRequest(string AccountName, decimal Balance);
record UpdateAccountRequest(string AccountName, decimal Balance);
record CreateTransactionRequest(int AccountId, decimal Amount, TransactionCategory Category, DateTime Date);
record UpdateTransactionRequest(decimal Amount, TransactionCategory Category, DateTime Date);
record CreateMailInboxRequest(int AccountId, string DisplayName, string ImapHost, int ImapPort, bool UseSsl, string Username, string Password, string FolderName);
record ServerFeatures(bool AiEnabled, bool MailInboxEnabled);

[JsonSerializable(typeof(Account))]
[JsonSerializable(typeof(List<Account>))]
[JsonSerializable(typeof(Transaction))]
[JsonSerializable(typeof(List<Transaction>))]
[JsonSerializable(typeof(Result<Account>))]
[JsonSerializable(typeof(Result<List<Account>>))]
[JsonSerializable(typeof(Result<Transaction>))]
[JsonSerializable(typeof(Result<List<Transaction>>))]
[JsonSerializable(typeof(Result<bool>))]
[JsonSerializable(typeof(Result<string>))]
[JsonSerializable(typeof(MailInbox))]
[JsonSerializable(typeof(List<MailInbox>))]
[JsonSerializable(typeof(Result<MailInbox>))]
[JsonSerializable(typeof(Result<List<MailInbox>>))]
[JsonSerializable(typeof(RegisterRequest))]
[JsonSerializable(typeof(LoginRequest))]
[JsonSerializable(typeof(CreateMailInboxRequest))]
[JsonSerializable(typeof(CreateAccountRequest))]
[JsonSerializable(typeof(UpdateAccountRequest))]
[JsonSerializable(typeof(CreateTransactionRequest))]
[JsonSerializable(typeof(UpdateTransactionRequest))]
[JsonSerializable(typeof(ServerFeatures))]
internal partial class AppJsonSerializerContext : JsonSerializerContext
{
}
