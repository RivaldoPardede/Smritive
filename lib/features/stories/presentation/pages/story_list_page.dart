import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
  int _selectedNav = 0;

  @override
  void initState() {
    super.initState();
    // Fetch on first mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoryListProvider>().fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      // ── Bottom Navigation Bar ──────────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.divider, width: 1),
          ),
        ),
        child: NavigationBar(
          backgroundColor: AppColors.background,
          selectedIndex: _selectedNav,
          indicatorColor: AppColors.primaryLight,
          onDestinationSelected: (i) => setState(() => _selectedNav = i),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home, color: AppColors.primary),
              label: l10n.nav_home,
            ),
            NavigationDestination(
              icon: const Icon(Icons.search),
              selectedIcon: const Icon(Icons.search, color: AppColors.primary),
              label: l10n.nav_search,
            ),
            NavigationDestination(
              icon: const Icon(Icons.bookmark_border),
              selectedIcon:
                  const Icon(Icons.bookmark, color: AppColors.primary),
              label: l10n.nav_saved,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon:
                  const Icon(Icons.person, color: AppColors.primary),
              label: l10n.nav_profile,
            ),
          ],
        ),
      ),

      // ── FAB: Add Story ─────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        onPressed: () => context.push(AppRoutes.addStory),
        child: const Icon(Icons.add_a_photo_outlined),
      ),

      body: _selectedNav == 0
          ? _HomeTab(auth: auth, l10n: l10n)
          : _PlaceholderTab(label: _tabLabel(l10n, _selectedNav)),
    );
  }

  String _tabLabel(AppLocalizations l10n, int index) {
    switch (index) {
      case 1:
        return l10n.nav_search;
      case 2:
        return l10n.nav_saved;
      case 3:
        return l10n.nav_profile;
      default:
        return '';
    }
  }
}

// ── Placeholder for non-Home tabs ─────────────────────────────────────────────

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

// ── Home Tab ──────────────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.auth, required this.l10n});

  final AuthProvider auth;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
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
                if (provider.isLoading) {
                  return const _LoadingSkeleton();
                }
                if (provider.hasError) {
                  return _ErrorState(
                    message: provider.errorMessage ?? '',
                    l10n: l10n,
                    onRetry: () => context.read<StoryListProvider>().fetch(),
                  );
                }
                if (provider.isEmpty) {
                  return _EmptyState(l10n: l10n);
                }
                return _StoryContent(
                  stories: provider.stories,
                  l10n: l10n,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Story Content (Loaded) ─────────────────────────────────────────────────────

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
        // ── Section 1: Popular story ───────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.section_popular, style: AppTextStyles.sectionHeader),
              Text(l10n.link_view_all, style: AppTextStyles.link),
            ],
          ),
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

        // ── Section 2: You may also like ──────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.section_you_may_like,
                  style: AppTextStyles.sectionHeader),
              GestureDetector(
                onTap: () =>
                    context.read<StoryListProvider>().refresh(),
                child: Text(l10n.link_refresh, style: AppTextStyles.link),
              ),
            ],
          ),
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

        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

// ── Popular Story Card (horizontal) ──────────────────────────────────────────

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
                // Image
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: Image.network(
                    story.photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(
                      color: AppColors.surfaceVariant,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.textHint,
                      ),
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
                          story.name,
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

// ── You May Also Like Card (vertical) ────────────────────────────────────────

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.story});
  final Story story;

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
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.surfaceVariant,
                backgroundImage: NetworkImage(story.photoUrl),
                onBackgroundImageError: (exception, stackTrace) {},
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
                      story.name,
                      style: AppTextStyles.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      story.description,
                      style:
                          AppTextStyles.body.copyWith(color: AppColors.textSecondary),
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
        // Popular section skeleton
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
        // List section skeleton
        const Padding(
          padding: EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
          child: ShimmerBox(width: 160, height: 18, borderRadius: 4),
        ),
        ...List.generate(
          3,
          (i) => const Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md,
                AppSpacing.sm),
            child: ShimmerBox(width: double.infinity, height: 96, borderRadius: AppRadius.md),
          ),
        ),
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
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off, color: AppColors.error, size: 48),
          const SizedBox(height: AppSpacing.md),
          Text(
            message.isNotEmpty ? message : l10n.state_error,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: onRetry,
            child: Text(l10n.action_retry,
                style: AppTextStyles.label
                    .copyWith(color: AppColors.primary)),
          ),
        ],
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
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_stories_outlined,
              size: 56, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.state_empty,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
