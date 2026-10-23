import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/data.dart';
import '../profile/hobby_catalog.dart';
import 'listing_detail_page.dart';
import 'listing_photo.dart';

/// The server stores and returns photoDataUrl and area, so posting them is on.
/// Build with --dart-define=LISTING_MEDIA_ENABLED=false against an older
/// server that drops them.
const listingMediaEnabled = bool.fromEnvironment(
  'LISTING_MEDIA_ENABLED',
  defaultValue: true,
);

class PostPage extends StatefulWidget {
  const PostPage({
    super.key,
    this.client,
    this.onPosted,
    this.pickPhoto,
    this.mediaEnabled = listingMediaEnabled,
  });
  final ApiClient? client;
  final VoidCallback? onPosted;
  final Future<Uint8List?> Function()? pickPhoto;
  final bool mediaEnabled;
  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final _form = GlobalKey<FormState>();
  final _scroll = ScrollController();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _wanted = TextEditingController();
  final _area = TextEditingController();
  String? _hobbyId;
  String? _condition;
  ListingType _type = ListingType.swap;
  String? _photo;
  String? _error;
  String? _notice;
  bool _busy = false;
  bool _picking = false;
  static const _conditions = ['New', 'Like new', 'Good', 'Fair'];
  @override
  void dispose() {
    _scroll.dispose();
    for (final controller in [_title, _description, _wanted, _area]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _required(String? text) =>
      (text ?? '').trim().isEmpty ? 'Please fill in this field.' : null;
  NewListing _draft() => NewListing(
    hobbyId: _hobbyId!,
    title: _title.text.trim(),
    description: _description.text.trim(),
    condition: _condition!,
    type: _type,
    wantedItem: _type == ListingType.swap ? _wanted.text.trim() : null,
    area: _area.text.trim().isEmpty ? null : _area.text.trim(),
    photoDataUrl: _photo,
  );
  Listing _preview(NewListing draft) => Listing(
    id: 'preview',
    ownerId: ApiConfig.demoUserId,
    hobbyId: draft.hobbyId,
    title: draft.title,
    description: draft.description,
    condition: draft.condition,
    type: draft.type,
    wantedItem: draft.wantedItem,
    area: draft.area,
    photoDataUrl: draft.photoDataUrl,
    status: ListingStatus.available,
    createdAt: DateTime.now(),
  );
  Future<void> _choosePhoto() async {
    setState(() {
      _picking = true;
      _error = null;
    });
    try {
      Uint8List? bytes;
      if (widget.pickPhoto != null) {
        bytes = await widget.pickPhoto!();
      } else {
        final file = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 75,
          requestFullMetadata: false,
        );
        if (file != null) {
          if (await file.length() > 512 * 1024) {
            throw const FormatException(
              'Choose a smaller image (up to 512 KB).',
            );
          }
          bytes = await file.readAsBytes();
        }
      }
      if (bytes != null) {
        if (bytes.length > 512 * 1024) {
          throw const FormatException('Choose a smaller image (up to 512 KB).');
        }
        // Validate that it is an image before accepting it as a photo.
        final image = await decodeImageFromList(bytes);
        image.dispose();
        final mime = bytes.length > 3 && bytes[0] == 0xFF && bytes[1] == 0xD8
            ? 'image/jpeg'
            : bytes.length > 3 && bytes[0] == 0x89 && bytes[1] == 0x50
            ? 'image/png'
            : bytes.length > 12 && bytes[0] == 0x52 && bytes[8] == 0x57
            ? 'image/webp'
            : null;
        if (mime == null) {
          throw const FormatException(
            'Please choose a JPG, PNG, or WebP image.',
          );
        }
        if (mounted) {
          setState(() => _photo = 'data:$mime;base64,${base64Encode(bytes!)}');
        }
      }
    } on FormatException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } on PlatformException {
      if (mounted) {
        setState(
          () => _error =
              'Could not open your photos. Check photo access and try again.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _error = 'That photo could not be read. Try a JPG or PNG image.',
        );
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _submit() async {
    if (_busy || !_form.currentState!.validate()) return;
    final draft = _draft();
    if (!widget.mediaEnabled &&
        (draft.photoDataUrl != null || draft.area != null)) {
      setState(
        () => _error = 'Photo and city/area publishing is not available yet. You can preview them, or remove them to publish a text listing.',
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
    });
    try {
      final saved = await (widget.client ?? apiClient).createListing(
        draft,
        ownerId: ApiConfig.demoUserId,
      );
      if (!mounted) return;
      final missingMedia =
          (draft.photoDataUrl != null && saved.photoDataUrl == null) ||
          (draft.area != null && saved.area != draft.area);
      _title.clear();
      _description.clear();
      _wanted.clear();
      _area.clear();
      _form.currentState!.reset();
      setState(() {
        _photo = null;
        _hobbyId = null;
        _condition = null;
        _type = ListingType.swap;
        _notice = missingMedia
            ? 'Listing posted, but the server did not save its photo or area. Contact your team before posting another.'
            : 'Listing posted! It now appears on Home.';
      });
      widget.onPosted?.call();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scroll.hasClients) _scroll.jumpTo(0);
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Form(
    key: _form,
    child: SingleChildScrollView(
      controller: _scroll,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Give supplies a fresh start.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Share something for a swap or give it a new home. No prices needed.',
          ),
          const SizedBox(height: 20),
          if (_notice != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_notice!),
              ),
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ListingPhoto(hobbyId: _hobbyId ?? '', dataUrl: _photo),
          ),
          Wrap(
            spacing: 12,
            children: [
              TextButton.icon(
                onPressed: _busy || _picking ? null : _choosePhoto,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(
                  _picking
                      ? 'Opening photos...'
                      : _photo == null
                      ? 'Add photo (optional)'
                      : 'Change photo',
                ),
              ),
              if (_photo != null)
                TextButton(
                  onPressed: _busy ? null : () => setState(() => _photo = null),
                  child: const Text('Remove photo'),
                ),
            ],
          ),
          const Text(
            'One JPG, PNG, or WebP photo, up to 512 KB. No photo? We will use a hobby icon.',
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _title,
            enabled: !_busy,
            maxLength: 80,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Item name'),
            validator: _required,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: ValueKey('hobby-$_hobbyId'),
            initialValue: _hobbyId,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Hobby'),
            items: [
              for (final hobby in HobbyCatalog.all)
                DropdownMenuItem(value: hobby.id, child: Text(hobby.name)),
            ],
            onChanged: _busy
                ? null
                : (value) => setState(() => _hobbyId = value),
            validator: _required,
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            key: ValueKey('condition-$_condition'),
            initialValue: _condition,
            decoration: const InputDecoration(labelText: 'Condition'),
            items: [
              for (final condition in _conditions)
                DropdownMenuItem(value: condition, child: Text(condition)),
            ],
            onChanged: _busy
                ? null
                : (value) => setState(() => _condition = value),
            validator: _required,
          ),
          const SizedBox(height: 20),
          SegmentedButton<ListingType>(
            segments: const [
              ButtonSegment(
                value: ListingType.swap,
                label: Text('Swap'),
                icon: Icon(Icons.swap_horiz),
              ),
              ButtonSegment(
                value: ListingType.giveaway,
                label: Text('Giveaway'),
                icon: Icon(Icons.volunteer_activism_outlined),
              ),
            ],
            selected: {_type},
            onSelectionChanged: _busy
                ? null
                : (value) => setState(() => _type = value.first),
          ),
          const SizedBox(height: 20),
          if (_type == ListingType.swap)
            TextFormField(
              controller: _wanted,
              enabled: !_busy,
              maxLength: 120,
              decoration: const InputDecoration(
                labelText: 'What would you like in exchange?',
              ),
              validator: _required,
            ),
          TextFormField(
            controller: _description,
            enabled: !_busy,
            minLines: 3,
            maxLines: 6,
            maxLength: 1000,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'What is included? Mention wear or missing pieces.',
            ),
            validator: _required,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _area,
            enabled: !_busy,
            maxLength: 80,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'City / area (optional)',
              helperText: 'For example, Baton Rouge. No street address needed.',
            ),
          ),
          if (!widget.mediaEnabled)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Photos and city/area can be previewed now. Publishing those fields is awaiting server support.',
              ),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _busy || _picking
                ? null
                : () {
                    if (_form.currentState!.validate()) {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ListingDetailPage(
                            listing: _preview(_draft()),
                            preview: true,
                          ),
                        ),
                      );
                    }
                  },
            child: const Text('Preview listing'),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _busy || _picking ? null : _submit,
            icon: _busy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.publish),
            label: Text(_busy ? 'Posting...' : 'Post listing'),
          ),
        ],
      ),
    ),
  );
}
