// ignore_for_file: type=lint
import 'package:microsoft_kiota_abstractions/microsoft_kiota_abstractions.dart';

/// auto generated
class MailInbox implements AdditionalDataHolder, Parsable {
    ///  The accountId property
    UntypedNode? accountId;
    ///  Stores additional data not described in the OpenAPI description found when deserializing. Can be used for serialization as well.
    @override
    Map<String, Object?> additionalData;
    ///  The displayName property
    String? displayName;
    ///  The folderName property
    String? folderName;
    ///  The id property
    UntypedNode? id;
    ///  The imapHost property
    String? imapHost;
    ///  The imapPort property
    UntypedNode? imapPort;
    ///  The password property
    String? password;
    ///  The username property
    String? username;
    ///  The useSsl property
    bool? useSsl;
    /// Instantiates a new [MailInbox] and sets the default values.
    MailInbox() :  
        additionalData = {};
    /// Creates a new instance of the appropriate class based on discriminator value
    ///  [parseNode] The parse node to use to read the discriminator value and create the object
    static MailInbox createFromDiscriminatorValue(ParseNode parseNode) {
        return MailInbox();
    }
    /// The deserialization information for the current model
    @override
    Map<String, void Function(ParseNode)> getFieldDeserializers() {
        var deserializerMap = <String, void Function(ParseNode)>{};
        deserializerMap['accountId'] = (node) => accountId = node.getObjectValue<UntypedNode>(UntypedNode.createFromDiscriminatorValue);
        deserializerMap['displayName'] = (node) => displayName = node.getStringValue();
        deserializerMap['folderName'] = (node) => folderName = node.getStringValue();
        deserializerMap['id'] = (node) => id = node.getObjectValue<UntypedNode>(UntypedNode.createFromDiscriminatorValue);
        deserializerMap['imapHost'] = (node) => imapHost = node.getStringValue();
        deserializerMap['imapPort'] = (node) => imapPort = node.getObjectValue<UntypedNode>(UntypedNode.createFromDiscriminatorValue);
        deserializerMap['password'] = (node) => password = node.getStringValue();
        deserializerMap['username'] = (node) => username = node.getStringValue();
        deserializerMap['useSsl'] = (node) => useSsl = node.getBoolValue();
        return deserializerMap;
    }
    /// Serializes information the current object
    ///  [writer] Serialization writer to use to serialize this model
    @override
    void serialize(SerializationWriter writer) {
        writer.writeObjectValue<UntypedNode>('accountId', accountId);
        writer.writeStringValue('displayName', displayName);
        writer.writeStringValue('folderName', folderName);
        writer.writeObjectValue<UntypedNode>('id', id);
        writer.writeStringValue('imapHost', imapHost);
        writer.writeObjectValue<UntypedNode>('imapPort', imapPort);
        writer.writeStringValue('password', password);
        writer.writeStringValue('username', username);
        writer.writeBoolValue('useSsl', value:useSsl);
        writer.writeAdditionalData(additionalData);
    }
}
