import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'student/student_home_view.dart';
import 'student/student_explore_view.dart';
import 'student/student_activities_view.dart';
import 'student/student_discoveries_view.dart';
import 'student/student_profile_view.dart';
import 'facilitator/facilitator_dashboard_view.dart';
import 'facilitator/facilitator_students_view.dart';
import 'facilitator/facilitator_activities_view.dart';
import 'facilitator/facilitator_reports_view.dart';
import 'facilitator/facilitator_profile_view.dart';

class MainTabView extends StatefulWidget {
  final String? participantID;
  final String? participantName;

  const MainTabView({super.key, this.participantID, this.participantName});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final isFasilitator = authVM.isFasilitator;

    return Scaffold(
      backgroundColor: AppTheme.creamBackground,
      body: IndexedStack(
        index: _currentIndex,
        children: isFasilitator ? _facilitatorTabs() : _studentTabs(),
      ),
      bottomNavigationBar: _floatingTabBar(isFasilitator),
    );
  }

  List<Widget> _facilitatorTabs() {
    return [
      const FacilitatorDashboardView(),
      const FacilitatorStudentsView(),
      const FacilitatorActivitiesView(),
      const FacilitatorReportsView(),
      const FacilitatorProfileView(),
    ];
  }

  List<Widget> _studentTabs() {
    final pid = widget.participantID ?? '';
    final pname = widget.participantName ?? 'Peserta';
    return [
      StudentHomeView(participantID: pid, participantName: pname),
      StudentExploreView(participantID: pid),
      StudentActivitiesView(participantID: pid, participantName: pname),
      StudentDiscoveriesView(participantID: pid),
      StudentProfileView(participantID: pid, participantName: pname),
    ];
  }

  Widget _floatingTabBar(bool isFasilitator) {
    return AppBottomNavigationBar(
      isFacilitator: isFasilitator,
      currentIndex: _currentIndex,
      onSelected: (index) => setState(() => _currentIndex = index),
    );
  }
}

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    super.key,
    required this.isFacilitator,
    required this.currentIndex,
    required this.onSelected,
  });

  final bool isFacilitator;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final facilitatorItems = [
      _TabItem(icon: Icons.home_filled, label: 'Laman'),
      _TabItem(icon: Icons.people, label: 'Pelajar'),
      _TabItem(icon: Icons.dashboard, label: 'Aktiviti'),
      _TabItem(icon: Icons.bar_chart, label: 'Laporan'),
      _TabItem(icon: Icons.person, label: 'Profil'),
    ];

    final studentItems = [
      _TabItem(icon: Icons.home_filled, label: 'Laman'),
      _TabItem(icon: Icons.explore, label: 'Teroka'),
      _TabItem(icon: Icons.dashboard, label: 'Aktiviti'),
      _TabItem(icon: Icons.star, label: 'Penemuan'),
      _TabItem(icon: Icons.person, label: 'Profil'),
    ];

    final items = isFacilitator ? facilitatorItems : studentItems;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            children: List.generate(items.length, (index) {
              final isSelected = currentIndex == index;
              final item = items[index];
              final selectedColor = isFacilitator
                  ? AppTheme.forestGreen
                  : AppTheme.darkGreen;
              return Expanded(
                child: Semantics(
                  selected: isSelected,
                  button: true,
                  label: item.label,
                  child: InkWell(
                    onTap: () => onSelected(index),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      constraints: const BoxConstraints(minHeight: 52),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 5,
                      ),
                      decoration: isSelected
                          ? BoxDecoration(
                              color: selectedColor.withValues(alpha: 0.11),
                              borderRadius: BorderRadius.circular(16),
                            )
                          : null,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item.icon,
                            size: isSelected ? 22 : 20,
                            color: isSelected
                                ? selectedColor
                                : AppTheme.secondaryText,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10.5,
                              height: 1.1,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? selectedColor
                                  : AppTheme.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  _TabItem({required this.icon, required this.label});
}
