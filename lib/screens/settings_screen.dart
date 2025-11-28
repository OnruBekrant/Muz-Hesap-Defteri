import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/database_provider.dart';
import '../models/season.dart';
import '../constants/colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: Consumer<DatabaseProvider>(
        builder: (context, provider, child) {
          final pastSeasons = provider.getPastSeasons();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Theme Settings (Placeholder)
              // Theme Settings
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField<ThemeMode>(
                  decoration: const InputDecoration(
                    labelText: 'Tema Ayarı',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.brightness_6),
                  ),
                  value: provider.themeMode,
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('Sistem Teması'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Aydınlık Tema'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Karanlık (AMOLED)'),
                    ),
                  ],
                  onChanged: (ThemeMode? newValue) {
                    if (newValue != null) {
                      provider.setThemeMode(newValue);
                    }
                  },
                ),
              ),
              const Divider(),

              // History Section
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Geçmiş Sezonlar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.koyuYesil),
                ),
              ),
              if (pastSeasons.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Henüz arşivlenmiş sezon yok.'),
                )
              else
                DropdownButtonFormField<Season>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Geçmiş Sezon Seç',
                    prefixIcon: Icon(Icons.history),
                  ),
                  items: pastSeasons.map((season) {
                    return DropdownMenuItem<Season>(
                      value: season,
                      child: Text(season.name),
                    );
                  }).toList(),
                  onChanged: (selectedSeason) {
                    if (selectedSeason != null) {
                      provider.switchToHistory(selectedSeason);
                      Navigator.pop(context); // Return to Home
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${selectedSeason.name} görüntüleniyor.')),
                      );
                    }
                  },
                ),
              
              const SizedBox(height: 40),
              const Divider(),

              // Danger Zone
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Tehlikeli Bölge',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ),
              ListTile(
                title: const Text('Sezonu Kapat ve Arşivle'),
                subtitle: const Text('Mevcut sezonu bitirir ve yeni bir sezon başlatır.'),
                leading: const Icon(Icons.archive, color: Colors.red),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Sezonu Kapat?'),
                      content: const Text(
                        'Bu işlem mevcut sezonu arşivleyecek ve yeni, boş bir sezon başlatacaktır. Emin misiniz?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('İptal'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () async {
                            await provider.closeSeason();
                            if (context.mounted) {
                              Navigator.pop(context); // Close dialog
                              Navigator.pop(context); // Close settings
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Yeni sezon başlatıldı.')),
                              );
                            }
                          },
                          child: const Text('EVET, KAPAT', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
