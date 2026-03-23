// ignore_for_file: type=lint
import 'package:app_financeflix/ApiClient/transaction/transaction_request_builder.dart';
import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
/// auto generated
/// The main entry point of the SDK, exposes the configuration and the fluent API.
class ApiClient extends BaseRequestBuilder<ApiClient> {
    ///  The transaction property
    TransactionRequestBuilder get transaction {
        return TransactionRequestBuilder(pathParameters, requestAdapter);
    }
    /// Clones the requestbuilder.
    @override
    ApiClient clone() {
        return ApiClient(requestAdapter);
    }
    /// Instantiates a new [ApiClient] and sets the default values.
    ///  [requestAdapter] The request adapter to use to execute the requests.
    ApiClient(RequestAdapter requestAdapter) : super(requestAdapter, "{+baseurl}", {}) {
        if (requestAdapter.baseUrl == null || requestAdapter.baseUrl!.isEmpty) {
            requestAdapter.baseUrl = 'http://localhost:3000';
        }
        pathParameters['baseurl'] = requestAdapter.baseUrl;
    }
}
