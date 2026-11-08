import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'core/di/service_locator.dart';
import 'core/router/app_router.dart';
import 'data/local/database.dart';
import 'data/local/seed/seed_loader.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupServiceLocator();
  await SeedLoader(GetIt.instance<AppDatabase>()).seedIfNeeded();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'J Donuts',
      routerConfig: appRouter,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
