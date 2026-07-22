import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'login_view.dart';
import 'role_selection_view.dart';
import '../main_tab_view.dart';

class RootView extends StatelessWidget {
  const RootView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) {
        print(
          '[RootView] authState=${authVM.authState} role=${authVM.userRole} selectedRole=${authVM.selectedRole}',
        );

        switch (authVM.authState) {
          case AuthState.loading:
            return const Scaffold(
              backgroundColor: AppTheme.creamBackground,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppTheme.forestGreen,
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Memuatkan...',
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeBody,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            );

          case AuthState.unauthenticated:
            if (authVM.selectedRole != null) {
              return LoginView(
                onSwitchRole: () {
                  authVM.selectedRole = null;
                },
              );
            }
            return RoleSelectionView(
              onSelectRole: (role) {
                print('[RootView] role selected: "$role"');
                authVM.selectedRole = role;
              },
            );

          case AuthState.authenticated:
            final pid = authVM.user?.uid ?? '';
            final pname = authVM.user?.displayName ?? 'Peserta';
            final isFac = authVM.isFasilitator;

            return MainTabView(
              participantID: isFac ? null : pid,
              participantName: isFac ? null : pname,
            );
        }
      },
    );
  }
}
