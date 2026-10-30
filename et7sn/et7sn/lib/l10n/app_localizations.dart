import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../models/localized_text.dart';
import 'app_ar.dart';
import 'app_en.dart';

/// Hand-written localizations for English and Arabic.
///
/// Usage: `AppLocalizations.of(context).t('key')`. Dynamic text uses
/// `{placeholder}` markers filled in by [tr]. Arabic automatically switches
/// the whole app to right-to-left through Flutter's localization machinery.
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const List<Locale> supportedLocales = [Locale('en'), Locale('ar')];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  bool get isArabic => locale.languageCode == 'ar';

  Map<String, String> get _strings => isArabic ? arStrings : enStrings;

  /// Translates [key]. Falls back to English, then to the key itself.
  String t(String key) => _strings[key] ?? enStrings[key] ?? key;

  /// Translates [key] and replaces every `{name}` with the matching value.
  String tr(String key, Map<String, String> values) {
    var text = t(key);
    values.forEach((name, value) {
      text = text.replaceAll('{$name}', value);
    });
    return text;
  }

  /// Picks the English or Arabic version of bundled content (meals, foods).
  String pick(LocalizedText text) => text.of(locale.languageCode);

  /// 5:42 PM  /  ٥:٤٢ م
  String formatTime(DateTime time) =>
      DateFormat('h:mm a', locale.languageCode).format(time);

  /// Friday, October 30
  String formatDate(DateTime date) =>
      DateFormat.MMMMEEEEd(locale.languageCode).format(date);

  /// Oct 30, 2026
  String formatShortDate(DateTime date) =>
      DateFormat.yMMMd(locale.languageCode).format(date);

  /// Maps a Firebase Auth error code to a friendly message.
  String authError(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
      case 'invalid-email':
        return t('authInvalidCredential');
      case 'email-already-in-use':
        return t('authUsernameTaken');
      case 'weak-password':
        return t('passwordTooShort');
      case 'network-request-failed':
        return t('authNetwork');
      case 'too-many-requests':
        return t('authTooManyRequests');
      case 'user-disabled':
        return t('authDisabled');
      case 'operation-not-allowed':
      case 'configuration-not-found':
        return '${t('authNotEnabled')} [$code]';
      default:
        return '${t('errorGeneric')} [$code]';
    }
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'en' || locale.languageCode == 'ar';

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
