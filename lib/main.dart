import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/services/local_notification_service.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  await LocalNotificationService.instance.init();
  await LocalNotificationService.instance.requestPermission();

  runApp(const ProviderScope(child: PustakalayaApp()));
}

class PustakalayaApp extends StatelessWidget {
  const PustakalayaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pustakalaya',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}
