using FinanceFlix.Features.MailInboxes.Commands;
using FinanceFlix.Models.Common;
using FinanceFlix.Repositories.MailInbox;
using Mediator;

namespace FinanceFlix.Features.MailInboxes.Handlers
{
    public class DeleteMailInboxHandler : IRequestHandler<DeleteMailInboxCommand, Result<bool>>
    {
        private readonly IMailInboxRepository _repository;

        public DeleteMailInboxHandler(IMailInboxRepository repository)
        {
            _repository = repository;
        }

        public async ValueTask<Result<bool>> Handle(
            DeleteMailInboxCommand request, CancellationToken cancellationToken)
        {
            try
            {
                var deleted = await _repository.DeleteAsync(request.Id, cancellationToken);
                return deleted
                    ? Result<bool>.Success(true)
                    : Result<bool>.Failure($"MailInbox {request.Id} not found.");
            }
            catch (Exception ex)
            {
                return Result<bool>.Failure(ex.Message);
            }
        }
    }
}
