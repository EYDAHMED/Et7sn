/// A piece of content stored in both supported languages
/// (used for meal names, ingredient names and cooking notes).
class LocalizedText {
  const LocalizedText(this.en, this.ar);

  final String en;
  final String ar;

  String of(String languageCode) => languageCode == 'ar' ? ar : en;
}
