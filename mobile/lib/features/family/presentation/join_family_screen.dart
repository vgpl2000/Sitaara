import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../core/models/api_models.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/feedback_banner.dart';
import '../../../core/widgets/page_frame.dart';
import '../../../core/widgets/role_selector.dart';
import '../../auth/application/session_controller.dart';

class JoinFamilyScreen extends ConsumerStatefulWidget {
  const JoinFamilyScreen({super.key});

  @override
  ConsumerState<JoinFamilyScreen> createState() => _JoinFamilyScreenState();
}

class _JoinFamilyScreenState extends ConsumerState<JoinFamilyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  String _role = 'dad';
  bool _busy = false;
  ApiException? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(familyRepositoryProvider)
          .redeemInvite(role: _role, code: _code.text);
      await ref.read(sessionControllerProvider.notifier).familyChanged();
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    appBar: AppBar(title: const Text('Join your partner')),
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter the invite code',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Codes contain six letters or numbers and expire after 24 hours.',
          ),
          const SizedBox(height: 24),
          if (_error != null) ...[
            FeedbackBanner.fromException(_error!),
            const SizedBox(height: 16),
          ],
          RoleSelector(
            value: _role,
            onChanged: (value) => setState(() => _role = value),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _code,
            enabled: !_busy,
            textCapitalization: TextCapitalization.characters,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 8,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
              LengthLimitingTextInputFormatter(6),
              _UpperCaseFormatter(),
            ],
            decoration: const InputDecoration(
              labelText: 'Invite code',
              hintText: '7KM9QW',
              counterText: '',
            ),
            maxLength: 6,
            validator: (value) => value == null || value.length != 6
                ? 'Enter the six-character code.'
                : null,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Join family'),
          ),
        ],
      ),
    ),
  );
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(
    text: newValue.text.toUpperCase(),
    selection: newValue.selection,
  );
}
