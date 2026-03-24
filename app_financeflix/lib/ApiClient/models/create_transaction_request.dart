// ignore_for_file: type=lint
import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';

/// auto generated
class CreateTransactionRequest implements AdditionalDataHolder, Parsable {
    ///  The accountId property
    UntypedNode? accountId;
    ///  Stores additional data not described in the OpenAPI description found when deserializing. Can be used for serialization as well.
    @override
    Map<String, Object?> additionalData;
    ///  The amount property
    UntypedNode? amount;
    ///  The category property
    int? category;
    ///  The date property
    DateTime? date;
    /// Instantiates a new [CreateTransactionRequest] and sets the default values.
    CreateTransactionRequest() :  
        additionalData = {};
    /// Creates a new instance of the appropriate class based on discriminator value
    ///  [parseNode] The parse node to use to read the discriminator value and create the object
    static CreateTransactionRequest createFromDiscriminatorValue(ParseNode parseNode) {
        return CreateTransactionRequest();
    }
    /// The deserialization information for the current model
    @override
    Map<String, void Function(ParseNode)> getFieldDeserializers() {
        var deserializerMap = <String, void Function(ParseNode)>{};
        deserializerMap['accountId'] = (node) => accountId = node.getObjectValue<UntypedNode>(UntypedNode.createFromDiscriminatorValue);
        deserializerMap['amount'] = (node) => amount = node.getObjectValue<UntypedNode>(UntypedNode.createFromDiscriminatorValue);
        deserializerMap['category'] = (node) => category = node.getIntValue();
        deserializerMap['date'] = (node) => date = node.getDateTimeValue();
        return deserializerMap;
    }
    /// Serializes information the current object
    ///  [writer] Serialization writer to use to serialize this model
    @override
    void serialize(SerializationWriter writer) {
        writer.writeObjectValue<UntypedNode>('accountId', accountId);
        writer.writeObjectValue<UntypedNode>('amount', amount);
        writer.writeIntValue('category', category);
        writer.writeDateTimeValue('date', date);
        writer.writeAdditionalData(additionalData);
    }
}
