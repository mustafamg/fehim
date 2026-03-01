import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookup();
typedef MessageIfAbsent =
    String Function(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  @override
  String get localeName => 'ar';
  @override
  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "submit": MessageLookupByLibrary.simpleMessage("Submit"),
  };
}
