// ignore_for_file: type=lint
import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
import '../../models/result_of_list_of_mail_inbox.dart';
import '../../models/result_ofboolean.dart';

/// auto generated
/// Builds and executes requests for operations under \mailinbox\{account-id}
class AccountItemRequestBuilder extends BaseRequestBuilder<AccountItemRequestBuilder> {
    /// Clones the requestbuilder.
    @override
    AccountItemRequestBuilder clone() {
        return AccountItemRequestBuilder(pathParameters, requestAdapter);
    }
    /// Instantiates a new [AccountItemRequestBuilder] and sets the default values.
    ///  [pathParameters] Path parameters for the request
    ///  [requestAdapter] The request adapter to use to execute the requests.
    AccountItemRequestBuilder(Map<String, dynamic> pathParameters, RequestAdapter requestAdapter) : super(requestAdapter, "{+baseurl}/mailinbox/{account%2Did}", pathParameters) ;
    /// Instantiates a new [AccountItemRequestBuilder] and sets the default values.
    ///  [rawUrl] The raw URL to use for the request builder.
    ///  [requestAdapter] The request adapter to use to execute the requests.
    AccountItemRequestBuilder.withUrl(String rawUrl, RequestAdapter requestAdapter) : super(requestAdapter, "{+baseurl}/mailinbox/{account%2Did}", {RequestInformation.rawUrlKey : rawUrl}) ;
    ///  [requestConfiguration] Configuration for the request such as headers, query parameters, and middleware options.
    Future<ResultOfboolean?> deleteAsync([void Function(RequestConfiguration<DefaultQueryParameters>)? requestConfiguration]) async {
        var requestInfo = toDeleteRequestInformation(requestConfiguration);
        return await requestAdapter.send<ResultOfboolean>(requestInfo, ResultOfboolean.createFromDiscriminatorValue, {});
    }
    ///  [requestConfiguration] Configuration for the request such as headers, query parameters, and middleware options.
    Future<ResultOfListOfMailInbox?> getAsync([void Function(RequestConfiguration<DefaultQueryParameters>)? requestConfiguration]) async {
        var requestInfo = toGetRequestInformation(requestConfiguration);
        return await requestAdapter.send<ResultOfListOfMailInbox>(requestInfo, ResultOfListOfMailInbox.createFromDiscriminatorValue, {});
    }
    ///  [requestConfiguration] Configuration for the request such as headers, query parameters, and middleware options.
    RequestInformation toDeleteRequestInformation([void Function(RequestConfiguration<DefaultQueryParameters>)? requestConfiguration]) {
        var requestInfo = RequestInformation(httpMethod : HttpMethod.delete, urlTemplate : urlTemplate, pathParameters :  pathParameters);
        requestInfo.configure<DefaultQueryParameters>(requestConfiguration, () => DefaultQueryParameters());
        requestInfo.headers.put('Accept', 'application/json');
        return requestInfo;
    }
    ///  [requestConfiguration] Configuration for the request such as headers, query parameters, and middleware options.
    RequestInformation toGetRequestInformation([void Function(RequestConfiguration<DefaultQueryParameters>)? requestConfiguration]) {
        var requestInfo = RequestInformation(httpMethod : HttpMethod.get, urlTemplate : urlTemplate, pathParameters :  pathParameters);
        requestInfo.configure<DefaultQueryParameters>(requestConfiguration, () => DefaultQueryParameters());
        requestInfo.headers.put('Accept', 'application/json');
        return requestInfo;
    }
}
