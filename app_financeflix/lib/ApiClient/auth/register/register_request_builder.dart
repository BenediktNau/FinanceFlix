// ignore_for_file: type=lint
import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
import '../../models/register_request.dart';
import '../../models/result_ofboolean.dart';

/// auto generated
/// Builds and executes requests for operations under \auth\register
class RegisterRequestBuilder extends BaseRequestBuilder<RegisterRequestBuilder> {
    /// Clones the requestbuilder.
    @override
    RegisterRequestBuilder clone() {
        return RegisterRequestBuilder(pathParameters, requestAdapter);
    }
    /// Instantiates a new [RegisterRequestBuilder] and sets the default values.
    ///  [pathParameters] Path parameters for the request
    ///  [requestAdapter] The request adapter to use to execute the requests.
    RegisterRequestBuilder(Map<String, dynamic> pathParameters, RequestAdapter requestAdapter) : super(requestAdapter, "{+baseurl}/auth/register", pathParameters) ;
    /// Instantiates a new [RegisterRequestBuilder] and sets the default values.
    ///  [rawUrl] The raw URL to use for the request builder.
    ///  [requestAdapter] The request adapter to use to execute the requests.
    RegisterRequestBuilder.withUrl(String rawUrl, RequestAdapter requestAdapter) : super(requestAdapter, "{+baseurl}/auth/register", {RequestInformation.rawUrlKey : rawUrl}) ;
    ///  [body] The request body
    ///  [requestConfiguration] Configuration for the request such as headers, query parameters, and middleware options.
    Future<ResultOfboolean?> postAsync(RegisterRequest body, [void Function(RequestConfiguration<DefaultQueryParameters>)? requestConfiguration]) async {
        var requestInfo = toPostRequestInformation(body, requestConfiguration);
        return await requestAdapter.send<ResultOfboolean>(requestInfo, ResultOfboolean.createFromDiscriminatorValue, {});
    }
    ///  [body] The request body
    ///  [requestConfiguration] Configuration for the request such as headers, query parameters, and middleware options.
    RequestInformation toPostRequestInformation(RegisterRequest body, [void Function(RequestConfiguration<DefaultQueryParameters>)? requestConfiguration]) {
        var requestInfo = RequestInformation(httpMethod : HttpMethod.post, urlTemplate : urlTemplate, pathParameters :  pathParameters);
        requestInfo.configure<DefaultQueryParameters>(requestConfiguration, () => DefaultQueryParameters());
        requestInfo.headers.put('Accept', 'application/json');
        requestInfo.setContentFromParsable(requestAdapter, 'application/json', body);
        return requestInfo;
    }
}
