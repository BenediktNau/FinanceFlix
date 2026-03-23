using $safeprojectname$.Features.TodoItems.Queries;
using $safeprojectname$.Models.Common;
using $safeprojectname$.Models.TodoItem;
using $safeprojectname$.Repositories.TodoItem;
using Mediator;

namespace $safeprojectname$.Features.TodoItems.Handlers
{
    public class GetAllTodoItemsHandler : IRequestHandler<GetAllTodoItemsQuery, Result<List<TodoItem>>>
    {
        private readonly ITodoItemRepository _repository;

        public GetAllTodoItemsHandler(ITodoItemRepository repository)
        {
            _repository = repository;
        }

        public async ValueTask<Result<List<TodoItem>>> Handle(
            GetAllTodoItemsQuery request, CancellationToken cancellationToken)
        {
            try
            {
                var todoItems = await _repository.GetAllAsync(cancellationToken);
                return Result<List<TodoItem>>.Success(todoItems);
            }
            catch (Exception ex)
            {
                return Result<List<TodoItem>>.Failure(ex.Message);
            }
        }
    }
}
