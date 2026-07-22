import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'viewmodels/auth_viewmodel.dart';

bool firebaseReady = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    firebaseReady = true;
    print('========== Firebase initialized ==========');
  } catch (e, stack) {
    print('========== Firebase init FAILED ==========');
    print('Error: $e');
    print('Stack: $stack');
    firebaseReady = false;
  }

  await Hive.initFlutter();
  await Hive.openBox('offlineData');

  print('========== APP START ==========');
  print('Firebase project: rompin-trail-buddy');
  print('Firebase ready: $firebaseReady');

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthViewModel())],
      child: const RompinForestApp(),
    ),
  );
}
