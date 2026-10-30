/// The five daily prayers (sunrise is shown in the list but is not a prayer).
enum PrayerName { fajr, dhuhr, asr, maghrib, isha }

/// Calculation conventions offered in Settings.
enum PrayerMethod {
  egyptian,
  muslimWorldLeague,
  ummAlQura,
  karachi,
  northAmerica,
}

/// All prayer times for one calendar day, in the device's local time zone.
class DayPrayers {
  const DayPrayers({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  final DateTime date;
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  DateTime of(PrayerName name) {
    switch (name) {
      case PrayerName.fajr:
        return fajr;
      case PrayerName.dhuhr:
        return dhuhr;
      case PrayerName.asr:
        return asr;
      case PrayerName.maghrib:
        return maghrib;
      case PrayerName.isha:
        return isha;
    }
  }
}

/// The upcoming prayer, plus the time of the one before it (for the progress ring).
class NextPrayer {
  const NextPrayer(this.name, this.time, this.previous);

  final PrayerName name;
  final DateTime time;
  final DateTime previous;
}
