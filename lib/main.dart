// ルーティングは自動設定。触らなくていい
import 'package:flutter/material.dart';
import 'package:shellapp_runtime/shellapp_runtime.dart';
import 'screens/dynamic_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ShellAppRuntime.init();
  runApp(const ShellApp());
}

class ShellApp extends StatelessWidget {
  const ShellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/main',
      routes: {
        '/main': (context) => const DynamicScreen(screenName: 'main'),
      },
    );
  }
}
