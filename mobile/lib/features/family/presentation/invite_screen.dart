import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/models/api_models.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/feedback_banner.dart';
import '../../../core/widgets/page_frame.dart';

class InviteScreen extends ConsumerStatefulWidget {
  const InviteScreen({super.key});

  @override
  ConsumerState<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends ConsumerState<InviteScreen> {
  InviteModel? _invite;
  ApiException? _error;
  bool _busy = false;

  Future<void> _generate() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final invite = await ref.read(familyRepositoryProvider).createInvite();
      if (mounted) setState(() => _invite = invite);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _copy() async {
    final invite = _invite;
    if (invite == null) return;
    await Clipboard.setData(ClipboardData(text: invite.code));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Invite code copied.')));
    }
  }

  Future<void> _share() async {
    final invite = _invite;
    if (invite == null) return;
    await SharePlus.instance.share(
      ShareParams(text: 'Join our family on Sitaara with code ${invite.code}.'),
    );
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    appBar: AppBar(title: const Text('Invite your partner')),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Learn together',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        const Text(
          'Generate a private, single-use code. Creating a new code disables the previous one.',
        ),
        const SizedBox(height: 24),
        if (_error != null) ...[
          FeedbackBanner.fromException(_error!),
          const SizedBox(height: 16),
        ],
        if (_invite == null)
          FilledButton(
            onPressed: _busy ? null : _generate,
            child: Text(_busy ? 'Generating…' : 'Generate invite code'),
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'YOUR INVITE CODE',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    _invite!.code,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 8,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Expires ${DateFormat.yMMMd().add_jm().format(_invite!.expiresAt.toLocal())}',
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _copy,
                          icon: const Icon(Icons.copy_outlined),
                          label: const Text('Copy'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _share,
                          icon: const Icon(Icons.share_outlined),
                          label: const Text('Share'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        if (_invite != null) ...[
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _busy ? null : _generate,
            icon: const Icon(Icons.refresh),
            label: const Text('Generate a new code'),
          ),
        ],
      ],
    ),
  );
}
