import 'package:flutter/material.dart';

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
  late final _name = TextEditingController(
    text: widget.store.profile?.displayName,
  );
  late final _bio = TextEditingController(text: widget.store.profile?.bio);
  late final _isNew = widget.store.profile == null;

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    widget.store.saveDetails(
      displayName: _name.text.trim(),
      bio: _bio.text.trim(),
    );
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
            controller: _name,
            autofocus: _isNew,
            maxLength: UserProfile.maxNameLength,
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
            maxLength: UserProfile.maxBioLength,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'About you (optional)',
              hintText: 'What you make, grow, or play',
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _save,
            child: Text(_isNew ? 'Next: choose hobbies' : 'Save'),
          ),
        ],
      ),
    ),
  );
}
