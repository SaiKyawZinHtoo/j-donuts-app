import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:j_donuts_app/core/di/service_locator.dart';
import 'package:j_donuts_app/core/router/app_router.dart';
import 'package:j_donuts_app/data/local/database.dart';
import 'package:j_donuts_app/data/local/seed/seed_loader.dart';
import 'package:j_donuts_app/l10n/app_localizations.dart';

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
