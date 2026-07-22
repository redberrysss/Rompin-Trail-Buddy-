import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _groupCodeController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String _selectedRole = 'pelajar';
  bool _privacyAccepted = false;

  @override
  void initState() {
    super.initState();
    _authListener = context.read<AuthViewModel>()..addListener(_onAuthChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.read<AuthViewModel>().authState == AuthState.authenticated) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  AuthViewModel? _authListener;

  void _onAuthChanged() {
    if (!mounted) return;
    final authVM = context.read<AuthViewModel>();
    if (authVM.authState == AuthState.authenticated) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  void dispose() {
    _authListener?.removeListener(_onAuthChanged);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _groupCodeController.dispose();
    super.dispose();
  }

  void _handleRegister(AuthViewModel authVM) {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    print(
      '[RegisterView] handleRegister: email=$email, name=$name, role=$_selectedRole',
    );

    if (name.isEmpty) {
      authVM.setValidationError('Sila masukkan nama penuh.');
      return;
    }
    if (email.isEmpty) {
      authVM.setValidationError('Sila masukkan alamat e-mel.');
      return;
    }
    if (password.isEmpty) {
      authVM.setValidationError('Sila masukkan kata laluan.');
      return;
    }
    if (confirm.isEmpty) {
      authVM.setValidationError('Sila masukkan pengesahan kata laluan.');
      return;
    }

    if (password != confirm) {
      authVM.setValidationError('Kata laluan tidak sepadan.');
      return;
    }

    if (!_privacyAccepted) {
      authVM.setValidationError(
        'Sila bersetuju dengan penyimpanan data aktiviti.',
      );
      return;
    }

    authVM.register(
      name,
      email,
      password,
      _selectedRole,
      groupCode: _selectedRole == 'pelajar' ? _groupCodeController.text : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    print('[RegisterView] build');

    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) {
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
                  // ── Close button ──
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: AppTheme.onSurface),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Header ──
                  const Center(
                    child: Text(
                      'Daftar Akaun Baru',
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeTitle,
                        fontWeight: AppTheme.weightBold,
                        color: AppTheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Cipta akaun untuk mula',
                      style: TextStyle(
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

                  // ── Name field ──
                  const Text(
                    'Nama Penuh',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeCaption,
                      fontWeight: AppTheme.weightMedium,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan nama penuh',
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                    onChanged: (_) => authVM.clearError(),
                  ),
                  const SizedBox(height: 16),

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
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'cth: nama@contoh.com',
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                    onChanged: (_) => authVM.clearError(),
                  ),
                  const SizedBox(height: 16),

                  // ── Password field ──
                  const Text(
                    'Kata Laluan',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeCaption,
                      fontWeight: AppTheme.weightMedium,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: 'Sekurang-kurangnya 6 aksara',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppTheme.secondaryText,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppTheme.secondaryText,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    onChanged: (_) => authVM.clearError(),
                  ),
                  const SizedBox(height: 16),

                  // ── Confirm password field ──
                  const Text(
                    'Pengesahan Kata Laluan',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeCaption,
                      fontWeight: AppTheme.weightMedium,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleRegister(authVM),
                    decoration: InputDecoration(
                      hintText: 'Taip semula kata laluan',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppTheme.secondaryText,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppTheme.secondaryText,
                        ),
                        onPressed: () {
                          setState(() => _obscureConfirm = !_obscureConfirm);
                        },
                      ),
                    ),
                    onChanged: (_) => authVM.clearError(),
                  ),
                  const SizedBox(height: 20),

                  // ── Role picker ──
                  const Text(
                    'Peranan',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeCaption,
                      fontWeight: AppTheme.weightMedium,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedRole = 'pelajar'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedRole == 'pelajar'
                                  ? AppTheme.forestGreen
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusDefault,
                              ),
                              border: Border.all(
                                color: _selectedRole == 'pelajar'
                                    ? AppTheme.forestGreen
                                    : AppTheme.dividerColor,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 18,
                                  color: _selectedRole == 'pelajar'
                                      ? Colors.white
                                      : AppTheme.secondaryText,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Peserta',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: AppTheme.fontSizeCaption,
                                      fontWeight: AppTheme.weightSemiBold,
                                      color: _selectedRole == 'pelajar'
                                          ? Colors.white
                                          : AppTheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedRole = 'fasilitator'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedRole == 'fasilitator'
                                  ? AppTheme.forestGreen
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusDefault,
                              ),
                              border: Border.all(
                                color: _selectedRole == 'fasilitator'
                                    ? AppTheme.forestGreen
                                    : AppTheme.dividerColor,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 18,
                                  color: _selectedRole == 'fasilitator'
                                      ? Colors.white
                                      : AppTheme.secondaryText,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Fasilitator',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: AppTheme.fontSizeCaption,
                                      fontWeight: AppTheme.weightSemiBold,
                                      color: _selectedRole == 'fasilitator'
                                          ? Colors.white
                                          : AppTheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_selectedRole == 'pelajar') ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Kod Kumpulan (Pilihan)',
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeCaption,
                        fontWeight: AppTheme.weightMedium,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _groupCodeController,
                      textCapitalization: TextCapitalization.characters,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        hintText: 'Masukkan kod kumpulan',
                        prefixIcon: Icon(Icons.groups_outlined),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Dapatkan kod daripada fasilitator anda.',
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeSmall,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // ── Privacy toggle ──
                  Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: _privacyAccepted,
                          onChanged: (value) {
                            setState(() => _privacyAccepted = value ?? false);
                          },
                          activeColor: AppTheme.forestGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Saya bersetuju dengan penyimpanan data aktiviti',
                          style: TextStyle(
                            fontSize: AppTheme.fontSizeCaption,
                            color: AppTheme.secondaryText.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── Register button ──
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: authVM.isLoading
                          ? null
                          : () => _handleRegister(authVM),
                      child: authVM.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text('Daftar'),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
