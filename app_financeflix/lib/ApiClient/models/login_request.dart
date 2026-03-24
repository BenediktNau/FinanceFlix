// ignore_for_file: type=lint
import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';

/// auto generated
class LoginRequest implements AdditionalDataHolder, Parsable {
    ///  Stores additional data not described in the OpenAPI description found when deserializing. Can be used for serialization as well.
    @override
    Map<String, Object?> additionalData;
    ///  The email property
    String? email;
    ///  The password property
    String? password;
    /// Instantiates a new [LoginRequest] and sets the default values.
    LoginRequest() :  
        additionalData = {};
    /// Creates a new instance of the appropriate class based on discriminator value
    ///  [parseNode] The parse node to use to read the discriminator value and create the object
    static LoginRequest createFromDiscriminatorValue(ParseNode parseNode) {
        return LoginRequest();
    }
    /// The deserialization information for the current model
    @override
    Map<String, void Function(ParseNode)> getFieldDeserializers() {
        var deserializerMap = <String, void Function(ParseNode)>{};
        deserializerMap['email'] = (node) => email = node.getStringValue();
        deserializerMap['password'] = (node) => password = node.getStringValue();
        return deserializerMap;
    }
    /// Serializes information the current object
    ///  [writer] Serialization writer to use to serialize this model
    @override
    void serialize(SerializationWriter writer) {
        writer.writeStringValue('email', email);
        writer.writeStringValue('password', password);
        writer.writeAdditionalData(additionalData);
    }
}
