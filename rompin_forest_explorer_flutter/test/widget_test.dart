import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:rompin_forest_explorer/app.dart';
import 'package:rompin_forest_explorer/viewmodels/auth_viewmodel.dart';
import 'package:rompin_forest_explorer/views/auth/role_selection_view.dart';
import 'package:rompin_forest_explorer/views/main_tab_view.dart';
import 'package:rompin_forest_explorer/views/student/student_explore_view.dart';

void main() {
  testWidgets('selecting facilitator shows localized login fields', (
    WidgetTester tester,
  ) async {
    final authViewModel = AuthViewModel(initialize: false);
    addTearDown(authViewModel.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthViewModel>.value(
        value: authViewModel,
        child: const RompinForestApp(),
      ),
    );

    await tester.tap(find.text('Fasilitator'));
    await tester.pump();

    expect(find.text('Log Masuk Fasilitator'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('bottom navigation fits a narrow screen with large text', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(
          body: const SizedBox.expand(),
          bottomNavigationBar: AppBottomNavigationBar(
            isFacilitator: false,
            currentIndex: 3,
            onSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Penemuan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('role selection scrolls on a short large-text screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.8)),
          child: child!,
        ),
        home: RoleSelectionView(onSelectRole: (_) {}),
      ),
    );

    expect(find.text('Fasilitator'), findsOneWidget);
    expect(find.text('Peserta'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Teroka fits a narrow screen with large text', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: const StudentExploreView(participantID: 'student-test'),
      ),
    );
    await tester.pump();

    expect(find.text('Apa yang anda nampak?'), findsOneWidget);
    expect(find.text('Buka Kamera'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
