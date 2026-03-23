using System.Text.Json.Serialization;
using FinanceFlix;
using FinanceFlix.Features.Accounts.Commands;
using FinanceFlix.Features.Accounts.Queries;
using FinanceFlix.Features.Transactions.Commands;
using FinanceFlix.Features.Transactions.Queries;
using FinanceFlix.Models.Account;
using FinanceFlix.Models.Common;
using FinanceFlix.Models.Transaction;
using FinanceFlix.Pipeline;
using FinanceFlix.Repositories.Account;
using FinanceFlix.Repositories.Transaction;
using Mediator;

var builder = WebApplication.CreateSlimBuilder(args);

builder.Services.ConfigureHttpJsonOptions(options =>
{
    options.SerializerOptions.TypeInfoResolverChain.Insert(0, AppJsonSerializerContext.Default);
});

builder.Services.AddOpenApi()
    .AddDbContext<DBContext>()
    .AddMediator(options => { options.ServiceLifetime = ServiceLifetime.Scoped; options.PipelineBehaviors = [typeof(LoggingBehaviour<,>)]; })
    .AddScoped<ITransactionRepository, TransactionRepository>()
    .AddScoped<IAccountRepository, AccountRepository>();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

var accountApi = app.MapGroup("/account");
accountApi.MapGet("/{userId}", async (string userId, IMediator mediator) =>
    await mediator.Send(new GetAccountsQuery(userId)));
accountApi.MapPost("/", async (CreateAccountRequest req, IMediator mediator) =>
    await mediator.Send(new CreateAccountCommand(req.UserId, req.AccountName, req.Balance)));
accountApi.MapPut("/{id}", async (int id, UpdateAccountRequest req, IMediator mediator) =>
    await mediator.Send(new UpdateAccountCommand(id, req.AccountName, req.Balance)));
accountApi.MapDelete("/{id}", async (int id, IMediator mediator) =>
    await mediator.Send(new DeleteAccountCommand(id)));

var transactionApi = app.MapGroup("/transaction");
transactionApi.MapGet("/", async (IMediator mediator) =>
    await mediator.Send(new GetAllTransactionsQuery()));
transactionApi.MapPost("/", async (CreateTransactionRequest req, IMediator mediator) =>
    await mediator.Send(new CreateTransactionCommand(req.AccountId, req.Amount, req.Category, req.Date)));
transactionApi.MapPut("/{id}", async (int id, UpdateTransactionRequest req, IMediator mediator) =>
    await mediator.Send(new UpdateTransactionCommand(id, req.Amount, req.Category, req.Date)));
transactionApi.MapDelete("/{id}", async (int id, IMediator mediator) =>
    await mediator.Send(new DeleteTransactionCommand(id)));

app.Run("http://localhost:3000");

// Request body records for POST/PUT endpoints
record CreateAccountRequest(string UserId, string AccountName, decimal Balance);
record UpdateAccountRequest(string AccountName, decimal Balance);
record CreateTransactionRequest(int AccountId, decimal Amount, TransactionCategory Category, DateTime Date);
record UpdateTransactionRequest(decimal Amount, TransactionCategory Category, DateTime Date);

[JsonSerializable(typeof(Account))]
[JsonSerializable(typeof(List<Account>))]
[JsonSerializable(typeof(Transaction))]
[JsonSerializable(typeof(List<Transaction>))]
[JsonSerializable(typeof(Result<Account>))]
[JsonSerializable(typeof(Result<List<Account>>))]
[JsonSerializable(typeof(Result<Transaction>))]
[JsonSerializable(typeof(Result<List<Transaction>>))]
[JsonSerializable(typeof(Result<bool>))]
[JsonSerializable(typeof(CreateAccountRequest))]
[JsonSerializable(typeof(UpdateAccountRequest))]
[JsonSerializable(typeof(CreateTransactionRequest))]
[JsonSerializable(typeof(UpdateTransactionRequest))]
internal partial class AppJsonSerializerContext : JsonSerializerContext
{
}
