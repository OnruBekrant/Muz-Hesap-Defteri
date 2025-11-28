import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/database_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_item.dart';
import 'add_transaction_screen.dart';
import 'transaction_detail_screen.dart';
import 'settings_screen.dart';
import '../services/pdf_service.dart';
import '../constants/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
      builder: (context, provider, child) {
        final currentSeason = provider.currentSeason;
        
        if (currentSeason == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.home, size: 32),
              onPressed: () {
                provider.resetToHome();
              },
              tooltip: 'Bugüne Dön',
            ),
            title: Text(currentSeason.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.print, size: 28),
                onPressed: () async {
                  await PdfService().generateTransactionReport(
                    currentSeason,
                    provider.transactionList,
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings, size: 28),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TransactionDetailScreen(),
                    ),
                  );
                },
                child: BalanceCard(transactions: provider.transactionList),
              ),
              Expanded(
                child: provider.transactionList.isEmpty
                    ? Center(
                        child: Text(
                          'Henüz işlem yok.',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: provider.transactionList.length,
                        itemBuilder: (context, index) {
                          return TransactionItem(
                            transaction: provider.transactionList[index],
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: currentSeason.isActive
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
                    );
                  },
                  backgroundColor: AppColors.yaprakYesili,
                  child: const Icon(Icons.add, color: Colors.white, size: 36),
                )
              : Container(), // Hide FAB if season is not active
        );
      },
    );
  }
}
