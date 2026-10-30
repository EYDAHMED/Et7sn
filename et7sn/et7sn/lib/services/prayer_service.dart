import 'package:adhan/adhan.dart';

import '../models/prayer.dart';

/// Calculates prayer times offline from GPS coordinates using the `adhan`
/// astronomical algorithms.
class PrayerService {
  PrayerService._();

  static DayPrayers calculate(
    double latitude,
    double longitude,
    DateTime date,
    PrayerMethod method,
  ) {
    final coordinates = Coordinates(latitude, longitude);
    final params = switch (method) {
      PrayerMethod.egyptian => CalculationMethod.egyptian.getParameters(),
      PrayerMethod.muslimWorldLeague =>
        CalculationMethod.muslim_world_league.getParameters(),
      PrayerMethod.ummAlQura => CalculationMethod.umm_al_qura.getParameters(),
      PrayerMethod.karachi => CalculationMethod.karachi.getParameters(),
      PrayerMethod.northAmerica =>
        CalculationMethod.north_america.getParameters(),
    };
    params.madhab = Madhab.shafi;

    final times = PrayerTimes(coordinates, DateComponents.from(date), params);

    return DayPrayers(
      date: DateTime(date.year, date.month, date.day),
      fajr: times.fajr.toLocal(),
      sunrise: times.sunrise.toLocal(),
      dhuhr: times.dhuhr.toLocal(),
      asr: times.asr.toLocal(),
      maghrib: times.maghrib.toLocal(),
      isha: times.isha.toLocal(),
    );
  }
}
