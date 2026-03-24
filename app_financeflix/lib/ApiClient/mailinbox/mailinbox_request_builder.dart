// ignore_for_file: type=lint
import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
import '../models/create_mail_inbox_request.dart';
import '../models/result_of_mail_inbox.dart';
import './item/account_item_request_builder.dart';

/// auto generated
/// Builds and executes requests for operations under \mailinbox
class MailinboxRequestBuilder extends BaseRequestBuilder<MailinboxRequestBuilder> {
    /// Gets an item from the ApiSDK.mailinbox.item collection
    ///  [accountId] Unique identifier of the item
    AccountItemRequestBuilder byAccountId(String accountId) {
        var urlTplParams = Map.of(pathParameters);
        urlTplParams.putIfAbsent('account%2Did', () => accountId);
        return AccountItemRequestBuilder(urlTplParams, requestAdapter);
    }
    /// Clones the requestbuilder.
    @override
    MailinboxRequestBuilder clone() {
        return MailinboxRequestBuilder(pathParameters, requestAdapter);
    }
    /// Instantiates a new [MailinboxRequestBuilder] and sets the default values.
    ///  [pathParameters] Path parameters for the request
    ///  [requestAdapter] The request adapter to use to execute the requests.
    MailinboxRequestBuilder(Map<String, dynamic> pathParameters, RequestAdapter requestAdapter) : super(requestAdapter, "{+baseurl}/mailinbox", pathParameters) ;
    /// Instantiates a new [MailinboxRequestBuilder] and sets the default values.
    ///  [rawUrl] The raw URL to use for the request builder.
    ///  [requestAdapter] The request adapter to use to execute the requests.
    MailinboxRequestBuilder.withUrl(String rawUrl, RequestAdapter requestAdapter) : super(requestAdapter, "{+baseurl}/mailinbox", {RequestInformation.rawUrlKey : rawUrl}) ;
    ///  [body] The request body
    ///  [requestConfiguration] Configuration for the request such as headers, query parameters, and middleware options.
    Future<ResultOfMailInbox?> postAsync(CreateMailInboxRequest body, [void Function(RequestConfiguration<DefaultQueryParameters>)? requestConfiguration]) async {
        var requestInfo = toPostRequestInformation(body, requestConfiguration);
        return await requestAdapter.send<ResultOfMailInbox>(requestInfo, ResultOfMailInbox.createFromDiscriminatorValue, {});
    }
    ///  [body] The request body
    ///  [requestConfiguration] Configuration for the request such as headers, query parameters, and middleware options.
    RequestInformation toPostRequestInformation(CreateMailInboxRequest body, [void Function(RequestConfiguration<DefaultQueryParameters>)? requestConfiguration]) {
        var requestInfo = RequestInformation(httpMethod : HttpMethod.post, urlTemplate : urlTemplate, pathParameters :  pathParameters);
        requestInfo.configure<DefaultQueryParameters>(requestConfiguration, () => DefaultQueryParameters());
        requestInfo.headers.put('Accept', 'application/json');
        requestInfo.setContentFromParsable(requestAdapter, 'application/json', body);
        return requestInfo;
    }
}
