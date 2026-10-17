import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/api_models.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/feedback_banner.dart';
import '../../../core/widgets/page_frame.dart';
import '../../../core/widgets/role_selector.dart';
import '../../../core/widgets/sitaara_illustration.dart';
import '../../../core/widgets/skeleton.dart';
import '../../auth/application/session_controller.dart';

class CreateFamilyScreen extends ConsumerStatefulWidget {
  const CreateFamilyScreen({super.key});

  @override
  ConsumerState<CreateFamilyScreen> createState() => _CreateFamilyScreenState();
}

class _CreateFamilyScreenState extends ConsumerState<CreateFamilyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  String _role = 'mom';
  DateTime? _dateOfBirth;
  bool _busy = false;
  ApiException? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? now.subtract(const Duration(days: 365)),
      firstDate: DateTime(now.year - 6, now.month, now.day + 1),
      lastDate: now,
      helpText: "Child's date of birth",
    );
    if (selected != null) setState(() => _dateOfBirth = selected);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dateOfBirth == null) {
      setState(
        () => _error = const ApiException(
          code: 'VALIDATION_ERROR',
          message: "Choose your child's date of birth.",
        ),
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(familyRepositoryProvider)
          .createFamily(
            role: _role,
            childName: _name.text,
            dateOfBirth: _dateOfBirth!,
          );
      await ref.read(sessionControllerProvider.notifier).familyChanged();
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    appBar: AppBar(title: const Text('Create your family')),
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: SitaaraIllustration(
              'child_toddler',
              height: 124,
              semanticLabel: 'A cheerful young child',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tell us who you’re learning for',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'This one shared profile keeps both parents in step with the same lessons and progress.',
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
            controller: _name,
            enabled: !_busy,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: "Child's name",
              hintText: 'Aarav',
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? "Enter your child's name."
                : null,
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _busy ? null : _pickDate,
            borderRadius: BorderRadius.circular(14),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date of birth',
                suffixIcon: Icon(Icons.calendar_today_outlined),
              ),
              child: Text(
                _dateOfBirth == null
                    ? 'Choose a date'
                    : DateFormat.yMMMd().format(_dateOfBirth!),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const SitaaraSkeleton(
                    semanticLabel: 'Creating family',
                    child: SkeletonBlock(width: 110, height: 18, radius: 9),
                  )
                : const Text('Create our family space'),
          ),
        ],
      ),
    ),
  );
}
