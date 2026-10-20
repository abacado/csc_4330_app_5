import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'features/home/app_shell.dart';

class HobbySwapApp extends StatelessWidget {
  const HobbySwapApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'HobbySwap',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: const AppShell(),
  );
}
