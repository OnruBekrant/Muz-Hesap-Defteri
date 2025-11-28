import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/database_provider.dart';
import '../models/transaction.dart';
import '../constants/colors.dart';
import '../services/notification_service.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  TransactionType _selectedType = TransactionType.alacak;
  DateTime _selectedDate = DateTime.now();
  DateTime? _dueDate;
  
  // Controllers
  final _amountController = TextEditingController();
  final _weightController = TextEditingController();
  final _unitCountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _relatedTransactionId;

  @override
  void dispose() {
    _amountController.dispose();
    _weightController.dispose();
    _unitCountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Default due date is 30 days from now
    _dueDate = DateTime.now().add(const Duration(days: 30));
  }

  void _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text.replaceAll(',', '.'));
    final weight = _weightController.text.isNotEmpty 
        ? double.parse(_weightController.text.replaceAll(',', '.')) 
        : null;
    final unitCount = _unitCountController.text.isNotEmpty 
        ? int.parse(_unitCountController.text) 
        : null;

    String description = _descriptionController.text;
    if (description.isEmpty) {
      description = _selectedType == TransactionType.alacak ? 'Muz Teslimi' : 'Para Tahsilatı';
    }

    try {
      Provider.of<DatabaseProvider>(context, listen: false).addTransaction(
        type: _selectedType,
        date: _selectedDate,
        amount: amount,
        description: description,
        weight: weight,
        unitCount: unitCount,
        relatedTransactionId: _relatedTransactionId,
        dueDate: _selectedType == TransactionType.alacak ? _dueDate : null,
      );

      // Schedule Notification if enabled and due date is set
      if (_selectedType == TransactionType.alacak && _dueDate != null) {
        final provider = Provider.of<DatabaseProvider>(context, listen: false);
        if (provider.notificationsEnabled) {
          try {
            int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
            
            await NotificationService().scheduleNotification(
              notificationId,
              'Ödeme Günü Geldi!',
              '${DateFormat('dd MMMM yyyy', 'tr_TR').format(_selectedDate)} tarihinde verdiğiniz $amount TL\'lik muzun ödeme vadesi bugün.',
              _dueDate!,
            );
          } catch (e) {
            debugPrint('Notification scheduling failed: $e');
            // Continue execution even if notification fails
          }
        }
      }
    } catch (e) {
      debugPrint('Error saving transaction: $e');
    } finally {
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.yaprakYesili,
              onPrimary: Colors.white,
              onSurface: AppColors.metinRengi,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        // Update due date if it hasn't been manually changed? 
        // Or just keep the default +30 logic relative to the new date?
        // Let's reset it to +30 days from the new date for convenience
        _dueDate = picked.add(const Duration(days: 30));
      });
    }
  }

  Future<void> _pickDueDate() async {
    if (_dueDate == null) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate!,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.yaprakYesili,
              onPrimary: Colors.white,
              onSurface: AppColors.metinRengi,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni İşlem'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Type Toggle
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.alacak,
                    label: Text('MUZ VERDİM', style: TextStyle(fontSize: 16)),
                    icon: Icon(Icons.arrow_upward),
                  ),
                  ButtonSegment(
                    value: TransactionType.alindi,
                    label: Text('PARA ALDIM', style: TextStyle(fontSize: 16)),
                    icon: Icon(Icons.arrow_downward),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<TransactionType> newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                    // Reset fields relevant to type
                    _weightController.clear();
                    _unitCountController.clear();
                    _relatedTransactionId = null;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return _selectedType == TransactionType.alacak 
                            ? AppColors.koyuYesil 
                            : Colors.redAccent;
                      }
                      return Colors.white;
                    },
                  ),
                  foregroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return Colors.white;
                      }
                      return AppColors.metinRengi;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 2. Date Picker
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tarih',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat('dd MMMM yyyy', 'tr_TR').format(_selectedDate),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Dynamic Fields based on Type
              if (_selectedType == TransactionType.alacak) ...[
                _buildSaleFields(),
              ] else ...[
                _buildPaymentFields(),
              ],

              const SizedBox(height: 16),
              
              // Description (Optional)
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama (Opsiyonel)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                style: const TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.yaprakYesili,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: const Text(
                  'KAYDET',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaleFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _unitCountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Dal Adedi',
                  border: OutlineInputBorder(),
                  suffixText: 'Adet',
                ),
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Kilo',
                  border: OutlineInputBorder(),
                  suffixText: 'Kg',
                ),
                style: const TextStyle(fontSize: 18),
                onChanged: (val) => setState(() {}), // Trigger rebuild for calculation
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Toplam Tutar',
            border: OutlineInputBorder(),
            suffixText: '₺',
            prefixIcon: Icon(Icons.attach_money),
          ),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lütfen tutar giriniz';
            }
            return null;
          },
          onChanged: (val) => setState(() {}), // Trigger rebuild for calculation
        ),
        
        // Average Price Calculation
        if (_weightController.text.isNotEmpty && _amountController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Builder(
              builder: (context) {
                try {
                  final weight = double.parse(_weightController.text.replaceAll(',', '.'));
                  final amount = double.parse(_amountController.text.replaceAll(',', '.'));
                  if (weight > 0) {
                    final avg = amount / weight;
                    return Text(
                      'Ortalama: ${avg.toStringAsFixed(2)} ₺/Kg',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.koyuYesil,
                      ),
                    );
                  }
                } catch (e) {
                  // Ignore parse errors
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          // Due Date Picker
          const SizedBox(height: 16),
          InkWell(
            onTap: _pickDueDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Tahmini Ödeme Tarihi (Vade)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.event_available),
              ),
              child: Text(
                _dueDate != null 
                  ? DateFormat('dd MMMM yyyy', 'tr_TR').format(_dueDate!)
                  : 'Seçilmedi',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentFields() {
    return Column(
      children: [
        TextFormField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Alınan Tutar',
            border: OutlineInputBorder(),
            suffixText: '₺',
            prefixIcon: Icon(Icons.attach_money),
          ),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lütfen tutar giriniz';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Dropdown for related transaction (Optional)
        Consumer<DatabaseProvider>(
          builder: (context, provider, child) {
            final sales = provider.transactionList
                .where((t) => t.type == TransactionType.alacak)
                .toList();
            
            if (sales.isEmpty) return const SizedBox.shrink();

            return DropdownButtonFormField<String>(
              value: _relatedTransactionId,
              decoration: const InputDecoration(
                labelText: 'Hangi Satış İçin? (Opsiyonel)',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Genel Hesaptan'),
                ),
                ...sales.map((sale) {
                  final dateStr = DateFormat('dd MMM').format(sale.date);
                  return DropdownMenuItem<String>(
                    value: sale.id,
                    child: Text(
                      '$dateStr - ${sale.description} (${sale.amount} ₺)',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _relatedTransactionId = value;
                });
              },
              isExpanded: true,
            );
          },
        ),
      ],
    );
  }
}
