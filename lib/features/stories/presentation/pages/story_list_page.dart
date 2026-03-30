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
        onPressed: () async {
          final provider = context.read<StoryListProvider>();
          final uploaded = await context.push<bool>(AppRoutes.addStory);
          if (uploaded == true) {
            // Called in StoryListPage's own scope — provider is guaranteed here.
            provider.refresh();
          }
        },
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
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.primary,
                        ),
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
                      onRetry: () => context.read<StoryListProvider>().fetch(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section 1: Story Rings (Horizontal) ─────────────────────────
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            itemCount: stories.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: _StoryRing(story: stories[i]),
            ),
          ),
        ),

        const Divider(height: 1, color: AppColors.divider),

        // ── Section 2: The Feed (Vertical) ──────────────────────────────
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: stories.length,
          itemBuilder: (context, i) => _FeedPost(story: stories[i]),
          separatorBuilder: (context, i) =>
              const Divider(color: AppColors.divider, thickness: 1, height: 24),
        ),

        const SizedBox(height: 96), // FAB clearance
      ],
    );
  }
}

// ── Story Ring (Horizontal scroll item) ─────────────────────────────────────

class _StoryRing extends StatelessWidget {
  const _StoryRing({required this.story});
  final Story story;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/stories/${story.id}'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Gradient Ring
          Container(
            padding: const EdgeInsets.all(3), // gradient width
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.storyRingGradient,
            ),
            child: Container(
              padding: const EdgeInsets.all(2), // white gap
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.network(
                    story.photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(
                      color: AppColors.surfaceVariant,
                      child: const Icon(
                        Icons.person,
                        color: AppColors.textHint,
                      ),
                    ),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(color: AppColors.surfaceVariant);
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Name
          SizedBox(
            width: 74,
            child: Text(
              story.name,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Feed Post (Vertical list item) ──────────────────────────────────────────

class _FeedPost extends StatelessWidget {
  const _FeedPost({required this.story});
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
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Post Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.surfaceVariant,
                  backgroundImage: NetworkImage(story.photoUrl),
                  onBackgroundImageError: (e, s) {},
                  child: story.photoUrl.isEmpty
                      ? const Icon(Icons.person, size: 20)
                      : null,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    story.name,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _formatDate(story.createdAt),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // 2. Edge-to-Edge Photo
          GestureDetector(
            onTap: () => context.push('/stories/${story.id}'),
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(
                context,
              ).size.width, // 1:1 aspect ratio square like classic IG
              constraints: const BoxConstraints(maxHeight: 500),
              color: AppColors.surfaceVariant,
              child: Image.network(
                story.photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 48,
                    color: AppColors.textHint,
                  ),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                },
              ),
            ),
          ),

          // 3. Post Caption (Footer)
          GestureDetector(
            onTap: () => context.push('/stories/${story.id}'),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: RichText(
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(
                      text: '${story.name} ',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: story.description),
                  ],
                ),
              ),
            ),
          ),
        ],
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
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: ShimmerBox(width: 120, height: 18, borderRadius: 4),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: 4,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: ShimmerBox(
                width: 130,
                height: 220,
                borderRadius: AppRadius.lg,
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: ShimmerBox(width: 160, height: 18, borderRadius: 4),
        ),
        ...List.generate(
          3,
          (i) => const Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: ShimmerBox(
              width: double.infinity,
              height: 88,
              borderRadius: AppRadius.md,
            ),
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
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
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
            const Icon(
              Icons.auto_stories_outlined,
              size: 56,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.state_empty,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
