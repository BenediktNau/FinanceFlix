using Mediator;
using System.Diagnostics;

namespace FinanceFlix.Pipeline
{
    public class LoggingBehaviour<TMessage, TResponse>(ILogger<LoggingBehaviour<TMessage, TResponse>> logger) : IPipelineBehavior<TMessage, TResponse> where TMessage : IMessage
    {
        public async ValueTask<TResponse> Handle(TMessage message, MessageHandlerDelegate<TMessage, TResponse> next, CancellationToken cancellationToken)
        {
            var correlationId = Guid.NewGuid();
            var name = typeof(TMessage).Name;
            logger.LogInformation("Handling {Request}", name);

            var sw = Stopwatch.StartNew();
            try
            {
                var response = await next(message, cancellationToken);
                sw.Stop();
                logger.LogInformation("Handled {Request} in {Elapsed}ms", name, sw.ElapsedMilliseconds);
                return response;
            }
            catch (Exception ex)
            {
                sw.Stop();
                logger.LogError(ex, "Error handling {Request} after {Elapsed}ms \n CorrelationID: {Correlation} ", name, sw.ElapsedMilliseconds, correlationId);
                throw;
            }
        }
    }
}
