import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportUtils {
  static Future<void> shareData(List<dynamic> cycles) async {
    if (cycles.isEmpty) {
      throw Exception('Tidak ada data siklus untuk diekspor.');
    }

    // Prepare headers
    List<List<dynamic>> rows = [];
    rows.add([
      'Tanggal Mulai',
      'Tanggal Selesai',
      'Panjang Siklus (Hari)',
      'Lama Haid (Hari)',
      'Catatan'
    ]);

    // Add data rows
    final dateFormat = DateFormat('yyyy-MM-dd');
    for (var cycle in cycles) {
      rows.add([
        dateFormat.format(cycle.startDate),
        cycle.endDate != null ? dateFormat.format(cycle.endDate!) : '-',
        cycle.cycleLength,
        cycle.periodLength,
        cycle.notes ?? '',
      ]);
    }

    // Convert to CSV string
    String csvData = Csv().encode(rows);

    // Save to temp directory
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/riwayat_siklus.csv';
    final file = File(path);
    await file.writeAsString(csvData);

    // Share file
    await Share.shareXFiles(
      [XFile(path)],
      text: 'Ini adalah ekspor data riwayat siklus saya.',
    );
  }
}
