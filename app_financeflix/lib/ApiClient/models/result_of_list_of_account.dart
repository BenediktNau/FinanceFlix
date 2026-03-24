// ignore_for_file: type=lint
import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
import './account.dart';

/// auto generated
class ResultOfListOfAccount implements AdditionalDataHolder, Parsable {
    ///  Stores additional data not described in the OpenAPI description found when deserializing. Can be used for serialization as well.
    @override
    Map<String, Object?> additionalData;
    ///  The error property
    String? error;
    ///  The isSuccess property
    bool? isSuccess;
    ///  The value property
    Iterable<Account>? value;
    /// Instantiates a new [ResultOfListOfAccount] and sets the default values.
    ResultOfListOfAccount() :  
        additionalData = {};
    /// Creates a new instance of the appropriate class based on discriminator value
    ///  [parseNode] The parse node to use to read the discriminator value and create the object
    static ResultOfListOfAccount createFromDiscriminatorValue(ParseNode parseNode) {
        return ResultOfListOfAccount();
    }
    /// The deserialization information for the current model
    @override
    Map<String, void Function(ParseNode)> getFieldDeserializers() {
        var deserializerMap = <String, void Function(ParseNode)>{};
        deserializerMap['error'] = (node) => error = node.getStringValue();
        deserializerMap['isSuccess'] = (node) => isSuccess = node.getBoolValue();
        deserializerMap['value'] = (node) => value = node.getCollectionOfObjectValues<Account>(Account.createFromDiscriminatorValue);
        return deserializerMap;
    }
    /// Serializes information the current object
    ///  [writer] Serialization writer to use to serialize this model
    @override
    void serialize(SerializationWriter writer) {
        writer.writeStringValue('error', error);
        writer.writeBoolValue('isSuccess', value:isSuccess);
        writer.writeCollectionOfObjectValues<Account>('value', value);
        writer.writeAdditionalData(additionalData);
    }
}
