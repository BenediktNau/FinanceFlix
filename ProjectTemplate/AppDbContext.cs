using $safeprojectname$.Models.TodoItem;
using Microsoft.EntityFrameworkCore;

namespace $safeprojectname$;

public class AppDbContext : DbContext
{
    public DbSet<TodoItem> TodoItems { get; set; }

    public string DbPath { get; }

    public AppDbContext()
    {
        var folder = Environment.SpecialFolder.LocalApplicationData;
        var path = Environment.GetFolderPath(folder);
        DbPath = System.IO.Path.Join(path, "$safeprojectname$.db");
    }

    protected override void OnConfiguring(DbContextOptionsBuilder options)
        => options.UseSqlite($"Data Source={DbPath}");
}
