using System.Text.Json.Serialization;
using FinanceFlix;
using FinanceFlix.Features.Transactions.Queries;
using Mediator;
using Microsoft.AspNetCore.Http.HttpResults;

var builder = WebApplication.CreateSlimBuilder(args);

builder.Services.ConfigureHttpJsonOptions(options =>
{
    options.SerializerOptions.TypeInfoResolverChain.Insert(0, AppJsonSerializerContext.Default);
});

// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi()
    .AddDbContext<DBContext>()
    .AddMediator();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

Todo[] sampleTodos =
[
    new(1, "Walk the dog"),
    new(2, "Do the dishes", DateOnly.FromDateTime(DateTime.Now)),
    new(3, "Do the laundry", DateOnly.FromDateTime(DateTime.Now.AddDays(1))),
    new(4, "Clean the bathroom"),
    new(5, "Clean the car", DateOnly.FromDateTime(DateTime.Now.AddDays(2)))
];

var todosApi = app.MapGroup("/todos");
todosApi.MapGet("/", () => sampleTodos)
    .WithName("GetTodos");

todosApi.MapGet("/{id}", Results<Ok<Todo>, NotFound> (int id) =>
        sampleTodos.FirstOrDefault(a => a.Id == id) is { } todo
            ? TypedResults.Ok(todo)
            : TypedResults.NotFound())
    .WithName("GetTodoById");



var balanceApi = app.MapGroup("/balance");



var transactionApi = app.MapGroup("/transaction");
transactionApi.MapGet("/", async (IMediator mediator) =>
    await mediator.Send(new GetAllTransactionsQuery()));


app.Run("http://localhost:3000");

public record Todo(int Id, string? Title, DateOnly? DueBy = null, bool IsComplete = false);

[JsonSerializable(typeof(Todo[]))]
internal partial class AppJsonSerializerContext : JsonSerializerContext
{
}