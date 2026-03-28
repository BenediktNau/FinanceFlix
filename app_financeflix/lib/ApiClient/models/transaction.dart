// ignore_for_file: type=lint
import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';

/// auto generated
class Transaction implements AdditionalDataHolder, Parsable {
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
    ///  The description property
    String? description;
    ///  The id property
    UntypedNode? id;
    ///  The imageCount property
    UntypedNode? imageCount;
    /// Instantiates a new [Transaction] and sets the default values.
    Transaction() :
        additionalData = {};
    /// Creates a new instance of the appropriate class based on discriminator value
    ///  [parseNode] The parse node to use to read the discriminator value and create the object
    static Transaction createFromDiscriminatorValue(ParseNode parseNode) {
        return Transaction();
    }
    /// The deserialization information for the current model
    @override
    Map<String, void Function(ParseNode)> getFieldDeserializers() {
        var deserializerMap = <String, void Function(ParseNode)>{};
        deserializerMap['accountId'] = (node) => accountId = node.getObjectValue<UntypedNode>(UntypedNode.createFromDiscriminatorValue);
        deserializerMap['amount'] = (node) => amount = node.getObjectValue<UntypedNode>(UntypedNode.createFromDiscriminatorValue);
        deserializerMap['category'] = (node) => category = node.getIntValue();
        deserializerMap['date'] = (node) => date = node.getDateTimeValue();
        deserializerMap['description'] = (node) => description = node.getStringValue();
        deserializerMap['id'] = (node) => id = node.getObjectValue<UntypedNode>(UntypedNode.createFromDiscriminatorValue);
        deserializerMap['imageCount'] = (node) => imageCount = node.getObjectValue<UntypedNode>(UntypedNode.createFromDiscriminatorValue);
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
        writer.writeStringValue('description', description);
        writer.writeObjectValue<UntypedNode>('id', id);
        writer.writeObjectValue<UntypedNode>('imageCount', imageCount);
        writer.writeAdditionalData(additionalData);
    }
}
