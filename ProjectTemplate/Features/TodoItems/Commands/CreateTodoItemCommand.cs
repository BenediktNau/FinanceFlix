using $safeprojectname$.Models.Common;
using $safeprojectname$.Models.TodoItem;
using Mediator;

namespace $safeprojectname$.Features.TodoItems.Commands
{
    public class CreateTodoItemCommand(
        string title) : IRequest<Result<TodoItem>>
    {
        public string Title { get; } = title;
    }
}
