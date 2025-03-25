import 'language.dart';

class NepaliUtils {
  factory NepaliUtils([Language? lang]) {
    _instance ??= NepaliUtils._();
    if (lang != null) _instance!.language = lang;
    return _instance!;
  }
  NepaliUtils._();
  static NepaliUtils? _instance;
  Language language = Language.english;
  
}
