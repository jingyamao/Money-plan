import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/app_provider.dart';
import 'screens/main_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService().init();
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
        home: const MainScreen(),
      ),
    );
  }
}
