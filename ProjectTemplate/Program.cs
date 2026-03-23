using System.Text.Json.Serialization;
using FluentValidation;
using $safeprojectname$;
using $safeprojectname$.Features.TodoItems.Commands;
using $safeprojectname$.Features.TodoItems.Queries;
using $safeprojectname$.Models.Common;
using $safeprojectname$.Models.TodoItem;
using $safeprojectname$.Pipeline;
using $safeprojectname$.Repositories.TodoItem;
using Mediator;

var builder = WebApplication.CreateSlimBuilder(args);

builder.Services.ConfigureHttpJsonOptions(options =>
{
    options.SerializerOptions.TypeInfoResolverChain.Insert(0, AppJsonSerializerContext.Default);
});

builder.Services.AddOpenApi()
    .AddDbContext<AppDbContext>()
    .AddValidatorsFromAssemblyContaining<Program>()
    .AddMediator(options =>
    {
        options.ServiceLifetime = ServiceLifetime.Scoped;
        options.PipelineBehaviors = [typeof(LoggingBehaviour<,>), typeof(ValidationBehaviour<,>)];
    })
    .AddScoped<ITodoItemRepository, TodoItemRepository>();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

var todoApi = app.MapGroup("/todoitem");
todoApi.MapGet("/", async (IMediator mediator) =>
    await mediator.Send(new GetAllTodoItemsQuery()));
todoApi.MapPost("/", async (CreateTodoItemRequest req, IMediator mediator) =>
    await mediator.Send(new CreateTodoItemCommand(req.Title)));
todoApi.MapPut("/{id}", async (int id, UpdateTodoItemRequest req, IMediator mediator) =>
    await mediator.Send(new UpdateTodoItemCommand(id, req.Title, req.IsCompleted)));
todoApi.MapDelete("/{id}", async (int id, IMediator mediator) =>
    await mediator.Send(new DeleteTodoItemCommand(id)));

app.Run("http://localhost:3000");

// Request body records for POST/PUT endpoints
record CreateTodoItemRequest(string Title);
record UpdateTodoItemRequest(string Title, bool IsCompleted);

[JsonSerializable(typeof(TodoItem))]
[JsonSerializable(typeof(List<TodoItem>))]
[JsonSerializable(typeof(Result<TodoItem>))]
[JsonSerializable(typeof(Result<List<TodoItem>>))]
[JsonSerializable(typeof(Result<bool>))]
[JsonSerializable(typeof(CreateTodoItemRequest))]
[JsonSerializable(typeof(UpdateTodoItemRequest))]
internal partial class AppJsonSerializerContext : JsonSerializerContext
{
}
