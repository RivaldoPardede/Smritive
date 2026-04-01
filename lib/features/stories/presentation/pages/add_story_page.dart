import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/flavor_config.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/story_repository.dart';
import '../providers/add_story_provider.dart';

class AddStoryPage extends StatelessWidget {
  const AddStoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AddStoryProvider(
        repository: StoryRepository(context.read<ApiService>()),
        authProvider: context.read<AuthProvider>(),
      ),
      child: const _AddStoryView(),
    );
  }
}

class _AddStoryView extends StatefulWidget {
  const _AddStoryView();

  @override
  State<_AddStoryView> createState() => _AddStoryViewState();
}

class _AddStoryViewState extends State<_AddStoryView> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  bool _descriptionNotEmpty = false;

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(() {
      final notEmpty = _descriptionController.text.trim().isNotEmpty;
      if (notEmpty != _descriptionNotEmpty) {
        setState(() => _descriptionNotEmpty = notEmpty);
      }
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  bool _isSubmittable(AddStoryProvider provider) =>
      provider.selectedImage != null &&
      _descriptionNotEmpty &&
      !provider.isLoading;

  // ── Image picker bottom sheet ──────────────────────────────────────────────

  void _showImageSourceSheet(AddStoryProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.primary,
              ),
              title: Text(l10n.photo_source_gallery, style: AppTextStyles.body),
              onTap: () async {
                sheetContext.pop();
                await provider.pickImage(ImageSource.gallery);
                if (mounted) _checkOversizeError(provider);
              },
            ),
            const Divider(height: 1, color: AppColors.divider),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.primary,
              ),
              title: Text(l10n.photo_source_camera, style: AppTextStyles.body),
              onTap: () async {
                sheetContext.pop();
                await provider.pickImage(ImageSource.camera);
                if (mounted) _checkOversizeError(provider);
              },
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  void _checkOversizeError(AddStoryProvider provider) {
    if (provider.photoOversize && mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.error_photo_too_large),
          backgroundColor: AppColors.error,
        ),
      );
      provider.clearOversizeFlag();
    }
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _submit(AddStoryProvider provider) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (provider.selectedImage == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.photo_required),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    await provider.submit(description: _descriptionController.text.trim());

    if (!mounted) return;

    if (provider.isSuccess) {
      // Signal success back to StoryListPage via pop result.
      context.pop(true);
    } else if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ── Location picker ────────────────────────────────────────────────────────

  Future<void> _openLocationPicker(AddStoryProvider provider) async {
    final result = await context.push<LatLng>(AppRoutes.locationPicker);
    if (result != null && mounted) {
      provider.setLocation(result.latitude, result.longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: Semantics(
          label: l10n.btn_close,
          child: IconButton(
            icon: const Icon(Icons.close, color: AppColors.textPrimary),
            tooltip: l10n.btn_close,
            onPressed: () => context.pop(),
          ),
        ),
        title: Text(l10n.add_story_title, style: AppTextStyles.appTitle),
      ),
      body: Consumer<AddStoryProvider>(
        builder: (context, provider, child) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Image Picker Area ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      0,
                    ),
                    child: GestureDetector(
                      onTap: () => _showImageSourceSheet(provider),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        child: SizedBox(
                          width: double.infinity,
                          height: 220,
                          child: provider.selectedImage == null
                              ? _EmptyImagePicker(l10n: l10n)
                              : _SelectedImagePreview(
                                  file: File(provider.selectedImage!.path),
                                  onEdit: () => _showImageSourceSheet(provider),
                                ),
                        ),
                      ),
                    ),
                  ),

                  // ── Description Field ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.md,
                      0,
                    ),
                    child: TextFormField(
                      controller: _descriptionController,
                      maxLines: 5,
                      minLines: 3,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        labelText: l10n.field_description,
                        hintText: l10n.field_description_hint,
                        alignLabelWithHint: true,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? l10n.validation_required
                          : null,
                    ),
                  ),

                  // ── Location Section (flavor-gated) ────────────────────────
                  _LocationSection(
                    provider: provider,
                    l10n: l10n,
                    onPickLocation: () => _openLocationPicker(provider),
                  ),

                  // ── Submit Button ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: _isSubmittable(provider)
                              ? AppColors.primary
                              : AppColors.primaryLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        onPressed: provider.isLoading
                            ? null
                            : () => _submit(provider),
                        child: provider.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              )
                            : Text(
                                l10n.btn_share_story,
                                style: AppTextStyles.label.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Location Section ──────────────────────────────────────────────────────────

class _LocationSection extends StatelessWidget {
  const _LocationSection({
    required this.provider,
    required this.l10n,
    required this.onPickLocation,
  });

  final AddStoryProvider provider;
  final AppLocalizations l10n;
  final VoidCallback onPickLocation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                l10n.location_section_label,
                style: AppTextStyles.sectionHeader,
              ),
              const Spacer(),
              if (FlavorConfig.isPaid && provider.hasLocation)
                TextButton(
                  onPressed: provider.clearLocation,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(44, 32),
                  ),
                  child: Text(
                    l10n.location_clear,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          if (FlavorConfig.isFree) ...[
            // Free variant: disabled explanation
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 18,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      l10n.location_free_locked,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Paid variant: pick location button or selected preview
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: provider.hasLocation
                  ? _LocationPreview(
                      key: const ValueKey('preview'),
                      lat: provider.selectedLat!,
                      lon: provider.selectedLon!,
                      onEdit: onPickLocation,
                      l10n: l10n,
                    )
                  : _PickLocationButton(
                      key: const ValueKey('picker'),
                      onTap: onPickLocation,
                      l10n: l10n,
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PickLocationButton extends StatelessWidget {
  const _PickLocationButton({
    super.key,
    required this.onTap,
    required this.l10n,
  });

  final VoidCallback onTap;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.add_location_alt_outlined),
      label: Text(l10n.location_pick_btn),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}

class _LocationPreview extends StatelessWidget {
  const _LocationPreview({
    super.key,
    required this.lat,
    required this.lon,
    required this.onEdit,
    required this.l10n,
  });

  final double lat;
  final double lon;
  final VoidCallback onEdit;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primary.withAlpha(60)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontFamily: 'monospace',
              ),
            ),
          ),
          TextButton(
            onPressed: onEdit,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(44, 32),
            ),
            child: Text(
              l10n.location_change,
              style: AppTextStyles.caption.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty image picker state ──────────────────────────────────────────────────

class _EmptyImagePicker extends StatelessWidget {
  const _EmptyImagePicker({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.add_photo_alternate_outlined,
            size: 48,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.photo_select_label,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.photo_select_hint,
            style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

// ── Selected image preview ────────────────────────────────────────────────────

class _SelectedImagePreview extends StatelessWidget {
  const _SelectedImagePreview({required this.file, required this.onEdit});
  final File file;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(file, fit: BoxFit.cover),
        Positioned(
          bottom: AppSpacing.sm,
          right: AppSpacing.sm,
          child: Semantics(
            label: 'Change photo',
            child: GestureDetector(
              onTap: onEdit,
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Icon(Icons.edit, color: AppColors.primary, size: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
