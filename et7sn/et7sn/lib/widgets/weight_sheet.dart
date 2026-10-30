import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/user_profile.dart';
import '../providers/session_provider.dart';
import '../services/firestore_service.dart';
import '../utils/parsing.dart';
import 'common_widgets.dart';

/// Opens the "update my weight" bottom sheet used by the leaderboard and profile.
Future<void> showWeightSheet(BuildContext context) {
  final profile = context.read<SessionProvider>().profile;
  if (profile == null) return Future<void>.value();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => _WeightSheet(profile: profile),
  );
}

class _WeightSheet extends StatefulWidget {
  const _WeightSheet({required this.profile});

  final UserProfile profile;

  @override
  State<_WeightSheet> createState() => _WeightSheetState();
}

class _WeightSheetState extends State<_WeightSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.profile.weightKg.toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    final weight = Parsing.toDouble(_controller.text)!;
    final service = context.read<FirestoreService>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await service.saveWeight(profile: widget.profile, weightKg: weight);
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(l.t('weightSaved'))));
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = l.t('errorGeneric');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.t('updateWeight'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              l.t('updateWeightHint'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩.,٫]')),
              ],
              decoration: InputDecoration(
                labelText: l.t('currentWeightKg'),
                prefixIcon: const Icon(Icons.monitor_weight_outlined),
              ),
              validator: (value) {
                final number = Parsing.toDouble(value);
                if (number == null || number < 25 || number > 400) {
                  return l.t('invalidWeight');
                }
                return null;
              },
              onFieldSubmitted: (_) => _save(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              ErrorBanner(_error!),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _save,
              child: _busy
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : Text(l.t('save')),
            ),
          ],
        ),
      ),
    );
  }
}
