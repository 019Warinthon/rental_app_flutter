import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rental_app/core/config/theme.dart';
import 'package:rental_app/core/router/app_router.dart';
import 'package:rental_app/modules/main/providers/favorites_provider.dart';
import 'package:rental_app/modules/booking/providers/booking_provider.dart';
import 'package:rental_app/modules/profile/providers/user_provider.dart';
import 'package:rental_app/modules/profile/providers/settings_provider.dart';
import 'package:rental_app/modules/auth/providers/auth_provider.dart';
import 'package:rental_app/modules/home/providers/home_provider.dart';
import 'package:rental_app/modules/room_detail/providers/review_provider.dart';
import 'package:rental_app/core/api/api_client.dart';
import 'package:rental_app/modules/images/providers/storage_providers.dart';
import 'package:rental_app/modules/chat/providers/chat_provider.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('th')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProxyProvider<UserProvider, FavoritesProvider>(
          create: (_) => FavoritesProvider(),
          update: (_, userProvider, favProvider) =>
              favProvider!..updateUser(userProvider.user.id),
        ),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        Provider<ApiClient>(create: (_) => ApiClient()),
        ...StorageProviders.providers,
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProxyProvider<UserProvider, ChatProvider>(
          create: (_) => ChatProvider(),
          update: (_, userProvider, chatProvider) =>
              chatProvider!..updateProxy(userProvider),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp.router(
            title: 'Rental App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: AppRouter.router,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
          );
        },
      ),
    );
  }
}
