import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/business_profile.dart';
import '../../../domain/entities/quote.dart';
import '../../../domain/entities/quote_item.dart';
import '../../../domain/entities/work_order.dart';

class PdfService {
  static Future<Uint8List> generateQuotePdf({
    required BusinessProfile business,
    required Quote quote,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(business, quote.quoteNumber, 'COTIZACIÓN'),
          pw.SizedBox(height: 20),
          _buildClientInfo(quote),
          pw.SizedBox(height: 20),
          _buildItemsTable(quote.items),
          pw.SizedBox(height: 20),
          _buildTotals(quote, business.currency),
          if (quote.notes != null && quote.notes!.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            _buildNotes(quote.notes!),
          ],
          pw.SizedBox(height: 40),
          _buildFooter(),
        ],
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateWorkOrderPdf({
    required BusinessProfile business,
    required WorkOrder workOrder,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(business, workOrder.orderNumber, 'ORDEN DE TRABAJO'),
          pw.SizedBox(height: 20),
          _buildWorkOrderInfo(workOrder),
          pw.SizedBox(height: 20),
          if (workOrder.observations != null && workOrder.observations!.isNotEmpty)
            _buildObservations(workOrder.observations!),
          pw.SizedBox(height: 40),
          _buildSignatureSection(),
          pw.SizedBox(height: 20),
          _buildFooter(),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(BusinessProfile business, String number, String type) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue800,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                business.companyName,
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'RUC: ${business.ruc}',
                style: const pw.TextStyle(color: PdfColors.white, fontSize: 10),
              ),
              pw.Text(
                business.phone,
                style: const pw.TextStyle(color: PdfColors.white, fontSize: 10),
              ),
              pw.Text(
                business.email,
                style: const pw.TextStyle(color: PdfColors.white, fontSize: 10),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                type,
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'No. $number',
                style: const pw.TextStyle(color: PdfColors.white, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildClientInfo(Quote quote) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'CLIENTE',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 8),
          pw.Text(quote.clientName),
          pw.Text('Fecha: ${_formatDate(quote.date)}'),
          pw.Text('Válido hasta: ${_formatDate(quote.validUntil)}'),
        ],
      ),
    );
  }

  static pw.Widget _buildWorkOrderInfo(WorkOrder workOrder) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'DATOS DE LA ORDEN',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Cliente: ${workOrder.clientName}'),
          pw.Text('Fecha: ${_formatDate(workOrder.date)}'),
          pw.Text('Estado: ${workOrder.status}'),
          if (workOrder.quoteNumber.isNotEmpty && workOrder.quoteNumber != 'N/A')
            pw.Text('Cotización Referencia: ${workOrder.quoteNumber}'),
          pw.Text('Total: \$${workOrder.total.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  static pw.Widget _buildItemsTable(List<QuoteItem> items) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Descripción', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Cant.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('P. Unit.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
            ),
          ],
        ),
        ...items.map((item) => pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(item.description),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(item.quantity.toString(), textAlign: pw.TextAlign.center),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('\$${item.unitPrice.toStringAsFixed(2)}', textAlign: pw.TextAlign.right),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('\$${item.total.toStringAsFixed(2)}', textAlign: pw.TextAlign.right),
            ),
          ],
        )),
      ],
    );
  }

  static pw.Widget _buildTotals(Quote quote, String currency) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text('Subtotal: '),
              pw.Text('\$${quote.subtotal.toStringAsFixed(2)}'),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text('Impuesto (${quote.taxRate}%): '),
              pw.Text('\$${quote.taxAmount.toStringAsFixed(2)}'),
            ],
          ),
          pw.Divider(),
          pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text('TOTAL: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.Text(
                '\$${quote.total.toStringAsFixed(2)}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildNotes(String notes) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(4),
        color: PdfColors.grey100,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Notas:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(notes),
        ],
      ),
    );
  }

  static pw.Widget _buildObservations(String observations) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(4),
        color: PdfColors.grey100,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Observaciones:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(observations),
        ],
      ),
    );
  }

  static pw.Widget _buildSignatureSection() {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              children: [
                pw.Container(
                  width: 150,
                  height: 60,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text('Firma del Cliente'),
              ],
            ),
            pw.Column(
              children: [
                pw.Container(
                  width: 150,
                  height: 60,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text('Firma y Sello'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Container(
      alignment: pw.Alignment.center,
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Column(
        children: [
          pw.Divider(color: PdfColors.grey400),
          pw.SizedBox(height: 8),
          pw.Text(
            AppConstants.pdfFooterText,
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static Future<void> printQuotePdf({
    required BusinessProfile business,
    required Quote quote,
  }) async {
    final pdfData = await generateQuotePdf(business: business, quote: quote);
    await Printing.layoutPdf(onLayout: (_) async => pdfData);
  }

  static Future<void> printWorkOrderPdf({
    required BusinessProfile business,
    required WorkOrder workOrder,
  }) async {
    final pdfData = await generateWorkOrderPdf(business: business, workOrder: workOrder);
    await Printing.layoutPdf(onLayout: (_) async => pdfData);
  }

  static Future<void> shareQuotePdf({
    required BusinessProfile business,
    required Quote quote,
  }) async {
    final pdfData = await generateQuotePdf(business: business, quote: quote);
    await Printing.sharePdf(bytes: pdfData, filename: '${quote.quoteNumber}.pdf');
  }

  static Future<void> shareWorkOrderPdf({
    required BusinessProfile business,
    required WorkOrder workOrder,
  }) async {
    final pdfData = await generateWorkOrderPdf(business: business, workOrder: workOrder);
    await Printing.sharePdf(bytes: pdfData, filename: '${workOrder.orderNumber}.pdf');
  }
}
