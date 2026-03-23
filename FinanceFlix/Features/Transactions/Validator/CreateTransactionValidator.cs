using FinanceFlix.Features.Transactions.Commands;
using FluentValidation;

namespace FinanceFlix.Features.Transactions.Validator
{
    public class CreateTransactionValidator : AbstractValidator<CreateTransactionCommand>
    {
        public CreateTransactionValidator() {
            RuleFor(p => p.Amount).NotEmpty();
        }
    }
}
