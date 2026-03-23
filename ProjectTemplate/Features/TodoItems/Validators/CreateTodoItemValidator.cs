using $safeprojectname$.Features.TodoItems.Commands;
using FluentValidation;

namespace $safeprojectname$.Features.TodoItems.Validators
{
    public class CreateTodoItemValidator : AbstractValidator<CreateTodoItemCommand>
    {
        public CreateTodoItemValidator()
        {
            RuleFor(p => p.Title).NotEmpty().MaximumLength(200);
        }
    }
}
