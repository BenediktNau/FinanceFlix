using $safeprojectname$.Models.Common;
using $safeprojectname$.Models.TodoItem;
using Mediator;

namespace $safeprojectname$.Features.TodoItems.Commands
{
    public class UpdateTodoItemCommand(
        int id,
        string title,
        bool isCompleted) : IRequest<Result<TodoItem>>
    {
        public int Id { get; } = id;
        public string Title { get; } = title;
        public bool IsCompleted { get; } = isCompleted;
    }
}
