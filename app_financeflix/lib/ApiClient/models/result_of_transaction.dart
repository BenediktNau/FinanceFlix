// ignore_for_file: type=lint
import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
import './transaction.dart';

/// auto generated
class ResultOfTransaction implements AdditionalDataHolder, Parsable {
    ///  Stores additional data not described in the OpenAPI description found when deserializing. Can be used for serialization as well.
    @override
    Map<String, Object?> additionalData;
    ///  The error property
    String? error;
    ///  The isSuccess property
    bool? isSuccess;
    ///  The value property
    Transaction? value;
    /// Instantiates a new [ResultOfTransaction] and sets the default values.
    ResultOfTransaction() :  
        additionalData = {};
    /// Creates a new instance of the appropriate class based on discriminator value
    ///  [parseNode] The parse node to use to read the discriminator value and create the object
    static ResultOfTransaction createFromDiscriminatorValue(ParseNode parseNode) {
        return ResultOfTransaction();
    }
    /// The deserialization information for the current model
    @override
    Map<String, void Function(ParseNode)> getFieldDeserializers() {
        var deserializerMap = <String, void Function(ParseNode)>{};
        deserializerMap['error'] = (node) => error = node.getStringValue();
        deserializerMap['isSuccess'] = (node) => isSuccess = node.getBoolValue();
        deserializerMap['value'] = (node) => value = node.getObjectValue<Transaction>(Transaction.createFromDiscriminatorValue);
        return deserializerMap;
    }
    /// Serializes information the current object
    ///  [writer] Serialization writer to use to serialize this model
    @override
    void serialize(SerializationWriter writer) {
        writer.writeStringValue('error', error);
        writer.writeBoolValue('isSuccess', value:isSuccess);
        writer.writeObjectValue<Transaction>('value', value);
        writer.writeAdditionalData(additionalData);
    }
}
