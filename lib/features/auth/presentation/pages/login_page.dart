import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_service.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/auth_repository.dart';
import '../providers/auth_provider.dart';
import '../providers/login_provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginProvider(
        repository: AuthRepository(context.read<ApiService>()),
        authProvider: context.read<AuthProvider>(),
      ),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordVisible = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordVisible.dispose();
    super.dispose();
  }

  Future<void> _submit(LoginProvider provider) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await provider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          // ── Part A: illustration area ─────────────────────────────────
          _IllustrationArea(
            icon: Icons.menu_book_rounded,
            title: l10n.appTitle,
          ),

          // ── Part B: content area ──────────────────────────────────────
          Expanded(
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
                        l10n.login_title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.login_subtitle,
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.lg),

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
                            return (v == null || v.isEmpty)
                                ? l10n.validation_required
                                : null;
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Login button
                      Consumer<LoginProvider>(
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
                                : Text(l10n.btn_login),
                          ),
                        ),
                      ),

                      // Error message
                      Consumer<LoginProvider>(
                        builder: (context, provider, _) {
                          final msg = provider.errorMessage;
                          if (msg == null) return const SizedBox.shrink();
                          return Padding(
                            padding:
                                const EdgeInsets.only(top: AppSpacing.sm),
                            child: Center(
                              child: Text(
                                msg,
                                style: AppTextStyles.body
                                    .copyWith(color: AppColors.error),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),

                      // Register redirect
                      const SizedBox(height: AppSpacing.md),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            style: AppTextStyles.body
                                .copyWith(color: AppColors.textSecondary),
                            children: [
                              TextSpan(text: l10n.auth_no_account),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () =>
                                      context.go(AppRoutes.register),
                                  child: Text(
                                    l10n.btn_register,
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
        ],
      ),
    );
  }
}

// ── Shared illustration area widget ───────────────────────────────────────────

class _IllustrationArea extends StatelessWidget {
  const _IllustrationArea({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      height: 220 + safeTop,
      color: AppColors.primaryLight,
      padding: EdgeInsets.only(top: safeTop),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 72, color: AppColors.primary),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: AppTextStyles.appTitle.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
