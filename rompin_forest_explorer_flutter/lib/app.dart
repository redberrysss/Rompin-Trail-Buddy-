import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme/app_theme.dart';
import 'views/auth/root_view.dart';

class RompinForestApp extends StatelessWidget {
  const RompinForestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rompin Forest Explorer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme.copyWith(
        scaffoldBackgroundColor: AppTheme.creamBackground,
        cardTheme: AppTheme.lightTheme.cardTheme.copyWith(
          color: AppTheme.creamBackground,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: AppTheme.fontSizeHeadline,
            fontWeight: AppTheme.weightSemiBold,
            color: AppTheme.onSurface,
          ),
          iconTheme: IconThemeData(color: AppTheme.onSurface),
        ),
      ),
      locale: const Locale('ms', 'MY'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ms', 'MY'), Locale('en', 'US')],
      home: const RootView(),
    );
  }
}
