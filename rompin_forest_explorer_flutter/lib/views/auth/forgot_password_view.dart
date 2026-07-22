import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleReset(AuthViewModel authVM) {
    final email = _emailController.text.trim();

    print('[ForgotPasswordView] handleReset: email=$email');

    if (email.isEmpty) {
      authVM.setValidationError('Sila masukkan alamat e-mel.');
      return;
    }

    authVM.resetPassword(email).then((success) {
      if (success && mounted) {
        setState(() => _emailSent = true);
        print('[ForgotPasswordView] reset email sent');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('[ForgotPasswordView] build');

    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) {
        return Scaffold(
          backgroundColor: AppTheme.creamBackground,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingLarge,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // ── Header ──
                const Icon(
                  Icons.lock_reset,
                  size: 48,
                  color: AppTheme.forestGreen,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Set Semula Kata Laluan',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeTitle,
                    fontWeight: AppTheme.weightBold,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Masukkan alamat e-mel anda dan kami akan menghantar pautan untuk set semula kata laluan.',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeBody,
                    color: AppTheme.secondaryText,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Success message ──
                if (_emailSent) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusDefault,
                      ),
                      border: Border.all(
                        color: AppTheme.successGreen.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: AppTheme.successGreen,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'E-mel set semula kata laluan telah dihantar.',
                            style: TextStyle(
                              fontSize: AppTheme.fontSizeCaption,
                              color: AppTheme.successGreen,
                              fontWeight: AppTheme.weightMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Kembali ke Log Masuk'),
                    ),
                  ),
                ] else ...[
                  // ── Error message ──
                  if (authVM.errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.gentleCoral.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusDefault,
                        ),
                        border: Border.all(
                          color: AppTheme.gentleCoral.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppTheme.gentleCoral,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              authVM.errorMessage!,
                              style: const TextStyle(
                                fontSize: AppTheme.fontSizeCaption,
                                color: AppTheme.gentleCoral,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Email field ──
                  const Text(
                    'E-mel',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeCaption,
                      fontWeight: AppTheme.weightMedium,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleReset(authVM),
                    decoration: const InputDecoration(
                      hintText: 'Masukkan alamat e-mel anda',
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                    onChanged: (_) => authVM.clearError(),
                  ),
                  const SizedBox(height: 28),

                  // ── Submit button ──
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: authVM.isLoading
                          ? null
                          : () => _handleReset(authVM),
                      child: authVM.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text('Hantar E-mel Set Semula'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
