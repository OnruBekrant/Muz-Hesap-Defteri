import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/database_provider.dart';
import '../models/season.dart';
import '../constants/colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Season? _selectedSeasonToDelete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: Consumer<DatabaseProvider>(
        builder: (context, provider, child) {
          final pastSeasons = provider.getPastSeasons();

          // Ensure selected value is valid (it might have been deleted)
          if (_selectedSeasonToDelete != null && !pastSeasons.contains(_selectedSeasonToDelete)) {
             _selectedSeasonToDelete = null;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
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

              // Notification Settings
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Bildirim Ayarları',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.koyuYesil),
                ),
              ),
              SwitchListTile(
                title: const Text('Ödeme Hatırlatıcıları'),
                subtitle: const Text('Vadesi gelen ödemeler için bildirim al.'),
                value: provider.notificationsEnabled,
                onChanged: (bool value) {
                  provider.setNotificationsEnabled(value);
                },
                secondary: const Icon(Icons.notifications_active),
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
              
              // Delete Old Seasons
              if (pastSeasons.isNotEmpty) ...[
                const Divider(),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Eski Sezonları Sil',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<Season>(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Silinecek Sezon',
                            prefixIcon: Icon(Icons.delete_outline, color: Colors.red),
                          ),
                          value: _selectedSeasonToDelete,
                          items: pastSeasons.map((season) {
                            return DropdownMenuItem<Season>(
                              value: season,
                              child: Text(season.name),
                            );
                          }).toList(),
                          onChanged: (selectedSeason) {
                            if (selectedSeason != null) {
                              setState(() {
                                _selectedSeasonToDelete = selectedSeason;
                              });
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Sezonu Sil?'),
                                  content: Text(
                                    'DİKKAT: "${selectedSeason.name}" ve içindeki tüm kayıtlar KALICI OLARAK silinecek. Bu işlem geri alınamaz!',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        setState(() {
                                          _selectedSeasonToDelete = null;
                                        });
                                      },
                                      child: const Text('İptal'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      onPressed: () async {
                                        await provider.deleteSeason(selectedSeason.id);
                                        if (context.mounted) {
                                          Navigator.pop(context); // Close dialog
                                          
                                          // Reset selection
                                          setState(() {
                                            _selectedSeasonToDelete = null;
                                          });

                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Sezon silindi.')),
                                          );
                                        }
                                      },
                                      child: const Text('SİL', style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
