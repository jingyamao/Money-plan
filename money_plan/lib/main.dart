import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/app_provider.dart';
import 'screens/main_screen.dart';
import 'services/storage_service.dart';
import 'services/supabase_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化本地存储
  await StorageService().init();

  // 初始化 Supabase
  await SupabaseService.initialize();

  // 初始化通知服务
  await NotificationService().initialize();
  await NotificationService().requestPermission();

  runApp(const MoneyPlanApp());
}

class MoneyPlanApp extends StatelessWidget {
  const MoneyPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: MaterialApp(
        title: 'Money Plan',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        locale: const Locale('zh', 'CN'),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('zh', 'CN'),
          Locale('en', 'US'),
        ],
        home: const MainScreen(),
      ),
    );
  }
}
