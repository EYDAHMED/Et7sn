import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/prayer.dart';
import '../providers/prayer_provider.dart';
import '../services/location_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';

/// GPS-based prayer times with a live countdown to the next prayer.
class PrayerScreen extends StatelessWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final prayer = context.watch<PrayerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('prayerTimes')),
        actions: [
          IconButton(
            tooltip: l.t('updateLocation'),
            onPressed: prayer.isLocating ? null : prayer.refreshLocation,
            icon: prayer.isLocating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
                : const Icon(Icons.my_location),
          ),
        ],
      ),
      body: _buildBody(context, prayer, l),
    );
  }

  Widget _buildBody(BuildContext context, PrayerProvider prayer, AppLocalizations l) {
    final today = prayer.today;
    final next = prayer.next;

    if (prayer.status == PrayerStatus.ready && today != null && next != null) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          _NextPrayerCard(prayer: prayer, next: next),
          const SizedBox(height: 16),
          _TimesCard(today: today, next: next),
          const SizedBox(height: 16),
          _InfoCard(prayer: prayer),
          if (prayer.failure != null) ...[
            const SizedBox(height: 12),
            _FailureNote(failure: prayer.failure!, prayer: prayer),
          ],
        ],
      );
    }

    if (prayer.status == PrayerStatus.error && prayer.failure != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: _FailureNote(failure: prayer.failure!, prayer: prayer, large: true),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(l.t('detectingLocation')),
        ],
      ),
    );
  }
}

class _NextPrayerCard extends StatelessWidget {
  const _NextPrayerCard({required this.prayer, required this.next});

  final PrayerProvider prayer;
  final NextPrayer next;

  String _format(Duration duration) {
    final safe = duration.isNegative ? Duration.zero : duration;
    final h = safe.inHours.toString().padLeft(2, '0');
    final m = (safe.inMinutes % 60).toString().padLeft(2, '0');
    final s = (safe.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    const onDark = AppColors.white;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [AppColors.oliveDark, AppColors.olive],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ValueListenableBuilder<DateTime>(
        valueListenable: prayer.now,
        builder: (context, now, _) {
          final remaining = next.time.difference(now);
          final total = next.time.difference(next.previous).inSeconds;
          final elapsed = now.difference(next.previous).inSeconds;
          final progress =
              total <= 0 ? 0.0 : (elapsed / total).clamp(0.0, 1.0).toDouble();

          return Column(
            children: [
              Text(
                l.t('nextPrayer'),
                style: TextStyle(
                  color: onDark.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l.t('prayer_${next.name.name}'),
                style: const TextStyle(
                  color: onDark,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: 210,
                height: 210,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 210,
                      height: 210,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 9,
                        strokeCap: StrokeCap.round,
                        backgroundColor: onDark.withValues(alpha: 0.22),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.goldBright,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            _format(remaining),
                            style: const TextStyle(
                              color: onDark,
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l.t('remaining'),
                          style: TextStyle(color: onDark.withValues(alpha: 0.8)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l.tr('atTime', {'time': l.formatTime(next.time)}),
                style: const TextStyle(
                  color: onDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TimesCard extends StatelessWidget {
  const _TimesCard({required this.today, required this.next});

  final DayPrayers today;
  final NextPrayer next;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    Widget row(String label, DateTime time, {bool highlight = false, bool muted = false}) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: highlight ? scheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 16,
                  color: muted ? scheme.onSurfaceVariant : scheme.onSurface,
                ),
              ),
            ),
            Text(
              l.formatTime(time),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: muted ? scheme.onSurfaceVariant : scheme.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            row(l.t('prayer_fajr'), today.fajr, highlight: next.name == PrayerName.fajr),
            row(l.t('sunrise'), today.sunrise, muted: true),
            row(l.t('prayer_dhuhr'), today.dhuhr, highlight: next.name == PrayerName.dhuhr),
            row(l.t('prayer_asr'), today.asr, highlight: next.name == PrayerName.asr),
            row(
              l.t('prayer_maghrib'),
              today.maghrib,
              highlight: next.name == PrayerName.maghrib,
            ),
            row(l.t('prayer_isha'), today.isha, highlight: next.name == PrayerName.isha),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.prayer});

  final PrayerProvider prayer;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final lat = prayer.latitude;
    final lng = prayer.longitude;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on_outlined, color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        lat == null || lng == null
                            ? '-'
                            : '${lat.toStringAsFixed(3)}, ${lng.toStringAsFixed(3)}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l.tr('methodLine', {'method': l.t('method_${prayer.method.name}')}),
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              l.t('prayerInAppNote'),
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _FailureNote extends StatelessWidget {
  const _FailureNote({
    required this.failure,
    required this.prayer,
    this.large = false,
  });

  final LocationFailure failure;
  final PrayerProvider prayer;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    final String message;
    String? actionLabel;
    VoidCallback? action;
    switch (failure) {
      case LocationFailure.servicesDisabled:
        message = l.t('locServicesOff');
        actionLabel = l.t('openLocationSettings');
        action = prayer.openLocationSettings;
        break;
      case LocationFailure.denied:
        message = l.t('locDenied');
        actionLabel = l.t('allowLocation');
        action = prayer.refreshLocation;
        break;
      case LocationFailure.deniedForever:
        message = l.t('locDeniedForever');
        actionLabel = l.t('openAppSettings');
        action = prayer.openAppSettings;
        break;
      case LocationFailure.unavailable:
        message = l.t('locUnavailable');
        actionLabel = l.t('retry');
        action = prayer.refreshLocation;
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (large) ...[
          Icon(Icons.location_off_outlined, size: 56, color: scheme.onSurfaceVariant),
          const SizedBox(height: 16),
        ],
        large
            ? Text(message, textAlign: TextAlign.center)
            : ErrorBanner(message),
        const SizedBox(height: 14),
        if (large)
          FilledButton(onPressed: action, child: Text(actionLabel))
        else
          OutlinedButton(onPressed: action, child: Text(actionLabel)),
        if (large && failure == LocationFailure.denied) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: prayer.openAppSettings,
            child: Text(l.t('openAppSettings')),
          ),
        ],
      ],
    );
  }
}
