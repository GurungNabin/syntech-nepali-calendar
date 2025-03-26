import 'language.dart';

/// A utility class for handling Nepali-specific functionalities.
///
/// This class provides a singleton instance that can be configured with a specific
/// [Language]. By default, it uses [Language.english].
class NepaliUtils {
  /// Factory constructor to get the singleton instance of [NepaliUtils].
  ///
  /// Optionally, a [lang] parameter can be provided to set the language.
  factory NepaliUtils([Language? lang]) {
    _instance ??= NepaliUtils._();
    if (lang != null) _instance!.language = lang;
    return _instance!;
  }

  /// Private named constructor for singleton implementation.
  NepaliUtils._();

  /// The singleton instance of [NepaliUtils].
  static NepaliUtils? _instance;

  /// The language used by [NepaliUtils]. Defaults to [Language.english].
  Language language = Language.english;
}
