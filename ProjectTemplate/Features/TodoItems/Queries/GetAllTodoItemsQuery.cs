using $safeprojectname$.Models.Common;
using $safeprojectname$.Models.TodoItem;
using Mediator;

namespace $safeprojectname$.Features.TodoItems.Queries
{
    public class GetAllTodoItemsQuery : IRequest<Result<List<TodoItem>>>
    {
    }
}
