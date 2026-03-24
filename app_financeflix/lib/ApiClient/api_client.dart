// ignore_for_file: type=lint
import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
import 'package:microsoft_kiota_serialization_form/microsoft_kiota_serialization_form.dart';
import 'package:microsoft_kiota_serialization_json/microsoft_kiota_serialization_json.dart';
import 'package:microsoft_kiota_serialization_multipart/microsoft_kiota_serialization_multipart.dart';
import 'package:microsoft_kiota_serialization_text/microsoft_kiota_serialization_text.dart';
import './account/account_request_builder.dart';
import './auth/auth_request_builder.dart';
import './features/features_request_builder.dart';
import './mailinbox/mailinbox_request_builder.dart';
import './transaction/transaction_request_builder.dart';

/// auto generated
/// The main entry point of the SDK, exposes the configuration and the fluent API.
class ApiClient extends BaseRequestBuilder<ApiClient> {
    ///  The account property
    AccountRequestBuilder get account {
        return AccountRequestBuilder(pathParameters, requestAdapter);
    }
    ///  The auth property
    AuthRequestBuilder get auth {
        return AuthRequestBuilder(pathParameters, requestAdapter);
    }
    ///  The features property
    FeaturesRequestBuilder get features {
        return FeaturesRequestBuilder(pathParameters, requestAdapter);
    }
    ///  The mailinbox property
    MailinboxRequestBuilder get mailinbox {
        return MailinboxRequestBuilder(pathParameters, requestAdapter);
    }
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
        ApiClientBuilder.registerDefaultSerializer(JsonSerializationWriterFactory.new);
        ApiClientBuilder.registerDefaultSerializer(TextSerializationWriterFactory.new);
        ApiClientBuilder.registerDefaultSerializer(FormSerializationWriterFactory.new);
        ApiClientBuilder.registerDefaultSerializer(MultipartSerializationWriterFactory.new);
        ApiClientBuilder.registerDefaultDeserializer(JsonParseNodeFactory.new);
        ApiClientBuilder.registerDefaultDeserializer(FormParseNodeFactory.new);
        ApiClientBuilder.registerDefaultDeserializer(TextParseNodeFactory.new);
        if (requestAdapter.baseUrl == null || requestAdapter.baseUrl!.isEmpty) {
            requestAdapter.baseUrl = 'http://localhost:3000';
        }
        pathParameters['baseurl'] = requestAdapter.baseUrl;
    }
}
