import 'package:flutter/material.dart';

import 'config/routes/app_router.dart';
import 'config/theme/app_theme.dart';

class FundiConnectApp extends StatelessWidget {
  const FundiConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Fundi Connect',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      theme: AppTheme.lightTheme,
    );
  }
}
