import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/prayer.dart';
import '../services/location_service.dart';
import '../services/prayer_service.dart';
import '../utils/week_utils.dart';

enum PrayerStatus { idle, locating, ready, error }

/// Fired when a prayer time arrives while the app is open.
class PrayerArrival {
  const PrayerArrival(this.name, this.sequence);

  final PrayerName name;
  final int sequence;
}

/// Detects the location, calculates prayer times and drives the live countdown.
class PrayerProvider extends ChangeNotifier {
  PrayerProvider(this._prefs, this._location) {
    final stored = _prefs.getString(_methodKey);
    _method = PrayerMethod.values.firstWhere(
      (m) => m.name == stored,
      orElse: () => PrayerMethod.egyptian,
    );
  }

  static const String _latKey = 'prayer_lat';
  static const String _lngKey = 'prayer_lng';
  static const String _methodKey = 'prayer_method';

  final SharedPreferences _prefs;
  final LocationService _location;

  /// Ticks every second; the countdown widget listens to this directly so the
  /// rest of the screen does not rebuild every second.
  final ValueNotifier<DateTime> now = ValueNotifier<DateTime>(DateTime.now());

  late PrayerMethod _method;
  double? _latitude;
  double? _longitude;
  DayPrayers? _yesterday;
  DayPrayers? _today;
  DayPrayers? _tomorrow;
  NextPrayer? _next;
  PrayerStatus _status = PrayerStatus.idle;
  LocationFailure? _failure;
  PrayerArrival? _arrival;
  int _arrivalCount = 0;
  bool _started = false;
  bool _locating = false;
  Timer? _timer;

  PrayerMethod get method => _method;

  double? get latitude => _latitude;

  double? get longitude => _longitude;

  DayPrayers? get today => _today;

  NextPrayer? get next => _next;

  PrayerStatus get status => _status;

  LocationFailure? get failure => _failure;

  PrayerArrival? get arrival => _arrival;

  bool get isLocating => _locating;

  /// Starts the clock and the first location lookup. Safe to call repeatedly.
  void start() {
    if (_started) return;
    _started = true;

    final lat = _prefs.getDouble(_latKey);
    final lng = _prefs.getDouble(_lngKey);
    if (lat != null && lng != null) {
      _latitude = lat;
      _longitude = lng;
      _recompute();
      _status = PrayerStatus.ready;
      notifyListeners();
    }

    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    refreshLocation();
  }

  Future<void> refreshLocation() async {
    if (_locating) return;
    _locating = true;
    _failure = null;
    if (_latitude == null) _status = PrayerStatus.locating;
    notifyListeners();

    try {
      final position = await _location.currentPosition();
      _latitude = position.latitude;
      _longitude = position.longitude;
      await _prefs.setDouble(_latKey, position.latitude);
      await _prefs.setDouble(_lngKey, position.longitude);
      _recompute();
      _status = PrayerStatus.ready;
    } on LocationException catch (e) {
      _failure = e.failure;
      if (_latitude == null) _status = PrayerStatus.error;
    } catch (_) {
      _failure = LocationFailure.unavailable;
      if (_latitude == null) _status = PrayerStatus.error;
    }
    _locating = false;
    notifyListeners();
  }

  Future<void> setMethod(PrayerMethod method) async {
    if (method == _method) return;
    _method = method;
    await _prefs.setString(_methodKey, method.name);
    if (_latitude != null) _recompute();
    notifyListeners();
  }

  Future<void> openLocationSettings() => _location.openLocationSettings();

  Future<void> openAppSettings() => _location.openAppSettings();

  void _recompute() {
    final lat = _latitude;
    final lng = _longitude;
    if (lat == null || lng == null) return;

    final current = DateTime.now();
    _yesterday = PrayerService.calculate(
      lat,
      lng,
      current.subtract(const Duration(days: 1)),
      _method,
    );
    _today = PrayerService.calculate(lat, lng, current, _method);
    _tomorrow = PrayerService.calculate(
      lat,
      lng,
      current.add(const Duration(days: 1)),
      _method,
    );
    _next = _computeNext(current);
  }

  NextPrayer? _computeNext(DateTime at) {
    final yesterday = _yesterday;
    final today = _today;
    final tomorrow = _tomorrow;
    if (yesterday == null || today == null || tomorrow == null) return null;

    final entries = <MapEntry<PrayerName, DateTime>>[
      MapEntry(PrayerName.isha, yesterday.isha),
      MapEntry(PrayerName.fajr, today.fajr),
      MapEntry(PrayerName.dhuhr, today.dhuhr),
      MapEntry(PrayerName.asr, today.asr),
      MapEntry(PrayerName.maghrib, today.maghrib),
      MapEntry(PrayerName.isha, today.isha),
      MapEntry(PrayerName.fajr, tomorrow.fajr),
    ];
    for (var i = 1; i < entries.length; i++) {
      if (entries[i].value.isAfter(at)) {
        return NextPrayer(entries[i].key, entries[i].value, entries[i - 1].value);
      }
    }
    return null;
  }

  void _tick(Timer timer) {
    final current = DateTime.now();
    now.value = current;
    if (_latitude == null) return;

    final today = _today;
    if (today != null && !WeekUtils.sameDay(today.date, current)) {
      _recompute();
      notifyListeners();
      return;
    }

    final previous = _next;
    final upcoming = _computeNext(current);
    if (previous != null &&
        upcoming != null &&
        upcoming.time != previous.time &&
        !current.isBefore(previous.time) &&
        current.difference(previous.time) < const Duration(seconds: 30)) {
      _arrivalCount++;
      _arrival = PrayerArrival(previous.name, _arrivalCount);
    }
    if (previous?.time != upcoming?.time) {
      _next = upcoming;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    now.dispose();
    super.dispose();
  }
}
