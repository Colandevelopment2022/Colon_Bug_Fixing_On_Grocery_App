import 'package:logger/logger.dart';

//get logger
Logger getLogger(String className) {
  return Logger(printer: PrettyPrinter());
}

//log util to print log
class AppLogHelper extends LogPrinter {
  final String className;

  AppLogHelper(this.className);

  @override
  List<String> log(LogEvent event) {
    var color = PrettyPrinter.levelColors[event.level];
    var emoji = PrettyPrinter.levelEmojis[event.level];

    if (true) {
      //have to check is in debug mode or production mode to disable the og or not
      // Log.v(color('$emoji $className - ${event.message}'));
    }
  }
}
