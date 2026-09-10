import 'package:flutter/material.dart';
import 'package:malta_wash/Src/App/app.dart';
import 'package:malta_wash/Src/Core/config/app_config.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.validate();
  setupDependencies();
  runApp(const MaltaWashApp());
}
