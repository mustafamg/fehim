import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';
final messages = new MessageLookup();
typedef String MessageIfAbsent(String messageStr, List<dynamic> args);
class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ar';
  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "submit": MessageLookupByLibrary.simpleMessage("Submit"),
  };
}
