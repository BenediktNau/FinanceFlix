namespace $safeprojectname$.Repositories.TodoItem;
using $safeprojectname$.Models.TodoItem;

public interface ITodoItemRepository
{
    Task<List<TodoItem>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<TodoItem?> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<TodoItem> AddAsync(TodoItem todoItem, CancellationToken cancellationToken = default);
    Task<TodoItem?> UpdateAsync(TodoItem todoItem, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(int id, CancellationToken cancellationToken = default);
}
