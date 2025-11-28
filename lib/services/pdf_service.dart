import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/season.dart';
import '../models/transaction.dart';
import '../constants/colors.dart';

class PdfService {
  Future<void> generateTransactionReport(Season season, List<Transaction> transactions) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();

    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    final dateFormat = DateFormat('dd.MM.yyyy', 'tr_TR');

    double totalAlacak = 0;
    double totalAlindi = 0;

    // Calculate totals
    for (var t in transactions) {
      if (t.type == TransactionType.alacak) {
        totalAlacak += t.amount;
      } else {
        totalAlindi += t.amount;
      }
    }
    final balance = totalAlacak - totalAlindi;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Muz Hesap Defteri', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Text(season.name, style: pw.TextStyle(fontSize: 18)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              context: context,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignment: pw.Alignment.centerLeft,
              data: <List<String>>[
                <String>['Tarih', 'Tür', 'Açıklama', 'Tutar'],
                ...transactions.map((t) => [
                      dateFormat.format(t.date),
                      t.type == TransactionType.alacak ? 'Alacak' : 'Alındı',
                      t.description,
                      currencyFormat.format(t.amount),
                    ]),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Toplam Alacak: ${currencyFormat.format(totalAlacak)}'),
                    pw.Text('Toplam Alınan: ${currencyFormat.format(totalAlindi)}'),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'GÜNCEL BAKİYE: ${currencyFormat.format(balance)}',
                      style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Muz_Hesap_Raporu_${season.name}.pdf',
    );
  }
}
