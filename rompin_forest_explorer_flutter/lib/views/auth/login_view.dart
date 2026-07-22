import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'forgot_password_view.dart';
import 'register_view.dart';

class LoginView extends StatefulWidget {
  final VoidCallback? onSwitchRole;

  const LoginView({super.key, this.onSwitchRole});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) {
        final roleLabel = authVM.selectedRole == 'fasilitator'
            ? 'Fasilitator'
            : 'Pelajar';

        return Scaffold(
          backgroundColor: AppTheme.creamBackground,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingLarge,
                vertical: AppTheme.paddingStandard,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // ── Header ──
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppTheme.forestGreen.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.eco,
                        size: 32,
                        color: AppTheme.forestGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      'Rompin Forest Explorer',
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeTitle,
                        fontWeight: AppTheme.weightBold,
                        color: AppTheme.darkGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Log Masuk $roleLabel',
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeBody,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Error message ──
                  if (authVM.errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.gentleCoral.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: AppTheme.gentleCoral,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
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

                  // ── Email ──
                  const Text(
                    'E-mel',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeCaption,
                      fontWeight: AppTheme.weightMedium,
                      color: AppTheme.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan e-mel',
                    ),
                    onChanged: (_) => authVM.clearError(),
                  ),
                  const SizedBox(height: 16),

                  // ── Password ──
                  const Text(
                    'Kata Laluan',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeCaption,
                      fontWeight: AppTheme.weightMedium,
                      color: AppTheme.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleLogin(authVM),
                    decoration: InputDecoration(
                      hintText: 'Masukkan kata laluan',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppTheme.secondaryText,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    onChanged: (_) => authVM.clearError(),
                  ),
                  const SizedBox(height: 24),

                  // ── Login button ──
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: authVM.isLoading
                          ? null
                          : () => _handleLogin(authVM),
                      child: authVM.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Log Masuk'),
                                const SizedBox(width: 8),
                                Icon(Icons.arrow_forward, color: Colors.white),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Forgot password ──
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordView(),
                        ),
                      ),
                      child: const Text(
                        'Lupa Kata Laluan?',
                        style: TextStyle(
                          fontSize: AppTheme.fontSizeBody,
                          color: AppTheme.forestGreen,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Divider ──
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: AppTheme.dividerColor),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'atau',
                          style: TextStyle(
                            fontSize: AppTheme.fontSizeCaption,
                            color: AppTheme.secondaryText,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: AppTheme.dividerColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Register button ──
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegisterView()),
                      ),
                      icon: const Icon(Icons.person_add_outlined),
                      label: const Text('Daftar Akaun Baru'),
                    ),
                  ),

                  // ── Switch role ──
                  if (widget.onSwitchRole != null) ...[
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: widget.onSwitchRole,
                        child: Text(
                          'Tukar Peranan',
                          style: TextStyle(
                            fontSize: AppTheme.fontSizeCaption,
                            color: AppTheme.secondaryText.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleLogin(AuthViewModel authVM) {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      authVM.setValidationError('Sila masukkan alamat e-mel.');
      return;
    }
    if (password.isEmpty) {
      authVM.setValidationError('Sila masukkan kata laluan.');
      return;
    }

    print(
      '[LoginView] signIn: email=$email, selectedRole=${authVM.selectedRole}',
    );
    authVM.signIn(email, password);
  }
}
