import 'package:flutter/material.dart';

import '../../data/data.dart';
import 'hobby_selection_page.dart';
import 'profile.dart';

/// Creates the profile (then moves on to hobby selection) or edits it.
class ProfileFormPage extends StatefulWidget {
  const ProfileFormPage({super.key, required this.store});
  final ProfileStore store;
  @override
  State<ProfileFormPage> createState() => _ProfileFormPageState();
}

class _ProfileFormPageState extends State<ProfileFormPage> {
  final _form = GlobalKey<FormState>();
  late final _username = TextEditingController(
    text: widget.store.profile?.username,
  );
  late final _name = TextEditingController(
    text: widget.store.profile?.displayName,
  );
  late final _bio = TextEditingController(text: widget.store.profile?.bio);
  late final _isNew = widget.store.profile == null;
  bool _saving = false;

  /// Errors from the server, shown under the field they belong to.
  String? _usernameError;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _name.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _usernameError = null;
      _error = null;
    });
    if (_saving || !_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.store.save(
        username: _username.text.trim(),
        displayName: _name.text.trim(),
        bio: _bio.text.trim(),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        if (e.field == 'username') {
          _usernameError = e.message;
        } else {
          _error = e.message;
        }
      });
      return;
    }
    if (!mounted) return;
    final navigator = Navigator.of(context);
    if (_isNew) {
      navigator.pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) =>
              HobbySelectionPage(store: widget.store, isSetup: true),
        ),
      );
    } else {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_isNew ? 'Create profile' : 'Edit profile')),
    body: Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextFormField(
            controller: _username,
            autofocus: _isNew,
            enabled: !_saving,
            maxLength: ProfileRules.maxUsernameLength,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Username',
              prefixText: '@',
              helperText:
                  'Unique to you. Letters, numbers, and symbols; no spaces. '
                  'Capitals count, so @Ada and @ada are different.',
              helperMaxLines: 3,
            ),
            forceErrorText: _usernameError,
            onChanged: (_) {
              if (_usernameError != null) setState(() => _usernameError = null);
            },
            validator: (value) => ProfileRules.checkUsername(value ?? ''),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _name,
            enabled: !_saving,
            maxLength: ProfileRules.maxNameLength,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Display name',
              hintText: 'How other hobbyists will see you',
            ),
            validator: (value) =>
                (value ?? '').trim().isEmpty ? 'Enter a display name.' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _bio,
            enabled: !_saving,
            maxLength: ProfileRules.maxBioLength,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'About you (optional)',
              hintText: 'What you make, grow, or play',
            ),
          ),
          if (_error case final error?)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                error,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(
              _saving
                  ? 'Saving…'
                  : _isNew
                  ? 'Next: choose hobbies'
                  : 'Save',
            ),
          ),
        ],
      ),
    ),
  );
}
