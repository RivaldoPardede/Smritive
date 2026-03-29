import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/locale_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/shimmer_box.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/story.dart';
import '../providers/story_list_provider.dart';

class StoryListPage extends StatefulWidget {
  const StoryListPage({super.key});

  @override
  State<StoryListPage> createState() => _StoryListPageState();
}

class _StoryListPageState extends State<StoryListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoryListProvider>().fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.read<AuthProvider>();
    final locale = context.read<LocaleProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      // ── FAB: Add Story ─────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        tooltip: l10n.add_story_title,
        onPressed: () => context.push(AppRoutes.addStory),
        child: const Icon(Icons.add_a_photo_outlined),
      ),

      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => context.read<StoryListProvider>().refresh(),
        child: CustomScrollView(
          slivers: [
            // ── SliverAppBar ────────────────────────────────────────────────
            SliverAppBar(
              floating: true,
              pinned: false,
              backgroundColor: AppColors.background,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              title: Text(l10n.appTitle, style: AppTextStyles.appTitle),
              actions: [
                // Language toggle button
                TextButton(
                  onPressed: locale.toggle,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(44, 44),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.language, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        l10n.lang_switch_label,
                        style: AppTextStyles.label
                            .copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                // Logout
                IconButton(
                  icon: const Icon(Icons.logout, color: AppColors.textPrimary),
                  tooltip: l10n.logout,
                  onPressed: () async => auth.clearSession(),
                ),
              ],
            ),

            // ── Content ─────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Consumer<StoryListProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) return const _LoadingSkeleton();
                  if (provider.hasError) {
                    return _ErrorState(
                      message: provider.errorMessage ?? '',
                      l10n: l10n,
                      onRetry: () =>
                          context.read<StoryListProvider>().fetch(),
                    );
                  }
                  if (provider.isEmpty) return _EmptyState(l10n: l10n);
                  return _StoryContent(stories: provider.stories, l10n: l10n);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Story Content (Loaded) ────────────────────────────────────────────────────

class _StoryContent extends StatelessWidget {
  const _StoryContent({required this.stories, required this.l10n});

  final List<Story> stories;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final popular = stories.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section 1: Popular story ───────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm,
          ),
          child: Text(l10n.section_popular, style: AppTextStyles.sectionHeader),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: popular.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: _PopularCard(story: popular[i]),
            ),
          ),
        ),

        // ── Section 2: You may also like ──────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm,
          ),
          child: Text(l10n.section_you_may_like,
              style: AppTextStyles.sectionHeader),
        ),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          itemCount: stories.length,
          itemBuilder: (context, i) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _StoryCard(story: stories[i]),
          ),
        ),

        const SizedBox(height: 80), // FAB clearance
      ],
    );
  }
}

// ── Popular Story Card (horizontal scroll) ────────────────────────────────────

class _PopularCard extends StatelessWidget {
  const _PopularCard({required this.story});
  final Story story;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/stories/${story.id}'),
      child: SizedBox(
        width: 130,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: Image.network(
                    story.photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(
                      color: AppColors.surfaceVariant,
                      child: const Icon(Icons.broken_image_outlined,
                          color: AppColors.textHint),
                    ),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(color: AppColors.surfaceVariant);
                    },
                  ),
                ),
                // Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story.description,
                          style: AppTextStyles.cardTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          story.name,
                          style: AppTextStyles.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── You May Also Like Card (vertical) ─────────────────────────────────────────

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.story});
  final Story story;

  String _formatDate(String iso) {
    try {
      return iso.length >= 10 ? iso.substring(0, 10) : iso;
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => context.push('/stories/${story.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail avatar
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Image.network(
                    story.photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(
                      color: AppColors.surfaceVariant,
                      child: const Icon(Icons.broken_image_outlined,
                          size: 24, color: AppColors.textHint),
                    ),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(color: AppColors.surfaceVariant);
                    },
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Text column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.name,
                      style: AppTextStyles.cardTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(story.createdAt),
                      style: AppTextStyles.author,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      story.description,
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Loading Skeleton ──────────────────────────────────────────────────────────

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
          child: ShimmerBox(width: 120, height: 18, borderRadius: 4),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: 4,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: ShimmerBox(
                  width: 130, height: 220, borderRadius: AppRadius.lg),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
          child: ShimmerBox(width: 160, height: 18, borderRadius: 4),
        ),
        ...List.generate(
          3,
          (i) => const Padding(
            padding: EdgeInsets.fromLTRB(
                AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
            child: ShimmerBox(
                width: double.infinity,
                height: 88,
                borderRadius: AppRadius.md),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

// ── Error State ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.l10n,
    required this.onRetry,
  });

  final String message;
  final AppLocalizations l10n;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, color: AppColors.error, size: 48),
              const SizedBox(height: AppSpacing.md),
              Text(
                message.isNotEmpty ? message : l10n.state_error,
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(l10n.action_retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_stories_outlined,
                size: 56, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.state_empty,
              style:
                  AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
