import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/database_provider.dart';
import 'screens/home_screen.dart';
import 'constants/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  runApp(const MuzHesapDefteriApp());
}

class MuzHesapDefteriApp extends StatelessWidget {
  const MuzHesapDefteriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DatabaseProvider()..init()),
      ],
      child: MaterialApp(
        title: 'Muz Hesap Defteri',
        debugShowCheckedModeBanner: false,
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
      ),
    );
  }
}
