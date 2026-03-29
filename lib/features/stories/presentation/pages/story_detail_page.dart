import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/shimmer_box.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/story_repository.dart';
import '../../domain/story.dart';
import '../providers/story_detail_provider.dart';

class StoryDetailPage extends StatelessWidget {
  const StoryDetailPage({super.key, required this.storyId});

  final String storyId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StoryDetailProvider(
        repository: StoryRepository(context.read<ApiService>()),
        token: context.read<AuthProvider>().token ?? '',
      )..fetch(storyId),
      child: _StoryDetailView(storyId: storyId),
    );
  }
}

class _StoryDetailView extends StatelessWidget {
  const _StoryDetailView({required this.storyId});
  final String storyId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(l10n.appTitle, style: AppTextStyles.appTitle),
      ),
      body: Consumer<StoryDetailProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const _DetailSkeleton();
          }
          if (provider.hasError) {
            return _DetailError(
              message: provider.errorMessage ?? '',
              l10n: l10n,
              onRetry: () => provider.fetch(storyId),
            );
          }
          final story = provider.story;
          if (story == null) return const SizedBox.shrink();
          return _DetailContent(story: story, l10n: l10n);
        },
      ),
    );
  }
}

// ── Detail Content ────────────────────────────────────────────────────────────

class _DetailContent extends StatefulWidget {
  const _DetailContent({required this.story, required this.l10n});
  final Story story;
  final AppLocalizations l10n;

  @override
  State<_DetailContent> createState() => _DetailContentState();
}

class _DetailContentState extends State<_DetailContent> {
  bool _bookmarked = false;

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.story;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero Image ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md)
                .copyWith(top: AppSpacing.md),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: SizedBox(
                width: double.infinity,
                height: 260,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Network image
                    Image.network(
                      story.photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Container(
                        color: AppColors.surfaceVariant,
                        child: const Icon(Icons.broken_image_outlined,
                            size: 48, color: AppColors.textHint),
                      ),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(color: AppColors.surfaceVariant);
                      },
                    ),
                    // Bookmark button — bottom right
                    Positioned(
                      bottom: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: Semantics(
                        label: _bookmarked ? 'Remove bookmark' : 'Add bookmark',
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _bookmarked = !_bookmarked),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                            child: Icon(
                              _bookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Content ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md)
                .copyWith(top: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title (story name)
                Text(
                  story.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),

                // Author / date subline
                Text(
                  _formatDate(story.createdAt),
                  style: AppTextStyles.author,
                ),
                const SizedBox(height: AppSpacing.sm),

                // Stats row — API does not return stats; display "--"
                Row(
                  children: [
                    _StatItem(
                        icon: Icons.visibility_outlined, label: '--'),
                    const SizedBox(width: AppSpacing.md),
                    _StatItem(
                        icon: Icons.bookmark_border, label: '--'),
                    const SizedBox(width: AppSpacing.md),
                    _StatItem(
                        icon: Icons.share_outlined, label: '--'),
                  ],
                ),

                const Divider(
                  color: AppColors.divider,
                  height: AppSpacing.xl,
                ),

                // Date
                Text(
                  _formatDate(story.createdAt),
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.xs),

                // "The Story" section label
                Text(
                  widget.l10n.story_section_label,
                  style: AppTextStyles.sectionHeader,
                ),
                const SizedBox(height: AppSpacing.sm),

                // Description body
                Text(
                  story.description,
                  style: AppTextStyles.body.copyWith(height: 1.6),
                ),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Item ─────────────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  const _StatItem({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.statIcon),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption.copyWith(
          color: AppColors.statIcon,
        )),
      ],
    );
  }
}

// ── Loading Skeleton ──────────────────────────────────────────────────────────

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(
            width: double.infinity,
            height: 260,
            borderRadius: AppRadius.lg,
          ),
          const SizedBox(height: AppSpacing.md),
          const ShimmerBox(width: 200, height: 22, borderRadius: 4),
          const SizedBox(height: AppSpacing.sm),
          const ShimmerBox(width: 120, height: 14, borderRadius: 4),
          const SizedBox(height: AppSpacing.md),
          const ShimmerBox(width: double.infinity, height: 14, borderRadius: 4),
          const SizedBox(height: AppSpacing.sm),
          const ShimmerBox(width: double.infinity, height: 14, borderRadius: 4),
          const SizedBox(height: AppSpacing.sm),
          const ShimmerBox(width: 180, height: 14, borderRadius: 4),
        ],
      ),
    );
  }
}

// ── Error State ───────────────────────────────────────────────────────────────

class _DetailError extends StatelessWidget {
  const _DetailError({
    required this.message,
    required this.l10n,
    required this.onRetry,
  });

  final String message;
  final AppLocalizations l10n;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(
              message.isNotEmpty ? message : l10n.state_error,
              style:
                  AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: onRetry,
              child: Text(
                l10n.action_retry,
                style: AppTextStyles.label.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
