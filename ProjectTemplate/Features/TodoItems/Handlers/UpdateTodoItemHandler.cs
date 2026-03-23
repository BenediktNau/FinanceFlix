using $safeprojectname$.Features.TodoItems.Commands;
using $safeprojectname$.Models.Common;
using $safeprojectname$.Models.TodoItem;
using $safeprojectname$.Repositories.TodoItem;
using Mediator;

namespace $safeprojectname$.Features.TodoItems.Handlers
{
    public class UpdateTodoItemHandler : IRequestHandler<UpdateTodoItemCommand, Result<TodoItem>>
    {
        private readonly ITodoItemRepository _repository;

        public UpdateTodoItemHandler(ITodoItemRepository repository)
        {
            _repository = repository;
        }

        public async ValueTask<Result<TodoItem>> Handle(
            UpdateTodoItemCommand request, CancellationToken cancellationToken)
        {
            try
            {
                var todoItem = new TodoItem
                {
                    Id = request.Id,
                    Title = request.Title,
                    IsCompleted = request.IsCompleted
                };
                var updated = await _repository.UpdateAsync(todoItem, cancellationToken);
                if (updated is null)
                    return Result<TodoItem>.Failure($"TodoItem with Id {request.Id} not found.");

                return Result<TodoItem>.Success(updated);
            }
            catch (Exception ex)
            {
                return Result<TodoItem>.Failure(ex.Message);
            }
        }
    }
}
