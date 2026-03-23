using $safeprojectname$.Features.TodoItems.Commands;
using $safeprojectname$.Models.Common;
using $safeprojectname$.Models.TodoItem;
using $safeprojectname$.Repositories.TodoItem;
using Mediator;

namespace $safeprojectname$.Features.TodoItems.Handlers
{
    public class CreateTodoItemHandler : IRequestHandler<CreateTodoItemCommand, Result<TodoItem>>
    {
        private readonly ITodoItemRepository _repository;

        public CreateTodoItemHandler(ITodoItemRepository repository)
        {
            _repository = repository;
        }

        public async ValueTask<Result<TodoItem>> Handle(
            CreateTodoItemCommand request, CancellationToken cancellationToken)
        {
            try
            {
                var todoItem = new TodoItem
                {
                    Title = request.Title,
                    IsCompleted = false,
                    CreatedAt = DateTime.UtcNow
                };
                var created = await _repository.AddAsync(todoItem, cancellationToken);
                return Result<TodoItem>.Success(created);
            }
            catch (Exception ex)
            {
                return Result<TodoItem>.Failure(ex.Message);
            }
        }
    }
}
