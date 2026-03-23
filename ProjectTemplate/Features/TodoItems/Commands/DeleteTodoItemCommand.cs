using $safeprojectname$.Models.Common;
using Mediator;

namespace $safeprojectname$.Features.TodoItems.Commands
{
    public class DeleteTodoItemCommand(int id) : IRequest<Result<bool>>
    {
        public int Id { get; } = id;
    }
}
