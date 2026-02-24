import 'package:intl/intl.dart';

final DateFormat _noteDateFormat = DateFormat('dd/MM/yyyy HH:mm');

String formatNoteDateTime(DateTime dateTime) {
  return _noteDateFormat.format(dateTime);
}
