// ignore_for_file: type=lint
import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
import '../../models/login_request.dart';
import '../../models/result_ofstring.dart';

/// auto generated
/// Builds and executes requests for operations under \auth\login
class LoginRequestBuilder extends BaseRequestBuilder<LoginRequestBuilder> {
    /// Clones the requestbuilder.
    @override
    LoginRequestBuilder clone() {
        return LoginRequestBuilder(pathParameters, requestAdapter);
    }
    /// Instantiates a new [LoginRequestBuilder] and sets the default values.
    ///  [pathParameters] Path parameters for the request
    ///  [requestAdapter] The request adapter to use to execute the requests.
    LoginRequestBuilder(Map<String, dynamic> pathParameters, RequestAdapter requestAdapter) : super(requestAdapter, "{+baseurl}/auth/login", pathParameters) ;
    /// Instantiates a new [LoginRequestBuilder] and sets the default values.
    ///  [rawUrl] The raw URL to use for the request builder.
    ///  [requestAdapter] The request adapter to use to execute the requests.
    LoginRequestBuilder.withUrl(String rawUrl, RequestAdapter requestAdapter) : super(requestAdapter, "{+baseurl}/auth/login", {RequestInformation.rawUrlKey : rawUrl}) ;
    ///  [body] The request body
    ///  [requestConfiguration] Configuration for the request such as headers, query parameters, and middleware options.
    Future<ResultOfstring?> postAsync(LoginRequest body, [void Function(RequestConfiguration<DefaultQueryParameters>)? requestConfiguration]) async {
        var requestInfo = toPostRequestInformation(body, requestConfiguration);
        return await requestAdapter.send<ResultOfstring>(requestInfo, ResultOfstring.createFromDiscriminatorValue, {});
    }
    ///  [body] The request body
    ///  [requestConfiguration] Configuration for the request such as headers, query parameters, and middleware options.
    RequestInformation toPostRequestInformation(LoginRequest body, [void Function(RequestConfiguration<DefaultQueryParameters>)? requestConfiguration]) {
        var requestInfo = RequestInformation(httpMethod : HttpMethod.post, urlTemplate : urlTemplate, pathParameters :  pathParameters);
        requestInfo.configure<DefaultQueryParameters>(requestConfiguration, () => DefaultQueryParameters());
        requestInfo.headers.put('Accept', 'application/json');
        requestInfo.setContentFromParsable(requestAdapter, 'application/json', body);
        return requestInfo;
    }
}
