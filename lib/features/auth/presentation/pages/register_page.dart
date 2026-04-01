import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/auth_repository.dart';
import '../providers/register_provider.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RegisterProvider(
        repository: AuthRepository(context.read<ApiService>()),
      ),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordVisible = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordVisible.dispose();
    super.dispose();
  }

  Future<void> _submit(RegisterProvider provider) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await provider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (provider.isSuccess && mounted) {
      // Pop back so user lands on Login to sign in with their new account
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          // ── Part A: illustration area ─────────────────────────────────
          _IllustrationArea(title: l10n.appTitle),

          // ── Part B: content area ──────────────────────────────────────
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - value)),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.xl),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.register_title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.register_subtitle,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Name
                        TextFormField(
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: l10n.field_name,
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              color: AppColors.primary,
                            ),
                          ),
                          validator: (v) {
                            final l10n = AppLocalizations.of(context)!;
                            return (v == null || v.trim().isEmpty)
                                ? l10n.validation_required
                                : null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: l10n.field_email,
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: AppColors.primary,
                            ),
                          ),
                          validator: (v) {
                            final l10n = AppLocalizations.of(context)!;
                            return (v == null || v.trim().isEmpty)
                                ? l10n.validation_required
                                : null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Password
                        ValueListenableBuilder<bool>(
                          valueListenable: _passwordVisible,
                          builder: (context, visible, child) => TextFormField(
                            controller: _passwordController,
                            obscureText: !visible,
                            decoration: InputDecoration(
                              labelText: l10n.field_password,
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: AppColors.primary,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  visible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () =>
                                    _passwordVisible.value = !visible,
                              ),
                            ),
                            validator: (v) {
                              final l10n = AppLocalizations.of(context)!;
                              if (v == null || v.isEmpty) {
                                return l10n.validation_required;
                              }
                              if (v.length < 8) {
                                return l10n.validation_password_min;
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Register button
                        Consumer<RegisterProvider>(
                          builder: (context, provider, child) => SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: FilledButton(
                              onPressed: provider.isLoading
                                  ? null
                                  : () => _submit(provider),
                              child: provider.isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    )
                                  : Text(l10n.btn_register),
                            ),
                          ),
                        ),

                        // Error message
                        Consumer<RegisterProvider>(
                          builder: (context, provider, child) {
                            final msg = provider.errorMessage;
                            if (msg == null) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(
                                top: AppSpacing.sm,
                              ),
                              child: Center(
                                child: Text(
                                  msg,
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.error,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        ),

                        // Login redirect
                        const SizedBox(height: AppSpacing.md),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              children: [
                                TextSpan(text: l10n.auth_have_account),
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () => context.pop(),
                                    child: Text(
                                      l10n.btn_login,
                                      style: AppTextStyles.link,
                                    ),
                                  ),
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
            ),
          ),
        ],
      ),
    );
  }
}

class _IllustrationArea extends StatelessWidget {
  const _IllustrationArea({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      color: AppColors.background,
      padding: EdgeInsets.only(
        top: safeTop + AppSpacing.xl,
        bottom: AppSpacing.md,
        left: AppSpacing.xl,
        right: AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/icons/custom/smritive-icon.png',
            width: 80,
            height: 80,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: AppTextStyles.appTitle.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppLocalizations.of(context)!.auth_tagline,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
