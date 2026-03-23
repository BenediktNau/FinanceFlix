namespace $safeprojectname$.Repositories.TodoItem;

using Microsoft.EntityFrameworkCore;
using $safeprojectname$.Models.TodoItem;

public class TodoItemRepository : ITodoItemRepository
{
    private readonly AppDbContext _db;

    public TodoItemRepository(AppDbContext db)
    {
        _db = db;
    }

    public async Task<List<TodoItem>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await _db.TodoItems.ToListAsync(cancellationToken);
    }

    public async Task<TodoItem?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        return await _db.TodoItems.FindAsync([id], cancellationToken);
    }

    public async Task<TodoItem> AddAsync(TodoItem todoItem, CancellationToken cancellationToken = default)
    {
        _db.TodoItems.Add(todoItem);
        await _db.SaveChangesAsync(cancellationToken);
        return todoItem;
    }

    public async Task<TodoItem?> UpdateAsync(TodoItem todoItem, CancellationToken cancellationToken = default)
    {
        var existing = await _db.TodoItems.FindAsync([todoItem.Id], cancellationToken);
        if (existing is null) return null;

        existing.Title = todoItem.Title;
        existing.IsCompleted = todoItem.IsCompleted;
        await _db.SaveChangesAsync(cancellationToken);
        return existing;
    }

    public async Task<bool> DeleteAsync(int id, CancellationToken cancellationToken = default)
    {
        var todoItem = await _db.TodoItems.FindAsync([id], cancellationToken);
        if (todoItem is null) return false;

        _db.TodoItems.Remove(todoItem);
        return (await _db.SaveChangesAsync(cancellationToken)) == 1;
    }
}
