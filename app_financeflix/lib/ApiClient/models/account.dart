// ignore_for_file: type=lint
import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';

/// auto generated
class Account implements AdditionalDataHolder, Parsable {
    ///  The accountId property
    UntypedNode? accountId;
    ///  The accountName property
    String? accountName;
    ///  Stores additional data not described in the OpenAPI description found when deserializing. Can be used for serialization as well.
    @override
    Map<String, Object?> additionalData;
    ///  The balance property
    UntypedNode? balance;
    ///  The userId property
    String? userId;
    /// Instantiates a new [Account] and sets the default values.
    Account() :  
        additionalData = {};
    /// Creates a new instance of the appropriate class based on discriminator value
    ///  [parseNode] The parse node to use to read the discriminator value and create the object
    static Account createFromDiscriminatorValue(ParseNode parseNode) {
        return Account();
    }
    /// The deserialization information for the current model
    @override
    Map<String, void Function(ParseNode)> getFieldDeserializers() {
        var deserializerMap = <String, void Function(ParseNode)>{};
        deserializerMap['accountId'] = (node) => accountId = node.getObjectValue<UntypedNode>(UntypedNode.createFromDiscriminatorValue);
        deserializerMap['accountName'] = (node) => accountName = node.getStringValue();
        deserializerMap['balance'] = (node) => balance = node.getObjectValue<UntypedNode>(UntypedNode.createFromDiscriminatorValue);
        deserializerMap['userId'] = (node) => userId = node.getStringValue();
        return deserializerMap;
    }
    /// Serializes information the current object
    ///  [writer] Serialization writer to use to serialize this model
    @override
    void serialize(SerializationWriter writer) {
        writer.writeObjectValue<UntypedNode>('accountId', accountId);
        writer.writeStringValue('accountName', accountName);
        writer.writeObjectValue<UntypedNode>('balance', balance);
        writer.writeStringValue('userId', userId);
        writer.writeAdditionalData(additionalData);
    }
}
