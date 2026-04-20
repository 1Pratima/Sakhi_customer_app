import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:com.navajyoti.app/models/loan.dart';
import 'package:com.navajyoti.app/models/transaction.dart';
import 'package:com.navajyoti.app/utils/formatters.dart';

class StatementService {
  static Future<void> generateLoanStatement({
    required LoanAccount loan,
    required List<Transaction> transactions,
  }) async {
    final pdf = pw.Document();
    
    // Load a font that supports the Rupee symbol (₹)
    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();
    final theme = pw.ThemeData.withFont(
      base: font,
      bold: boldFont,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: theme,
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Navajyoti',
                        style: pw.TextStyle(
                            fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                    pw.Text('Loan Statement',
                        style: pw.TextStyle(fontSize: 16, color: PdfColors.grey700)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Date: ${DateTimeUtils.formatDate(DateTime.now())}'),
                    pw.Text('Loan ID: ${loan.loanId}'),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 30),

            // Account Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Account Summary',
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      _pdfInfoRow('Original Loan Amount:', DateTimeUtils.formatCurrency(loan.principalDisbursed)),
                      _pdfInfoRow('Total Expected:', DateTimeUtils.formatCurrency(loan.totalExpectedRepayment)),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      _pdfInfoRow('Principal Outstanding:', DateTimeUtils.formatCurrency(loan.principalOutstanding)),
                      _pdfInfoRow('Interest Outstanding:', DateTimeUtils.formatCurrency(loan.interestOutstanding)),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      _pdfInfoRow('Total Amount Paid:', DateTimeUtils.formatCurrency(loan.totalRepayment)),
                      _pdfInfoRow('Total Remaining Balance:', DateTimeUtils.formatCurrency(loan.totalOutstanding)),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      _pdfInfoRow('Disbursement Date:', DateTimeUtils.formatDate(loan.disbursedDate)),
                      _pdfInfoRow('Maturity Date:', DateTimeUtils.formatDate(loan.expectedEndDate)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 30),

            // Transactions Table
            pw.Text('Transaction Details',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                // Table Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _pdfCell('Date', isHeader: true),
                    _pdfCell('Description', isHeader: true),
                    _pdfCell('Principal', isHeader: true),
                    _pdfCell('Interest', isHeader: true),
                    _pdfCell('Total', isHeader: true),
                    _pdfCell('Balance', isHeader: true),
                  ],
                ),
                // Table Rows
                ...(() {
                  // Calculate running total outstanding balance
                  // Start from the total expected repayment and subtract payments as we go
                  double runningTotalBalance = loan.totalExpectedRepayment;
                  
                  // We need to process from OLDEST to NEWEST to calculate correctly,
                  // but display from NEWEST to OLDEST.
                  final sortedOldestFirst = List<Transaction>.from(transactions)..sort((a, b) => a.date.compareTo(b.date));
                  final Map<String, double> balanceAtTxn = {};
                  
                  for (var t in sortedOldestFirst) {
                    if (t.type == TransactionType.disbursement) {
                      balanceAtTxn[t.id] = runningTotalBalance;
                    } else {
                      runningTotalBalance -= t.amount;
                      balanceAtTxn[t.id] = runningTotalBalance;
                    }
                  }

                  return transactions.map((t) {
                    return pw.TableRow(
                      children: [
                        _pdfCell(DateTimeUtils.formatDate(t.date)),
                        _pdfCell(t.description),
                        _pdfCell(t.type == TransactionType.emiPayment ? DateTimeUtils.formatCurrency(t.principalPortion) : '-'),
                        _pdfCell(t.type == TransactionType.emiPayment ? DateTimeUtils.formatCurrency(t.interestPortion) : '-'),
                        _pdfCell(DateTimeUtils.formatCurrency(t.amount)),
                        _pdfCell(DateTimeUtils.formatCurrency(balanceAtTxn[t.id] ?? 0.0)),
                      ],
                    );
                  });
                })(),
              ],
            ),
            
            pw.SizedBox(height: 40),
            pw.Center(
               child: pw.Text('*** End of Statement ***', 
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500))
            ),
          ];
        },
      ),
    );

    // Save and Print/Open
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Statement_${loan.loanId}.pdf',
    );
  }

  static pw.Widget _pdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(width: 5),
          pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _pdfCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
