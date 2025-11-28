import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/database_provider.dart';
import '../models/transaction.dart';
import '../services/pdf_service.dart';
import '../widgets/transaction_item.dart';
import '../constants/colors.dart';

class TransactionDetailScreen extends StatefulWidget {
  const TransactionDetailScreen({super.key});

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
      builder: (context, provider, child) {
        final currentSeason = provider.currentSeason;
        if (currentSeason == null) return const SizedBox.shrink();

        final muzList = provider.transactionList
            .where((t) => t.type == TransactionType.alacak)
            .toList();
        
        final paraList = provider.transactionList
            .where((t) => t.type == TransactionType.alindi)
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Hesap Detayları'),
            actions: [
              IconButton(
                icon: const Icon(Icons.print),
                onPressed: () async {
                  if (_tabController.index == 0) {
                    await PdfService().generateTransactionReport(
                      currentSeason,
                      muzList,
                      customTitle: "Verilen Muz Listesi",
                    );
                  } else {
                    await PdfService().generateTransactionReport(
                      currentSeason,
                      paraList,
                      customTitle: "Alınan Para Listesi",
                    );
                  }
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  icon: Icon(Icons.agriculture),
                  text: 'VERİLEN MUZ',
                ),
                Tab(
                  icon: Icon(Icons.attach_money),
                  text: 'ALINAN PARA',
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildMuzTab(muzList),
              _buildParaTab(paraList),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMuzTab(List<Transaction> transactions) {
    double totalAmount = 0;
    double totalWeight = 0;

    for (var t in transactions) {
      totalAmount += t.amount;
      if (t.weight != null) {
        totalWeight += t.weight!;
      }
    }

    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    final numberFormat = NumberFormat.decimalPattern('tr_TR');

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          color: AppColors.yaprakYesili.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Toplam Tutar', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      currencyFormat.format(totalAmount),
                      style: const TextStyle(fontSize: 18, color: AppColors.yaprakYesili, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text('Toplam Kilo', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '${numberFormat.format(totalWeight)} Kg',
                      style: const TextStyle(fontSize: 18, color: AppColors.yaprakYesili, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: transactions.isEmpty
              ? const Center(child: Text('Kayıt bulunamadı'))
              : ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    return TransactionItem(transaction: transactions[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildParaTab(List<Transaction> transactions) {
    double totalAmount = 0;

    for (var t in transactions) {
      totalAmount += t.amount;
    }

    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          color: AppColors.muzSarisi.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                children: [
                  const Text('Toplam Tahsilat', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    currencyFormat.format(totalAmount),
                    style: const TextStyle(fontSize: 20, color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: transactions.isEmpty
              ? const Center(child: Text('Kayıt bulunamadı'))
              : ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    return TransactionItem(transaction: transactions[index]);
                  },
                ),
        ),
      ],
    );
  }
}
