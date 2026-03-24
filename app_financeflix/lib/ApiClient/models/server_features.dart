// ignore_for_file: type=lint
import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';

/// auto generated
class ServerFeatures implements AdditionalDataHolder, Parsable {
    ///  Stores additional data not described in the OpenAPI description found when deserializing. Can be used for serialization as well.
    @override
    Map<String, Object?> additionalData;
    ///  The aiEnabled property
    bool? aiEnabled;
    ///  The mailInboxEnabled property
    bool? mailInboxEnabled;
    /// Instantiates a new [ServerFeatures] and sets the default values.
    ServerFeatures() :  
        additionalData = {};
    /// Creates a new instance of the appropriate class based on discriminator value
    ///  [parseNode] The parse node to use to read the discriminator value and create the object
    static ServerFeatures createFromDiscriminatorValue(ParseNode parseNode) {
        return ServerFeatures();
    }
    /// The deserialization information for the current model
    @override
    Map<String, void Function(ParseNode)> getFieldDeserializers() {
        var deserializerMap = <String, void Function(ParseNode)>{};
        deserializerMap['aiEnabled'] = (node) => aiEnabled = node.getBoolValue();
        deserializerMap['mailInboxEnabled'] = (node) => mailInboxEnabled = node.getBoolValue();
        return deserializerMap;
    }
    /// Serializes information the current object
    ///  [writer] Serialization writer to use to serialize this model
    @override
    void serialize(SerializationWriter writer) {
        writer.writeBoolValue('aiEnabled', value:aiEnabled);
        writer.writeBoolValue('mailInboxEnabled', value:mailInboxEnabled);
        writer.writeAdditionalData(additionalData);
    }
}
