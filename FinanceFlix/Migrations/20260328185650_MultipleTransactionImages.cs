using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FinanceFlix.Migrations
{
    /// <inheritdoc />
    public partial class MultipleTransactionImages : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // 1. Add TransactionId as nullable first so we can populate it
            migrationBuilder.AddColumn<int>(
                name: "TransactionId",
                table: "TransactionImages",
                type: "INTEGER",
                nullable: true);

            // 2. Migrate existing data: copy FK from Transactions.ImageId → TransactionImages.TransactionId
            migrationBuilder.Sql("""
                UPDATE TransactionImages
                SET TransactionId = (
                    SELECT t.Id FROM Transactions t WHERE t.ImageId = TransactionImages.Id
                )
                WHERE EXISTS (
                    SELECT 1 FROM Transactions t WHERE t.ImageId = TransactionImages.Id
                );
                DELETE FROM TransactionImages WHERE TransactionId IS NULL;
                """);

            // 3. Make TransactionId non-nullable now that data is migrated
            migrationBuilder.AlterColumn<int>(
                name: "TransactionId",
                table: "TransactionImages",
                type: "INTEGER",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "INTEGER",
                oldNullable: true);

            // 4. Drop the old ImageId column from Transactions
            migrationBuilder.DropColumn(
                name: "ImageId",
                table: "Transactions");

            // 5. Add index and FK constraint
            migrationBuilder.CreateIndex(
                name: "IX_TransactionImages_TransactionId",
                table: "TransactionImages",
                column: "TransactionId");

            migrationBuilder.AddForeignKey(
                name: "FK_TransactionImages_Transactions_TransactionId",
                table: "TransactionImages",
                column: "TransactionId",
                principalTable: "Transactions",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_TransactionImages_Transactions_TransactionId",
                table: "TransactionImages");

            migrationBuilder.DropIndex(
                name: "IX_TransactionImages_TransactionId",
                table: "TransactionImages");

            migrationBuilder.DropColumn(
                name: "TransactionId",
                table: "TransactionImages");

            migrationBuilder.AddColumn<int>(
                name: "ImageId",
                table: "Transactions",
                type: "INTEGER",
                nullable: true);
        }
    }
}
