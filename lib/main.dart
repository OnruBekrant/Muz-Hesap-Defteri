import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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
            theme: ThemeData(
              primaryColor: AppColors.muzSarisi,
              scaffoldBackgroundColor: AppColors.arkaPlan,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.muzSarisi,
                primary: AppColors.muzSarisi,
                secondary: AppColors.yaprakYesili,
              ),
              useMaterial3: true,
              textTheme: GoogleFonts.robotoTextTheme().copyWith(
                displayLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.metinRengi),
                displayMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.metinRengi),
                bodyLarge: const TextStyle(fontSize: 20, color: AppColors.metinRengi), // Larger text for readability
                bodyMedium: const TextStyle(fontSize: 18, color: AppColors.metinRengi),
                labelLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Button text
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
