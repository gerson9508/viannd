import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/report_model.dart';

Future<void> downloadReportPdf(ReportModel report, int weekNumber, String weekRange) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Título
            pw.Text(
              'Reporte Semana $weekNumber',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(weekRange, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey)),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 16),

            // Macros
            pw.Text('Macronutrientes promedio',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _macroBox('Proteína', '${report.avgProtein.toInt()}g'),
                _macroBox('Carbos', '${report.avgCarbs.toInt()}g'),
                _macroBox('Grasas', '${report.avgFat.toInt()}g'),
              ],
            ),
            pw.SizedBox(height: 20),

            // Datos clave
            pw.Text('Datos clave',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: ['Métrica', 'Valor'],
              data: [
                ['Cumplimiento', '${report.compliancePercent.toInt()}%'],
                ['Promedio de calorías', '${report.avgCalories.toInt()} kcal'],
                ['Días consecutivos', '${report.consecutiveDays}'],
                ['Extras', '${report.totalExtras}'],
              ],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellPadding: const pw.EdgeInsets.all(8),
            ),
            pw.SizedBox(height: 20),

            // Calorías diarias
            pw.Text('Calorías por día',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            if (report.dailyCalories.isNotEmpty)
              pw.Table.fromTextArray(
                headers: ['Día', 'Calorías'],
                data: report.dailyCalories
                    .map((d) => [d['day'], '${d['calories']} kcal'])
                    .toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                cellPadding: const pw.EdgeInsets.all(8),
              ),
          ],
        );
      },
    ),
  );

  // Abre el diálogo de compartir/guardar/imprimir
  await Printing.sharePdf(
    bytes: await pdf.save(),
    filename: 'reporte_semana_$weekNumber.pdf',
  );
}

pw.Widget _macroBox(String label, String value) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey400),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
    ),
    child: pw.Column(
      children: [
        pw.Text(value, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Text(label, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey)),
      ],
    ),
  );
}