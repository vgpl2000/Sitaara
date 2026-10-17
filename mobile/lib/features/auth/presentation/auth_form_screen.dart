import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/api_models.dart';
import '../../../core/widgets/feedback_banner.dart';
import '../../../core/widgets/page_frame.dart';
import '../../../core/widgets/sitaara_illustration.dart';
import '../../../core/widgets/skeleton.dart';
import '../application/session_controller.dart';

enum AuthMode { signup, login }

class AuthFormScreen extends ConsumerStatefulWidget {
  const AuthFormScreen({super.key, required this.mode});

  final AuthMode mode;

  @override
  ConsumerState<AuthFormScreen> createState() => _AuthFormScreenState();
}

class _AuthFormScreenState extends ConsumerState<AuthFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _obscure = true;
  ApiException? _error;

  bool get _isSignup => widget.mode == AuthMode.signup;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);
    try {
      final controller = ref.read(sessionControllerProvider.notifier);
      if (_isSignup) {
        await controller.register(email: _email.text, password: _password.text);
      } else {
        await controller.login(email: _email.text, password: _password.text);
      }
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(sessionControllerProvider).isSubmitting;
    return PageFrame(
      appBar: AppBar(title: Text(_isSignup ? 'Create account' : 'Log in')),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SitaaraIllustration(
                'auth_calm',
                height: _isSignup ? 130 : 150,
                semanticLabel: 'A calm parent supported by Sitaara',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _isSignup
                  ? 'A calmer journey starts here'
                  : 'Good to see you again',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _isSignup
                  ? 'Create your private family space, then invite your parenting partner when you are ready.'
                  : 'Pick up where your family left off.',
            ),
            const SizedBox(height: 24),
            if (_error != null) ...[
              FeedbackBanner.fromException(_error!),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _email,
              enabled: !busy,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email address',
                hintText: 'parent@example.com',
              ),
              validator: (value) =>
                  value == null ||
                      !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                          .hasMatch(value.trim())
                  ? 'Enter a valid email address.'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _password,
              enabled: !busy,
              obscureText: _obscure,
              autofillHints: _isSignup
                  ? const [AutofillHints.newPassword]
                  : const [AutofillHints.password],
              textInputAction: _isSignup
                  ? TextInputAction.next
                  : TextInputAction.done,
              onFieldSubmitted: _isSignup ? null : (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Password',
                helperText: _isSignup ? 'Use 8–128 characters.' : null,
                suffixIcon: IconButton(
                  tooltip: _obscure ? 'Show password' : 'Hide password',
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) => value == null || value.length < 8
                  ? 'Use at least 8 characters.'
                  : null,
            ),
            if (_isSignup) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmation,
                enabled: !busy,
                obscureText: _obscure,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  labelText: 'Confirm password',
                ),
                validator: (value) =>
                    value != _password.text ? 'Passwords do not match.' : null,
              ),
            ],
            const SizedBox(height: 28),
            FilledButton(
              onPressed: busy ? null : _submit,
              child: busy
                  ? const SitaaraSkeleton(
                      semanticLabel: 'Submitting',
                      child: SkeletonBlock(width: 110, height: 18, radius: 9),
                    )
                  : Text(
                      _isSignup ? 'Create my account' : 'Continue to Sitaara',
                    ),
            ),
            const SizedBox(height: 14),
            Center(
              child: Text(
                _isSignup
                    ? 'Already part of Sitaara? Use Log in from the previous screen.'
                    : 'Your family space stays private to linked co-parents.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
