import 'package:flutter/material.dart';
import 'package:malta_wash/Src/App/theme/app_theme.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';
import 'package:malta_wash/Src/Core/router/app_router.dart';

class MaltaWashApp extends StatelessWidget {
  const MaltaWashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Malta Wash — Gestão & Agendamento Automotivo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: sl<AppRouter>().router,
    );
  }
}
