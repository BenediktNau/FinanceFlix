using FinanceFlix.Models.Account;
using FinanceFlix.Models.Auth;
using FinanceFlix.Models.MailInbox;
using FinanceFlix.Models.RecurringTransaction;
using FinanceFlix.Models.Transaction;
using FinanceFlix.Models.TransactionImage;
using Microsoft.EntityFrameworkCore;

namespace FinanceFlix;

public class DBContext : DbContext
{
    public DbSet<Transaction> Transactions { get; set; }
    public DbSet<Account> Accounts { get; set; }
    public DbSet<MailInbox> MailInboxes { get; set; }
    public DbSet<TransactionImage> TransactionImages { get; set; }
    public DbSet<User> Users { get; set; }
    public DbSet<RefreshToken> RefreshTokens { get; set; }
    public DbSet<RecurringTransaction> RecurringTransactions { get; set; }
    
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

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Transaction>()
            .HasMany(t => t.Images)
            .WithOne()
            .HasForeignKey(i => i.TransactionId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<RefreshToken>()
            .HasOne(rt => rt.User)
            .WithMany()
            .HasForeignKey(rt => rt.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<RefreshToken>()
            .HasIndex(rt => rt.Token)
            .IsUnique();
    }
}