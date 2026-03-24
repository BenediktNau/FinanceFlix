// ignore_for_file: type=lint
import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';
import './mail_inbox.dart';

/// auto generated
class ResultOfMailInbox implements AdditionalDataHolder, Parsable {
    ///  Stores additional data not described in the OpenAPI description found when deserializing. Can be used for serialization as well.
    @override
    Map<String, Object?> additionalData;
    ///  The error property
    String? error;
    ///  The isSuccess property
    bool? isSuccess;
    ///  The value property
    MailInbox? value;
    /// Instantiates a new [ResultOfMailInbox] and sets the default values.
    ResultOfMailInbox() :  
        additionalData = {};
    /// Creates a new instance of the appropriate class based on discriminator value
    ///  [parseNode] The parse node to use to read the discriminator value and create the object
    static ResultOfMailInbox createFromDiscriminatorValue(ParseNode parseNode) {
        return ResultOfMailInbox();
    }
    /// The deserialization information for the current model
    @override
    Map<String, void Function(ParseNode)> getFieldDeserializers() {
        var deserializerMap = <String, void Function(ParseNode)>{};
        deserializerMap['error'] = (node) => error = node.getStringValue();
        deserializerMap['isSuccess'] = (node) => isSuccess = node.getBoolValue();
        deserializerMap['value'] = (node) => value = node.getObjectValue<MailInbox>(MailInbox.createFromDiscriminatorValue);
        return deserializerMap;
    }
    /// Serializes information the current object
    ///  [writer] Serialization writer to use to serialize this model
    @override
    void serialize(SerializationWriter writer) {
        writer.writeStringValue('error', error);
        writer.writeBoolValue('isSuccess', value:isSuccess);
        writer.writeObjectValue<MailInbox>('value', value);
        writer.writeAdditionalData(additionalData);
    }
}
