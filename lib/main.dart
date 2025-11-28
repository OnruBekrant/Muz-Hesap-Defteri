import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'providers/database_provider.dart';
import 'screens/home_screen.dart';
import 'constants/colors.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'models/season.dart';
import 'models/transaction.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await initializeDateFormatting('tr_TR', null);

  // Register Adapters in TypeID Order
  Hive.registerAdapter(SeasonAdapter());          // TypeID: 0
  Hive.registerAdapter(TransactionTypeAdapter()); // TypeID: 1
  Hive.registerAdapter(TransactionAdapter());     // TypeID: 2

  // Open Boxes explicitly before app start
  await Hive.openBox<Season>('seasons');
  await Hive.openBox<Transaction>('transactions');

  // Initialize Provider
  final databaseProvider = DatabaseProvider();
  await databaseProvider.init();

  runApp(MuzHesapDefteriApp(databaseProvider: databaseProvider));
}

class MuzHesapDefteriApp extends StatelessWidget {
  final DatabaseProvider databaseProvider;

  const MuzHesapDefteriApp({super.key, required this.databaseProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: databaseProvider),
      ],
      child: Consumer<DatabaseProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'Muz Hesap Defteri',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('tr', 'TR'),
            ],
            locale: const Locale('tr', 'TR'),
            themeMode: provider.themeMode,
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Colors.black, // Saf Siyah (AMOLED)
              primaryColor: Colors.green, // Yaprak Yeşili (Marka rengi korunsun)
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.black, // Bar da siyah olsun
                elevation: 0,
                titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
                iconTheme: IconThemeData(color: Colors.white),
              ),
              cardColor: const Color(0xFF1E1E1E), // Kartlar hafif gri kalsın ki ayırt edilsin
              colorScheme: const ColorScheme.dark(
                primary: Colors.green,
                secondary: Colors.yellow, // Muz Sarısı detaylar
                surface: Colors.black,
              ),
              // Yazı tipleri okunabilir beyaz/gri olsun
              textTheme: ThemeData.light().textTheme.apply(
                fontFamily: 'Roboto',
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
            ),
            theme: ThemeData(
              primaryColor: AppColors.muzSarisi,
              scaffoldBackgroundColor: AppColors.arkaPlan,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.muzSarisi,
                primary: AppColors.muzSarisi,
                secondary: AppColors.yaprakYesili,
              ),
              useMaterial3: true,
              textTheme: ThemeData.light().textTheme.apply(
                fontFamily: 'Roboto',
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.yaprakYesili,
                foregroundColor: Colors.white,
                centerTitle: true,
                titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.muzSarisi,
                  foregroundColor: AppColors.metinRengi,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
