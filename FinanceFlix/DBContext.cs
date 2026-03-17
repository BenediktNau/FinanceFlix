using FinanceFlix.Models;
using Microsoft.EntityFrameworkCore;

namespace FinanceFlix;

public class DBContext : DbContext
{
    public DbSet<Transaction> Transactions { get; set; }
    public DbSet<Account> Accounts { get; set; }
    
    public string DbPath { get; }

    public DBContext()
    {
        var folder = Environment.SpecialFolder.LocalApplicationData;
        var path = Environment.GetFolderPath(folder);
        DbPath = System.IO.Path.Join(path, "FinanceFlix.db");
    }

    // The following configures EF to create a Sqlite database file in the
    // special "local" folder for your platform.
    protected override void OnConfiguring(DbContextOptionsBuilder options)
        => options.UseSqlite($"Data Source={DbPath}");
}