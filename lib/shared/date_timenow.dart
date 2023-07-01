import 'package:intl/intl.dart';

class DateTimeNow{
  static String now(){
    var now = DateTime.now();
    var formatter = DateFormat('dd MMMM yyyy');
    return formatter.format(now);
  }
}
