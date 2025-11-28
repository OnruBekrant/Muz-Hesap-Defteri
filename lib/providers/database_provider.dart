import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/season.dart';
import '../models/transaction.dart';
import '../services/notification_service.dart';

class DatabaseProvider extends ChangeNotifier {
  Season? _currentSeason;
  Season? _activeSeason;
  List<Transaction> _transactionList = [];

  Season? get currentSeason => _currentSeason;
  Season? get activeSeason => _activeSeason;
  List<Transaction> get transactionList => _transactionList;

  bool get isHistoryMode => _currentSeason != null && _activeSeason != null && _currentSeason!.id != _activeSeason!.id;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  Box<Season>? _seasonBox;
  Box<Transaction>? _transactionBox;
  Box? _settingsBox;

  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> init() async {
    // Open Hive boxes
    _seasonBox = await Hive.openBox<Season>('seasons');
    _transactionBox = await Hive.openBox<Transaction>('transactions');
    _settingsBox = await Hive.openBox('settings');

    _notificationsEnabled = _settingsBox!.get('notificationsEnabled', defaultValue: true);

    await NotificationService().init();

    // Find active season
    try {
      _activeSeason = _seasonBox!.values.firstWhere((s) => s.isActive);
    } catch (e) {
      // No active season found, create new one
      await _createFirstSeason();
    }

    _currentSeason = _activeSeason;
    await _loadTransactions();
    notifyListeners();
  }

  Future<void> _createFirstSeason() async {
    final newSeason = Season(
      id: const Uuid().v4(),
      name: 'Yeni Sezon',
      isActive: true,
      startDate: DateTime.now(),
    );
    await _seasonBox!.add(newSeason);
    _activeSeason = newSeason;
  }

  Future<void> _loadTransactions() async {
    if (_currentSeason == null || _transactionBox == null) return;

    _transactionList = _transactionBox!.values
        .where((t) => t.seasonId == _currentSeason!.id)
        .toList();
    
    // Sort by date descending (newest first)
    _transactionList.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  void switchToHistory(Season season) {
    _currentSeason = season;
    _loadTransactions();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void resetToHome() {
    if (_activeSeason != null) {
      _currentSeason = _activeSeason;
      _loadTransactions();
    }
  }

  Future<void> addTransaction({
    required TransactionType type,
    required DateTime date,
    required double amount,
    required String description,
    double? weight,
    int? unitCount,
    double? unitPrice, // Can be null if calculated
    String? relatedTransactionId,
    DateTime? dueDate,
  }) async {
    if (_activeSeason == null) return;

    // Calculate unit price if not provided but weight and amount exist
    double? finalUnitPrice = unitPrice;
    if (type == TransactionType.alacak && weight != null && weight > 0 && amount > 0) {
      finalUnitPrice = amount / weight;
    }

    final newTransaction = Transaction(
      id: const Uuid().v4(),
      seasonId: _activeSeason!.id,
      type: type,
      date: date,
      amount: amount,
      description: description,
      weight: weight,
      unitCount: unitCount,
      unitPrice: finalUnitPrice,
      relatedTransactionId: relatedTransactionId,
      dueDate: dueDate,
    );

    await _transactionBox!.add(newTransaction);
    
    // If we are currently viewing the active season, update the list immediately
    if (_currentSeason?.id == _activeSeason!.id) {
      _transactionList.insert(0, newTransaction); // Add to top
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    if (_activeSeason == null) return;

    final index = _transactionList.indexWhere((t) => t.id == transactionId);
    if (index != -1) {
      final transaction = _transactionList[index];
      await transaction.delete(); // Delete from Hive
      _transactionList.removeAt(index); // Remove from local list
      notifyListeners();
    }
  }

  Future<void> closeSeason() async {
    if (_activeSeason == null) return;

    // 1. Update season name based on dates
    String seasonName = "Sezon";
    if (_transactionList.isNotEmpty) {
      final firstDate = _transactionList.last.date; // Oldest
      final lastDate = _transactionList.first.date; // Newest
      final dateFormat = DateFormat('yyyy');
      seasonName = "${dateFormat.format(firstDate)} - ${dateFormat.format(lastDate)} Sezonu";
    } else {
       seasonName = "${DateFormat('yyyy').format(_activeSeason!.startDate)} Sezonu";
    }

    _activeSeason!.name = seasonName;
    _activeSeason!.isActive = false;
    _activeSeason!.endDate = DateTime.now();
    await _activeSeason!.save(); // Save changes to Hive

    // 2. Create new active season
    final newSeason = Season(
      id: const Uuid().v4(),
      name: 'Yeni Sezon',
      isActive: true,
      startDate: DateTime.now(),
    );
    await _seasonBox!.add(newSeason);
    
    _activeSeason = newSeason;
    _currentSeason = newSeason;
    _transactionList = []; // Empty list for new season
    
    notifyListeners();
  }

  Future<void> deleteSeason(String seasonId) async {
    if (_seasonBox == null || _transactionBox == null) return;

    // 1. Delete all transactions for this season
    final transactionsToDelete = _transactionBox!.values
        .where((t) => t.seasonId == seasonId)
        .toList();
    
    for (var transaction in transactionsToDelete) {
      await transaction.delete();
    }

    // 2. Delete the season itself
    final seasonToDelete = _seasonBox!.values.firstWhere((s) => s.id == seasonId);
    await seasonToDelete.delete();

    // 3. If we deleted the current season (history view), reset to active season
    if (_currentSeason?.id == seasonId) {
      resetToHome();
    }
    
    notifyListeners();
  }
  
  // Helper to get all past seasons for history view
  List<Season> getPastSeasons() {
    if (_seasonBox == null) return [];
    return _seasonBox!.values.where((s) => !s.isActive).toList();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    await _settingsBox!.put('notificationsEnabled', value);
    
    if (!value) {
      await NotificationService().cancelAll();
    }
    
    notifyListeners();
  }
}
