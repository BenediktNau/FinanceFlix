using $safeprojectname$.Features.TodoItems.Commands;
using $safeprojectname$.Models.Common;
using $safeprojectname$.Repositories.TodoItem;
using Mediator;

namespace $safeprojectname$.Features.TodoItems.Handlers
{
    public class DeleteTodoItemHandler : IRequestHandler<DeleteTodoItemCommand, Result<bool>>
    {
        private readonly ITodoItemRepository _repository;

        public DeleteTodoItemHandler(ITodoItemRepository repository)
        {
            _repository = repository;
        }

        public async ValueTask<Result<bool>> Handle(
            DeleteTodoItemCommand request, CancellationToken cancellationToken)
        {
            try
            {
                var deleted = await _repository.DeleteAsync(request.Id, cancellationToken);
                if (!deleted)
                    return Result<bool>.Failure($"TodoItem with Id {request.Id} not found.");

                return Result<bool>.Success(true);
            }
            catch (Exception ex)
            {
                return Result<bool>.Failure(ex.Message);
            }
        }
    }
}
