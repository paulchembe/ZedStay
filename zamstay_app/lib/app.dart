import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/router/app_router.dart';

// Language provider
final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));
// Simple translation provider
final languageProvider = StateProvider<String>((ref) => 'en');

class AppStrings {
  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'findAccommodation': 'Find Accommodation',
      'myListings': 'My Listings',
      'myBookings': 'My Bookings',
      'bookingRequests': 'Booking Requests',
      'messages': 'Messages',
      'addNewListing': 'Add New Listing',
      'bookNow': 'Book Now',
      'welcomeBack': 'Welcome back!',
      'searchByCity': 'Search by city — Lusaka, Kitwe...',
      'noListingsFound': 'No listings found',
      'offline': 'You are offline — showing cached listings',
    },
    'ny': {
      'findAccommodation': 'Peza Malo Ogona',
      'myListings': 'Malo Anga',
      'myBookings': 'Zobukitsa Zanga',
      'bookingRequests': 'Zopempha Zobukitsa',
      'messages': 'Mauthenga',
      'addNewListing': 'Onjeza Malo Atsopano',
      'bookNow': 'Bukitsa Tsopano',
      'welcomeBack': 'Tawelokomanso!',
      'searchByCity': 'Sakha mzinda — Lusaka, Kitwe...',
      'noListingsFound': 'Palibe malo apezeka',
      'offline': 'Mulibe intaneti — tikuwonetsa malo osungidwa',
    },
  };

  static String get(String key, String lang) {
    return _strings[lang]?[key] ?? _strings['en']![key] ?? key;
  }
}

class ZamStayApp extends ConsumerWidget {
  const ZamStayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'ZedStay',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ny'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        // Fall back to English for any unsupported locale
        if (locale == null) return const Locale('en');
        for (final supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }
        return const Locale('en');
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B3A6B),
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}